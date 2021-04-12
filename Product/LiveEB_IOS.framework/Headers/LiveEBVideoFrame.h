//
//  LiveEBVideoFrame.h
//  LiveEB_IOS
//
//  Created by ts on 4/8/21.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, LEBVideoRotation) {
  LEBVideoRotation_0 = 0,
  LEBVideoRotation_90 = 90,
  LEBVideoRotation_180 = 180,
  LEBVideoRotation_270 = 270,
};

NS_ASSUME_NONNULL_BEGIN

@interface LiveEBVideoFrame : NSObject

@property(nonatomic, readonly) CVPixelBufferRef pixelBuffer;

@property(nonatomic, readonly) LEBVideoRotation rotation;

@end

NS_ASSUME_NONNULL_END
