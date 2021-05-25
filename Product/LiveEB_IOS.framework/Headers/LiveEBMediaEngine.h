//
//  LiveEBMediaEngine.h
//  LiveEB_IOS
//
//  Created by ts on 4/7/21.
//  Copyright © 2021 ts. All rights reserved.
//

#import "LiveEBCaptureSource.h"
#import "LiveEBManager.h"
#import "LiveEBVideoRender.h"
#import "LEBStatReport.h"

NS_ASSUME_NONNULL_BEGIN

//stream media engine 相关数据结构
typedef NS_ENUM(NSInteger, LiveEBStreamState) {
  kLiveEBStreamStateConnecting,

  kLiveEBStreamStateConnected,
  
  kLiveEBStreamStateClosed,

  kLiveEBStreamStateDisconnected,
};

@interface LiveEBConfiguration : NSObject

//业务生成的唯一key，标识本次会话
@property (nonatomic, copy) NSString *sessionid;

//指定信令服务器
@property (nonatomic, copy) NSString *rtcHost;

//信令开始
@property (nonatomic, copy) NSString *startStream;

//通讯结束
@property (nonatomic, copy) NSString *stopStream;

//启动统计
@property (nonatomic, assign) BOOL switchStatOn;

//拉流
@property (nonatomic, assign) BOOL isPullStream;

@end

@class LiveEBMediaEngine;
@protocol LiveEBMediaEnginDelegate <NSObject>

//流状态
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
       didChangeState:(LiveEBStreamState)state;

//数据源
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
didCreateLocalSource:(LiveEBCaptureSource *)localSource;

//统计
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
      didGetStats:(LEBStatReport*)stats;

//错误状态
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
         didError:(NSError *)error;
@end

//拉流相关数据结构

@interface LiveEBPullStreamConfigure : NSObject

@property (nonatomic, copy) NSString *streamURL;

@property (nonatomic, copy) NSString *streamIDSDPStream;

@end

@protocol LiveEBPullStreamDelegate <NSObject>

- (void)onPrepared;

/*拉流 包括主动结束和被动结束(断流等)*/
- (void)onCompletion;

/*首帧渲染*/
- (void)onFirstFrameRender;

@end

@interface LiveEBPullStreamContext : NSObject

@property(nonatomic, strong) LiveEBPullStreamConfigure *pullConfig;

@property(weak, nonatomic) id<LiveEBVideoRender> videoRender;

@property(weak, nonatomic) id<LiveEBPullStreamDelegate> streamDelegate;

@property(nonatomic, copy) NSString* remoteSDP;

- (BOOL)isPlaying;

- (void)start;

- (void)stop;

- (void)resume;

- (void)pause;

- (void)background;

- (void)setAudioMute:(BOOL)mute;

- (void)setVideoPaused:(BOOL)paused;

- (CGFloat)setVolume:(CGFloat)volume;

- (CGFloat)getVolume;
@end


//推流相关数据结构
@interface LiveEBPushStreamConfigure : NSObject

@property (nonatomic, copy) NSString *pushURL;

@property (nonatomic, copy) NSString *streamIDSDPStream;

@end

@interface LiveEBPushStreamContext : NSObject

@property(nonatomic, strong) LiveEBPushStreamConfigure *pushConfig;

/*
*  capture作为source, mediaengine作为sink，
*  定制的capture可以使用这个delegate输出数据
*  implemention by LiveEBCaptureSource
*/
@property(weak, nonatomic) id<LiveEBCaptureSinkDelegate> captureSinkDelegate;


- (void)start;

- (void)stop;

@end



@interface LiveEBMediaEngine : NSObject

@property(readonly, nonatomic) LiveEBStreamState connState;

/*
 * pullStreamCtx 拉流模块上下文
 */
@property(readonly, nonatomic) LiveEBPullStreamContext *pullStreamCtx;

/*
 * pullStreamCtx 推流模块上下文
 */
@property(readonly, nonatomic) LiveEBPushStreamContext *pushStreamCtx;

/*
 创建针对拉流的mediaengin pullConfig为拉流配置
 */
+ (instancetype)createPullEngine:(LiveEBPullStreamConfigure*) pullConfig;

- (void)setLiveEBPullStreamDelegate:(id<LiveEBPullStreamDelegate>)delegate;

/*
 创建针对推流的mediaengin pushConfig推流配置
 */
+ (instancetype)createPushEngine:(LiveEBPushStreamConfigure*) pushConfig;



/*
 设置media engin 的配置
 */
- (void)setEnginConfig:(LiveEBConfiguration * _Nonnull)enginConfig;

- (void)setMediaEnginDelegate:(id<LiveEBMediaEnginDelegate>)delegate;

/*TO-DO*/
- (void)setAudioSessionConfiguration:(LiveEBAudioSessionConfiguration *)configuration;

/**
 *  设置video录制源即推流video源
 */
- (void)setCaptureSource:(LiveEBCaptureSource *)captureSource;

/***
 *  设置渲染器 可以自定义
 */
- (void)setVideoRender:(LiveEBVideoRenderAdapter *)videoRender;

/*
 * 是stream media engin 配置生效
 */
- (void)configure;
@end

NS_ASSUME_NONNULL_END
