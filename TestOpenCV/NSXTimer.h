//
//  NSXTimer.h
//  Measures the elapsed time in milliseconds since the initialisation of its object.
//  Can be used to generate timestamps for video and audio buffers.  
//
//  Created by Oliver Arnold on 25/5/16.
//
//  @copyright (c) 2016 nanocosmos. All rights reserved.
//  http://www.nanocosmos.de

#import <Foundation/Foundation.h>

@interface NSXTimer : NSObject
{
    int64_t startTime;
    int64_t time;
    
    int64_t prev_time;
    
    dispatch_queue_t timeQueue;
}

- (id) init;
- (void) dealloc;

- (void) close;
- (int64_t) getTime;
- (void) reset;

@end
