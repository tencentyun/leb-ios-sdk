## 一> LiveEB_IOS SDK (live event Broadcasting)
快直播 LEB （超低延迟直播） IOS SDK https://cloud.tencent.com/product/leb  

下载Demo体验请前点击 [IOS demo下载地址](https://github.com/tencentyun/leb-ios-sdk/tree/master/DEMO/LiveEB_Demo)

## 二> pod 接入

使用Cocoapods的方式来进行集成。在您的podfile中加入需要集成的库即可  

 LiveEB_IOS 封装了webrtc接口  
 
 最新版本参考： https://github.com/tencentyun/leb-ios-sdk/blob/master/DEMO/LiveEB_Demo/Podfile   
 a> LiveEB_IOS内部使用的是 TWebRTC:参考 https://github.com/tencentyun/TWebRTC.git 编译   
    
    参考上面 最新版本demo podfile文件
    
    
    pod 'TWebRTC', :git=>'https://github.com/tencentyun/TWebRTC-IOS-SDK.git' , :tag => '1.0.0'  
    pod 'LiveEB_IOS', :git=>'https://github.com/tencentyun/leb-ios-sdk.git' , :tag => '1.0.1' 
 
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

//错误信息回调
- (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error;

//视频大小回调
- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size;


@optional

//播放准备
- (void)onPrepared:(LiveEBVideoView*)videoView;

//播放结束 包括主动结束和被动结束(断流等)
- (void)onCompletion:(LiveEBVideoView*)videoView;

//首帧渲染回调
- (void)onFirstFrameRender:(LiveEBVideoView*)videoView;

//统计回调
- (void)showStats:(LiveEBVideoView *)videoView statReport:(LEBStatReport*)statReport;

@end

