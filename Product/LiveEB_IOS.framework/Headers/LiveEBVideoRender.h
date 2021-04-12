//
//  LiveEBVideoRender.h
//  LiveEB_IOS
//
//  Created by ts on 4/8/21.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import "LiveEBVideoFrame.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LiveEBVideoRender <NSObject>

/** The size of the frame. */
- (void)setSize:(CGSize)size;

/** The frame to be displayed. */
- (void)renderFrame:(nullable LiveEBVideoFrame *)frame;

- (void)pause:(BOOL)isPause;

- (void)setRenderRotationOverride:(NSValue *)rotationOverride;

- (void)setViewContentMode:(UIViewContentMode)contentMode;

@optional

-(LiveEBVideoFrame*)captureFrame;
@end

@interface LiveEBVideoRenderAdapter : NSObject<LiveEBVideoRender>

//需要把定制的渲染器设置到渲染适配器中
- (instancetype)initWithCustomeRender:(id<LiveEBVideoRender>)customeRender;

@end

NS_ASSUME_NONNULL_END
