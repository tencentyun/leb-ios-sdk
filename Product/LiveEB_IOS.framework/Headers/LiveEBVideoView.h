//
//  LiveEBVideoView.h
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

#import <WebRTC/RTCEAGLVideoView.h>
#if defined(RTC_SUPPORTS_METAL)
#import <WebRTC/RTCMTLVideoView.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class LiveEBVideoView;

@protocol LiveEBVideoViewControllerDelegate <NSObject>
@required
    -(void)start;
    -(void)stop;
    -(void)restart;
    -(void)setStat;
@end

@protocol LiveEBVideoViewDelegate <NSObject>

@required

- (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error;
- (void)showStats:(LiveEBVideoView *)videoView stat:(NSArray*)stat;
- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size;

@end


@interface LiveEBVideoView : UIView <LiveEBVideoViewControllerDelegate>

@property (nonatomic, copy) NSString *liveEBURL;

@property(nonatomic, weak) id<LiveEBVideoViewDelegate> delegate;
@property(nonatomic, readonly) __kindof UIView<RTCVideoRenderer> *remoteVideoView;
@end

NS_ASSUME_NONNULL_END
