//
//  NSXCustomCaptureSession.h
//  Redirects custom video samples to the nanostreamAVC library.
//
//  Created by Oliver Arnold on 25/05/16.
//
//  @copyright (c) 2016 nanocosmos. All rights reserved.
//  http://www.nanocosmos.de

#import <AVFoundation/AVFoundation.h>

@interface NSXCustomCaptureSession : AVCaptureSession

@property (nonatomic, strong) AVCaptureVideoDataOutput* myVideoOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput* myAudioOutput;

-(id) init;

-(void) addInput:(AVCaptureInput *)input;
-(void) addOutput:(AVCaptureOutput *)output;    // used by nanostreamAVC

-(void) startRunning;
-(void) stopRunning;

-(void) supplyVideoBuffer:(CVImageBufferRef)buffer;
-(void) supplyVideoBuffer:(CVImageBufferRef)buffer withPts:(CMTime)pts withDts:(CMTime)dts andDuration:(CMTime)dur;

-(void) reset;  // reset timing information

@end
