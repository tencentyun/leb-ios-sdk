//
//  LiveEBVideoView.m
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import "LiveEBVideoView.h"
#import "LiveEBManager.h"

#import "ARDAppClient.h"

#import <WebRTC/RTCEAGLVideoView.h>
#if defined(RTC_SUPPORTS_METAL)
#import <WebRTC/RTCMTLVideoView.h>
#endif

#import "ARDSettingsModel.h"
#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import "LiveEBAudioPlayer.h"

@interface LiveEBVideoView() <RTCVideoViewDelegate,
                                ARDAppClientDelegate,
//                                LiveEBDemoVideoCallViewDelegate,
                                RTCAudioSessionDelegate
>
{
    CGSize _remoteVideoSize;
    
    ARDAppClient *_client;
//    RTCVideoTrack *_remoteVideoTrack;
}



@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@property(nonatomic, strong) LiveEBAudioPlayer* audioPlayer;
@end

@implementation LiveEBVideoView
{
//    RTCVideoTrack *_remoteVideoTrack;
    
     BOOL _useLiveEventBroadcasting;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //#undef RTC_SUPPORTS_METAL
        #if defined(RTC_SUPPORTS_METAL)
            RTCMTLVideoView *remoteView = [[RTCMTLVideoView alloc] initWithFrame:CGRectZero];
            remoteView.delegate = self;
        #else
            RTCEAGLVideoView *remoteView = [[RTCEAGLVideoView alloc] initWithFrame:CGRectZero];
            remoteView.delegate = self;
        #endif
        
        
        _remoteVideoView = remoteView;
        
        
//        bringSubview(toFront: childView)
        
        
        [self addSubview:_remoteVideoView];
//        [self bringSubviewToFront:_remoteVideoView];
    }
    return self;
}

- (void)setRtcHost:(NSString *)rtcHost {
    _client.rtcHost = rtcHost;
}

- (void)setLiveEBURL:(NSString *)liveEBURL {
    _audioPlayer = [LiveEBAudioPlayer new];
    
    [_audioPlayer loadPlayer];
    
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
    _client = [[ARDAppClient alloc] initWithDelegate:self];
    _client.clientInfo = [LiveEBManager sharedManager].clientInfo;
    _client.sessionid = _sessionid;
    
    //             if (useLiveEventBroadcasting) {
         _useLiveEventBroadcasting = YES;
         [_client useLiveBroadcasting:liveEBURL];
    //             }

     
    [_client initWithSettings:settingsModel isLoopback:NO];
    
    
      RTCAudioSession *session = [RTCAudioSession sharedInstance];
      [session addDelegate:self];
        
       
}


- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    _remoteVideoView.frame = bounds;

             NSLog(@"_remoteVideoView[ %f %f] x=%f y=%f width=%f height=%f _remoteVideoSize:%f %f ",
               _remoteVideoView.center.x, _remoteVideoView.center.y, _remoteVideoView.frame.origin.x, _remoteVideoView.frame.origin.y, _remoteVideoView.frame.size.width, _remoteVideoView.frame.size.height
                   ,_remoteVideoSize.width, _remoteVideoSize.height);
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _remoteVideoView) {
    _remoteVideoSize = size;
  }

  [_delegate videoView:self didChangeVideoSize:size];
    
//  [self setNeedsLayout];
}


#pragma mark - Private

- (void)onRouteChange:(id)sender {
//  [_delegate videoCallViewDidChangeRoute:self];
}

- (void)onHangup:(id)sender {
//  [_delegate videoCallViewDidHangup:self];
}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
//  [_delegate videoCallViewDidEnableStats:self];
}


- (NSString *)statusTextForState:(RTCIceConnectionState)state {
  switch (state) {
    case RTCIceConnectionStateNew:
    case RTCIceConnectionStateChecking:
      return @"Connecting...";
    case RTCIceConnectionStateConnected:
    case RTCIceConnectionStateCompleted:
    case RTCIceConnectionStateFailed:
    case RTCIceConnectionStateDisconnected:
    case RTCIceConnectionStateClosed:
    case RTCIceConnectionStateCount:
      return nil;
  }
}

#pragma mark - ARDAppClientDelegate

- (void)appClient:(ARDAppClient *)client
    didChangeState:(ARDAppClientState)state {
  switch (state) {
    case kARDAppClientStateConnected:
      RTCLog(@"Client connected.");
      break;
    case kARDAppClientStateConnecting:
      RTCLog(@"Client connecting.");
      break;
    case kARDAppClientStateDisconnected:
      RTCLog(@"Client disconnected.");
//      [self hangup];
      break;
  }
}

- (void)appClient:(ARDAppClient *)client
    didChangeConnectionState:(RTCIceConnectionState)state {
  RTCLog(@"ICE state changed: %ld", (long)state);
  __weak LiveEBVideoView *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    LiveEBVideoView *strongSelf = weakSelf;
  });
    
     
}

- (void)appClient:(ARDAppClient *)client
    didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
}

- (void)appClient:(ARDAppClient *)client
    didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
  self.remoteVideoTrack = remoteVideoTrack;
}

- (void)appClient:(ARDAppClient *)client
      didGetStats:(NSArray *)stats {
    
    [_delegate showStats:self stat:stats];

}

- (void)appClient:(ARDAppClient *)client
         didError:(NSError *)error {

}

#pragma mark - LiveEBVideoViewControllerDelegate

-(void)start {
    if (_useLiveEventBroadcasting) {
               [_client connectLiveBroadcast];
           }
}

-(void)stop {
    [_audioPlayer finished];
    [_client disconnect];
}

-(void)setStat {
    _client.shouldGetStats = YES;
}


- (void)setRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
  if (_remoteVideoTrack == remoteVideoTrack) {
    return;
  }
  [_remoteVideoTrack removeRenderer:_remoteVideoView];
  _remoteVideoTrack = nil;
  [_remoteVideoView renderFrame:nil];
  _remoteVideoTrack = remoteVideoTrack;
  [_remoteVideoTrack addRenderer:_remoteVideoView];
}
@end
