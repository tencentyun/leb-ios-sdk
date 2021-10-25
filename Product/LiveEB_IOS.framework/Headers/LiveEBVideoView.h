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

#import <TWEBRTC/TWEBRTC.h>
#if defined(RTC_SUPPORTS_METAL)
#import <TWEBRTC/RTCMTLVideoView.h>
#endif

#import "LEBStatReport.h"
#import "LiveEBManager.h"
#import "LiveEBMediaEngine.h"

NS_ASSUME_NONNULL_BEGIN

@class LiveEBVideoView;

typedef NS_ENUM(NSInteger, LiveEBViewConnectionState) {
    LiveEBView_Connection_State_CONNECTED,
    LiveEBView_Connection_State_DISCONN,
    LiveEBView_Connection_State_FAILED,
    LiveEBView_Connection_State_TIMEOUT,
};

@protocol LiveEBVideoViewControllerDelegate <NSObject>
@required
    -(void)start;

    -(void)stop;

    -(void)stopByJoin;

    -(void)pause;

    -(void)resume;
    
    -(void)background;
    
    /*
     * 表示流建联后正在播放
     */
    -(BOOL)isPlaying;
    
    /*
     * 表示流建联有效
     */
    -(BOOL)isRuning;

    /* 0 ~ 1 返回上次的设置值*/
    -(CGFloat)setVolume:(CGFloat)volume;

    -(void)setAudioMute:(BOOL)mute;

    -(void)setVideoPaused:(BOOL)paused;
    
    - (void)restart;

    /*开启统计回*/
    -(void)setStatState:(BOOL)stat;

    -(void)setWebRTCConfiguration:(LiveEBAudioSessionConfiguration *)configuration;
    
    ///【字段含义】播放器遭遇网络连接断开时 SDK 默认重试的次数 和网络重连的时间间隔
    -(void)setConnectRetryCount:(int)retryCount retryInterval:(int)retryInterval;
    
    /*获取截图*/
    -(UIImage*)captureVideoFrame;
    
    /*旋转*/
    - (void)setRenderRotation:(LEBVideoRotation)rotation;

    - (void)setRenderMode:(LEBVideoRenderMode)renderMode;
@end

@protocol LiveEBVideoViewDelegate <NSObject>

@required
/*
 * 信令
 * 或者播放器初始化过程中出现的错误
*/
- (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error;

- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size;

@optional
/*
 * 播放器成功初始化，准备播放
 */
- (void)videoView:(LiveEBVideoView *)videoView didFrozenUpdated:(BOOL)freeze;

/*
 * ICE建联过程出现的错误
 * 网络通讯相关错误
*/
- (void)videoView:(LiveEBVideoView *)videoView LiveEBViewConnectionState:(LiveEBViewConnectionState)state didError:(nullable NSError *)error;

- (void)onPrepared:(LiveEBVideoView*)videoView;

/*
 * 播放结束
 * 包括主动结束和被动结束(断流等)
 */
- (void)onCompletion:(LiveEBVideoView*)videoView;

- (void)onFirstFrameRender:(LiveEBVideoView*)videoView;

- (void)onSeiMetadata:(NSData *)bitstream;

/*统计接口*/
- (void)showStats:(LiveEBVideoView *)videoView statReport:(LEBStatReport*)statReport;

- (void)showStats:(LiveEBVideoView *)videoView rtcStatReport:(LEBRTCStatReport*)rtcStatReport
  __attribute__((deprecated("function rtcStatReport deprecated, use statReport function instead.")));


- (void)showStats:(LiveEBVideoView *)videoView strStat:(NSString*)strStat;

- (void)showStats:(LiveEBVideoView *)videoView stat:(NSArray*)stat
  __attribute__((deprecated("function stat deprecated, use strStat function instead.")));

@end


@interface LiveEBVideoView : UIView <LiveEBVideoViewControllerDelegate,
                                LiveEBPullStreamDelegate,
                                LiveEBMediaEnginDelegate>

/*默认内部设置，可以提供给view层接口查询信息*/
@property(nonatomic, readonly, strong) LiveEBMediaEngine *mediaEngine;

@property (nonatomic, copy) NSString *rtcHost;

@property (nonatomic, copy) NSString *sessionid;      //业务生成的唯一key，标识本次播放会话

@property (nonatomic, copy) NSString *liveEBURL;  //播放流地址
@property(nonatomic, weak) id<LiveEBVideoViewDelegate> delegate;
@property(nonatomic, readonly) __kindof UIView<RTCVideoRenderer> *remoteVideoView;

//拉流
- (instancetype)initWithFrame:(CGRect)frame;

/*V1*/
-(void)setLiveURL:(NSString *)liveEBURL pullStream:(NSString *)pullStream stopStream:(NSString *)stopStream;

/*V2*/
@property (nonatomic, copy) NSString *streamIDSDPStream; //live/streamID.sdp?route=mcd0&token=tencent_video

//推流 TO-DO
- (instancetype)initWithFrame:(CGRect)frame isPushPreview:(BOOL)isPushPreview;
/*
 推流信息配置
 */
-(void)setPushStreamURL:(NSString *)pushEBURL pullSignalStream:(NSString *)pullSignalStream stopSignalStream:(NSString *)stopSignalStream;

//testing TO-DO
- (instancetype)initWithFrame:(CGRect)frame room:(NSString*)room;
@end

NS_ASSUME_NONNULL_END
