# LiveEB_IOS
快直播 LEB （超低延迟直播） IOS SDK https://cloud.tencent.com/product/leb

live event Broadcasting
 pod 'LiveEB_IOS', :git=>'https://github.com/tencentyun/leb-ios-sdk.git' , :tag => '1.0.1'

支持平台
SDK支持IOS 9.0以上系统

开发环境
xcode10及以上环境


Xcode工程设置
1> pod依赖framework。后续会把sdk代码提交，也可以依赖code。设置bitcode为false.

eg:

source 'https://github.com/CocoaPods/Specs.git'
target 'LiveEB_Demo' do
 platform :ios, '9.0'
 pod 'LiveEB_IOS', :git=>'https://github.com/tencentyun/leb-ios-sdk.git' , :tag => '1.0.1'
 
end


添加头文件
#import <LiveEB_IOS/LiveEB_IOS.h>

验证
1>  初始化sdk
__weak typeof(self) weakSelf = self;
 [[LiveEBManager sharedManager] initSDK:weakSelf];



2> 创建LiveEBVideoView 用于渲染播放，设置播放url
 _remoteVideoView = [LiveEBVideoView new];
[self addSubview:_remoteVideoView];
     
_remoteVideoView2.liveEBURL = liveEBURL;
eg: webrtc://6721.liveplay.now.qq.com/live/6721_c21f14dc5c3ce1b2513f5810f359ea15?txSecret=c96521895c01742114c033f3cb585339&txTime=5DDE5CBC


3> 获取LiveEBVideoViewControllerDelegate 进行播放控制
_controlDelegate = _remoteVideoView;

   -(void)start;  //开始播放
    -(void)stop;  //结束播放
4 释放sdk.
-(void)finitSDK;


