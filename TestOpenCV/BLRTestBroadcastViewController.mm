//
//  BLRTestBroadcastViewController.m
//  BallerApp
//
//  Created by Ping Chen on 1/27/17.
//  Copyright © 2017 Baller, Inc. All rights reserved.
//

#import "BLRTestBroadcastViewController.h"
#import "BLRUIHelper.h"
#import "nanostreamAVC.h"
#import "NSXCustomCaptureSession.h"

#include <stdlib.h>
#import <opencv2/videoio/cap_ios.h>
using namespace cv;
using namespace std;


@interface BLRTestBroadcastViewController () <UIScrollViewDelegate, CvVideoCameraDelegate>

@property (strong) UIView *videoPreview;

@property (nonatomic, retain) CvVideoCamera *videoCamera;

@property std::deque<cv::Mat> ring;

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
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.videoPreview];
    self.videoCamera.delegate = self;
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    _ring.clear();
    
    UISwipeGestureRecognizer *swipeAway = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedAway:)];
    [self.view addGestureRecognizer:swipeAway];
    
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

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{

//    // convert to grayscale
//    Mat gray; cvtColor(image, gray, CV_BGRA2GRAY);
//
//    // copy back to image
//    cvtColor(gray, image, CV_GRAY2BGRA);
    
    
    // convert to grayscale and blur
    Mat gray;
    cvtColor(image, gray, CV_BGRA2GRAY);
    GaussianBlur(gray, gray, cv::Size(21, 21), 0);
    

    if (_ring.size() >= 10) {

        CGFloat cols = gray.cols;
        CGFloat rows = gray.rows;
        
        // calculate a moving average
        Mat avgImg(rows, cols, CV_32FC(gray.channels()));
        for (int i =0; i<10; i++) {
            cv::accumulate(_ring[i], avgImg);
        }
        
        // compute the absolute difference between the current frame and the moving average
        Mat frameDelta;
        cv::absdiff(gray, avgImg, frameDelta);
        
        Mat thresh;
        cv::threshold(frameDelta, thresh, 25, 255, THRESH_BINARY);
        
        
        //This part is just to display motions (delete for production)
        // dilate the thresholded image to fill in holes, then find contours on thresholded image
        cv::dilate(thresh, thresh, cv::getStructuringElement(MORPH_RECT, cv::Size()));
        
        thresh = cv2.dilate(thresh, None, iterations=2)
        (cnts, _) = cv2.findContours(thresh.copy(), cv2.RETR_EXTERNAL,
                                     cv2.CHAIN_APPROX_SIMPLE)
        
        
        
        cv::BackgroundSubtractorMOG2
        
        avgImg.release();

    }
    
    // add grayscale version to ringbuffer
    _ring.push_back(gray);
    
    if (_ring.size() > 10) {
        Mat temp = _ring.front();
        temp.release();
        _ring.pop_front();
    }
    
    
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
