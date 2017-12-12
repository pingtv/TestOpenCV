//
//  BLRTestBroadcastViewController.m
//  BallerApp
//
//  Created by Ping Chen on 1/27/17.
//  Copyright © 2017 Baller, Inc. All rights reserved.
//

#import "BLRTestBroadcastViewController.h"
#import "BLRTestControlView.h"
#import "BLRUIHelper.h"
#import "nanostreamAVC.h"
#import "NSXCustomCaptureSession.h"

#include <stdlib.h>
#import <opencv2/videoio/cap_ios.h>
using namespace cv;
using namespace std;


@interface BLRTestBroadcastViewController () <UIScrollViewDelegate, CvVideoCameraDelegate>

@property (strong) UIView *videoPreview;
@property (strong) UILabel *motionMeasure;

@property (nonatomic, retain) CvVideoCamera *videoCamera;
@property (nonatomic, strong) BLRTestControlView *ctrlView;

@property std::deque<cv::Mat> ring;


@property int gaussianBlurDimension;
@property int binaryThreshold;
@property double accumulationAlpha;

@end


@implementation BLRTestBroadcastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    self.videoPreview = [[UIView alloc] init];
    [self.videoPreview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [BLRUIHelper addView:self.videoPreview toLeftRightEdgesOfSuperview:self.view withGap:0.0];
    [BLRUIHelper constrainView:self.videoPreview onTopOfSuperviewWithGap:0.0];
    [BLRUIHelper constrainView:self.videoPreview onBottomOfSuperviewWithGap:0.0];
    
    self.gaussianBlurDimension = kBlurDimensionMin;
    self.binaryThreshold = kThresholdMin;
    self.accumulationAlpha = (double)kAccAlphaMin;
    
    [self setupCamera];
    [self setupControls];
    
    self.motionMeasure = [[UILabel alloc] initWithFrame:CGRectMake(100, 70, 100, 60)];
    [self.view addSubview:self.motionMeasure];
    
    _ring.clear();
    
    UISwipeGestureRecognizer *swipeAway = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedAway:)];
    [self.view addGestureRecognizer:swipeAway];
    
}

- (void)setupCamera {
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.videoPreview];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
}

- (void)setupControls {
    
    self.ctrlView = [[BLRTestControlView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
//    [_ctrlView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [_ctrlView addConstraint:[NSLayoutConstraint constraintWithItem:_ctrlView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:260.0]];
//    [_ctrlView addConstraint:[NSLayoutConstraint constraintWithItem:_ctrlView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:200.0]];
    [self.view addSubview:self.ctrlView];
//    [BLRUIHelper constrainView:_ctrlView onBottomOfSuperviewWithGap:-10.0];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_ctrlView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0.0]];
    
    [self.ctrlView setBackgroundColor:[UIColor greenColor]];
    
    [self.ctrlView.gaussianSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    [self.ctrlView.thresholdSlider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // We do not want the screen to lock while streaming.
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.videoCamera start];
}

- (void)dealloc {

    _ring.clear();
    
    if (_ctrlView != nil) {
        [_ctrlView.gaussianSlider removeObserver:self forKeyPath:@"value"];
        [_ctrlView.thresholdSlider removeObserver:self forKeyPath:@"value"];
    }
}


- (void)swipedAway:(id)sender {
    
    if (self.videoCamera) {
        [self.videoCamera stop];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - key value
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:@"value"]) {
        return;
    }
    
    if (object == _ctrlView.gaussianSlider) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        self.gaussianBlurDimension = [(NSNumber *)newValue intValue];
    }
    
    if (object == _ctrlView.thresholdSlider) {
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        self.binaryThreshold = [(NSNumber *)newValue intValue];
    }
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    
    // convert to grayscale and blur
    Mat gray;
    cvtColor(image, gray, CV_BGRA2GRAY);
    GaussianBlur(gray, gray, cv::Size(_gaussianBlurDimension, _gaussianBlurDimension), 0);
    
    image = gray;

    if (_ring.size() >= 10) {

        CGFloat cols = gray.cols;
        CGFloat rows = gray.rows;
        
        // calculate a moving average
        Mat avgImg(rows, cols, CV_32FC1);
        for (int i =0; i<10; i++) {
            cv::accumulateWeighted(_ring[i], avgImg, _accumulationAlpha);
        }
        
        
//        // compute the absolute difference between the current frame and the moving average
//        Mat frameDelta(rows, cols, CV_32FC1);
//        cv::absdiff(gray, avgImg, frameDelta);
//
//        // Apply threshold
//        Mat thresh;
//        cv::threshold(frameDelta, thresh, _binaryThreshold, 255, THRESH_BINARY);
//
//        // Find all contours
//        std::vector<std::vector<cv::Point> > contours;
//        cv::findContours(thresh, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE);
//
//        // Count all motion areas
//        std::vector<std::vector<cv::Point> > motionAreas;
//        double motionValue = 0;
//        for (int i = 0; i < contours.size(); i++) {
//            double area = cv::contourArea(contours[i]);
//            //only count motion above a certain size (filter some artifacts)
//            if (area > 5){
//                motionAreas.push_back(contours[i]);
//                motionValue += area;
//            }
//        }
//
//        [self.motionMeasure setText:[NSString stringWithFormat:@"motionValue: %.2f", motionValue]];
//
//        avgImg.release();
//        frameDelta.release();
//        thresh.release();
        
    }
    
    // add grayscale version to ringbuffer
    _ring.push_back(gray);
    
    if (_ring.size() > 10) {
        Mat temp = _ring.front();
        temp.release();
        _ring.pop_front();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view bringSubviewToFront:self.motionMeasure];
        [self.view bringSubviewToFront:self.ctrlView.inputView];
    });
    
    
}
#endif





/*

- (void)setupAVCapture {
    //-- Setup Capture Session.
    self.session = [[NSXCustomCaptureSession alloc] init];
    [self.session beginConfiguration];
    
    //-- Set preset session size.
    [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //-- Add the device to the session.
    NSError *err = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&err];
    if (videoInput) {
        [self.session addInput:videoInput];
    } else {
        NSLog(@"videoInput failed: %@", err.localizedDescription);
    }
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&err];
    if (audioInput) {
        [self.session addInput:audioInput];
    } else {
        NSLog(@"audioInput failed: %@", err.localizedDescription);
    }
    
    //-- Create the data output for the capture session.
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    if (!self.sessionQueue) {
        self.sessionQueue = dispatch_queue_create("com.baller.sessionQueue", DISPATCH_QUEUE_SERIAL);
    }
    [dataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    [self.session addOutput:dataOutput];
    
    
    //-- Create the preview layer output
    CALayer *layer = self.videoPreview.layer;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [layer addSublayer:captureVideoPreviewLayer];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    [self.session commitConfiguration];
    
    [self.session startRunning];
}
 
 */




@end
