## LiveEB_IOS SDK (live event Broadcasting)
快直播 LEB （超低延迟直播） IOS SDK https://cloud.tencent.com/product/leb  

下载Demo体验请前点击 [IOS demo下载地址](https://github.com/tencentyun/leb-ios-sdk/tree/master/DEMO/LiveEB_Demo)

## pod 接入

使用Cocoapods的方式来进行集成。在您的podfile中加入需要集成的库即可  

 LiveEB_IOS 封装了webrtc接口  
 
 a> LiveEB_IOS内部使用的是 TWebRTC:参考 https://github.com/tencentyun/TWebRTC.git 编译   
    
    pod 'TWebRTC', :git=>'https://github.com/tencentyun/TWebRTC-IOS-SDK.git' , :tag => '1.0.0'  
    pod 'LiveEB_IOS', :git=>'https://github.com/tencentyun/leb-ios-sdk.git' , :tag => '1.0.1'  
 
说明：  
   https://github.com/tencentyun/TWebRTC.git 是TWebRTC源码  
   https://github.com/tencentyun/TWebRTC-IOS-SDK.git 是ios TWebRTC的源码编译后pod私有仓库  
   https://github.com/tencentyun/leb-ios-sdk.git  是封装webrtc接口的封装层。包括源码和私有仓库。  
   
demo使用：  

cd LiveEB_Demo  
pod install  


## 支持平台
SDK支持IOS 9.0以上系统

## 开发环境
xcode10及以上环境


## Xcode工程设置
### 1> pod依赖framework。也可以调试依赖代码。





## API使用说明

### 添加头文件
#import <LiveEB_IOS/LiveEB_IOS.h>

### 1>  初始化sdk
__weak typeof(self) weakSelf = self;
 [[LiveEBManager sharedManager] initSDK:weakSelf];



### 2> 创建LiveEBVideoView 用于渲染播放，设置播放url
 _remoteVideoView = [LiveEBVideoView new];  
[self addSubview:_remoteVideoView];  

_remoteVideoView2.liveEBURL = liveEBURL;  
_remoteVideoView2.rtcHost = rtcHost;

eg:
 rtcHost = @"webrtc.liveplay.myqcloud.com";  
 liveEBURL= @"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a";  

### 3> 获取LiveEBVideoViewControllerDelegate 进行播放控制
_controlDelegate = _remoteVideoView;

   -(void)start;  //开始播放  
    -(void)stop;  //结束播放  
 
### 4 释放sdk.
-(void)finitSDK;


