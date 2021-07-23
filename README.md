## 一> LiveEB_IOS SDK (live event Broadcasting)
快直播 LEB （超低延迟直播） IOS SDK https://cloud.tencent.com/product/leb  

下载Demo体验请前点击 [IOS demo下载地址](https://github.com/tencentyun/leb-ios-sdk/tree/master/DEMO/LiveEB_Demo)

## 二> pod 接入

使用Cocoapods的方式来进行集成。在您的podfile中加入需要集成的库即可  

 LiveEB_IOS 封装了webrtc接口  

 最新版本参考： https://github.com/tencentyun/leb-ios-sdk/blob/master/DEMO/LiveEB_Demo/Podfile   
 a> LiveEB_IOS内部使用的是 TWebRTC:参考 https://github.com/tencentyun/TWebRTC.git 编译   
    
    参考上面 最新版本demo podfile文件


​    
​    pod 'TWebRTC', :git=>'https://github.com/tencentyun/TWebRTC-IOS-SDK.git' , :tag => '1.0.0'  
​    pod 'LiveEB_IOS', :git=>'https://github.com/tencentyun/leb-ios-sdk.git' , :tag => '1.0.1' 

说明：  
   https://github.com/tencentyun/TWebRTC.git 是TWebRTC源码  
   https://github.com/tencentyun/TWebRTC-IOS-SDK.git 是ios TWebRTC的源码编译后pod私有仓库  
   https://github.com/tencentyun/leb-ios-sdk.git  是封装webrtc接口的封装层。包括源码和私有仓库。  

## 三> demo使用：  

1> cd LiveEB_Demo  
2> pod install  


## 支持平台
SDK支持IOS 9.0以上系统

## 开发环境
xcode10及以上环境


## Xcode工程设置
### 1> pod依赖framework。也可以调试依赖代码。





## 四> API使用说明

### 添加头文件
#import <LiveEB_IOS/LiveEB_IOS.h>

### 1>  初始化sdk
__weak typeof(self) weakSelf = self;
 [[LiveEBManager sharedManager] initSDK:weakSelf];



### 2> 创建LiveEBVideoView 用于渲染播放，设置播放url
 _remoteVideoView = [LiveEBVideoView new];  
[self addSubview:_remoteVideoView];  

_remoteVideoView2.liveEBURL = liveEBURL;  

eg:
 liveEBURL= @"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a";  

### 3> 获取LiveEBVideoViewControllerDelegate 进行播放控制
_controlDelegate = _remoteVideoView;

   -(void)start;  //开始播放  
    -(void)stop;  //结束播放  

### 4 释放sdk.
-(void)finitSDK;

### 5 事件回调.
@protocol LiveEBVideoViewDelegate <NSObject>

@required

#### 错误信息回调
 - (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error;

#### 视频大小回调
- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size;


@optional

#### 播放准备
- (void)onPrepared:(LiveEBVideoView*)videoView;

#### 播放结束 包括主动结束和被动结束(断流等)
- (void)onCompletion:(LiveEBVideoView*)videoView;

#### 首帧渲染回调
- (void)onFirstFrameRender:(LiveEBVideoView*)videoView;

#### 统计回调
- (void)showStats:(LiveEBVideoView *)videoView statReport:(LEBStatReport*)statReport;

@end

### 6 LiveEBMediaEngine接口

/*默认内部设置，可以提供给view层接口查询信息*/
@property(nonatomic, readonly, strong) LiveEBMediaEngine *mediaEngine;

## 五> LiveEBMediaEngine接口和引擎接口说明

#### stream media engine 相关数据结构
typedef NS_ENUM(NSInteger, LiveEBStreamState) {
  kLiveEBStreamStateConnecting,

  kLiveEBStreamStateConnected,

  kLiveEBStreamStateClosed,

  kLiveEBStreamStateDisconnected,
};

@interface LiveEBConfiguration : NSObject

#### 业务生成的唯一key，标识本次会话
@property (nonatomic, copy) NSString *sessionid;

#### 指定信令服务器
@property (nonatomic, copy) NSString *rtcHost;

#### 信令开始
@property (nonatomic, copy) NSString *startStream;

#### 通讯结束
@property (nonatomic, copy) NSString *stopStream;

#### 启动统计
@property (nonatomic, assign) BOOL switchStatOn;

#### 拉流
@property (nonatomic, assign) BOOL isPullStream;

@end

@class LiveEBMediaEngine;
@protocol LiveEBMediaEnginDelegate <NSObject>

#### 流状态
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
       didChangeState:(LiveEBStreamState)state;

#### 数据源
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
didCreateLocalSource:(LiveEBCaptureSource *)localSource;

#### 统计
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
      didGetStats:(LEBStatReport*)stats;

#### 错误状态
- (void)mediaEngin:(LiveEBMediaEngine *)mediaEngin
         didError:(NSError *)error;
@end

#### 拉流相关数据结构

@interface LiveEBPullStreamConfigure : NSObject

@property (nonatomic, copy) NSString *streamURL;

@property (nonatomic, copy) NSString *streamIDSDPStream;

@end

@protocol LiveEBPullStreamDelegate <NSObject>

- (void)onPrepared;

#### /*拉流 包括主动结束和被动结束(断流等)*/
- (void)onCompletion;

#### /*首帧渲染*/
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


#### 推流相关数据结构
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

## 6 LiveEBMediaEngine引擎层 是提供更深层次的接口。
  需要自定义渲染器注册给LiveEBMediaEngine。目前LiveEBVideoView内部已实现利用 LiveEBMediaEngine使用sdk。后续将会开源渲染器定义代码，提供类似LiveEBVideoView的代码方便用户从LiveEBMediaEngine接入sdk。