//
//  LiveEBCaptureSource.hpp
//  LiveEB_IOS
//
//  Created by ts on 4/7/21.
//

#ifndef LiveEBCaptureSource_h
#define LiveEBCaptureSource_h

#import "LiveEBManager.h"
#import <AVFoundation/AVFoundation.h>

#include <stdio.h>


@class LiveEBCaptureSource;

@protocol LiveEBCaptureSinkDelegate <NSObject>

- (void)captureSampleBuffer:(CMSampleBufferRef)sampleBuffer
       correctAngle:(LEBVideoRotation)correctAngle
       frontCamera:(BOOL)frontCamera
       timestamp:(UInt64)timestamp;

@end

@interface LiveEBCaptureSource : NSObject <LiveEBCaptureSinkDelegate>

@end

#endif /* LiveEBCaptureSource_h */
