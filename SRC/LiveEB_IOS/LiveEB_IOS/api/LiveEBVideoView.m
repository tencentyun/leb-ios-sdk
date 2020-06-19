//
//  LiveEBVideoView.m
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import "LiveEBVideoView.h"
#import "LiveEBManager.h"

#import "LiveEBAppClient.h"

#import <WebRTC/RTCEAGLVideoView.h>
#if defined(RTC_SUPPORTS_METAL)
#import <WebRTC/RTCMTLVideoView.h>
#endif

#import "ARDStatsBuilder.h"
#import "ARDSettingsModel.h"
#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/WebRTC.h>
#import <WebRTC/RTCMediaConstraints.h>
#import "LiveEBAudioPlayer.h"

#import <WebRTC/RTCLegacyStatsReport.h>

@interface LiveEBVideoView() <RTCVideoViewDelegate,
                                LiveEBAppClientDelegate,
                                RTCAudioSessionDelegate
>
{
    CGSize _remoteVideoSize;
    
    LiveEBAppClient *_client;
  
    int _currConnectRetryCount;
    BOOL _isStringRetryConnect;
}



@property(nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property(nonatomic, strong) RTCAudioTrack *remoteAudioTrack;
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@property(nonatomic, strong) LiveEBAudioPlayer* audioPlayer;
@property(nonatomic, assign) BOOL audioTrackEnable;

@property(nonatomic, assign) BOOL isRTCPlaying;
@end

@implementation LiveEBVideoView
{
//    RTCVideoTrack *_remoteVideoTrack;
    
     BOOL _useLiveEventBroadcasting;
    
    ARDStatsBuilder *_statsBuilder;
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
        _audioTrackEnable = YES;
        
        _isStringRetryConnect = FALSE;
        self->_currConnectRetryCount = 0;
      
        _statsBuilder = [[ARDStatsBuilder alloc] init];
            
        
        [self addSubview:_remoteVideoView];
    }
    return self;
}

- (void)setRtcHost:(NSString *)rtcHost {
    _client.rtcHost = rtcHost;
}

- (void)setLiveEBURL:(NSString *)liveEBURL {
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
    _client = [[LiveEBAppClient alloc] initWithDelegate:self];
    _client.clientInfo = [LiveEBManager sharedManager].clientInfo;
    _client.sessionid = _sessionid;
    
   _useLiveEventBroadcasting = YES;
   [_client useLiveBroadcasting:liveEBURL];

     
    [_client initWithSettings:settingsModel isLoopback:NO];
}


- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    _remoteVideoView.frame = bounds;

             NSLog(@"LiveEB view [ %f %f] x=%f y=%f width=%f height=%f _remoteVideoSize:%f %f ",
                   _remoteVideoView.center.x, _remoteVideoView.center.y, _remoteVideoView.frame.origin.x,
                   _remoteVideoView.frame.origin.y, _remoteVideoView.frame.size.width,
                   _remoteVideoView.frame.size.height ,_remoteVideoSize.width, _remoteVideoSize.height);
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _remoteVideoView) {
    _remoteVideoSize = size;
  }

  [_delegate videoView:self didChangeVideoSize:size];
}

- (void)videoView:(id<RTCVideoRenderer>)videoView isFirstFrame:(BOOL)isfirstFrame {
  if ([_delegate respondsToSelector:@selector(onFirstFrameRender:)]) {
      [_delegate onFirstFrameRender:self];
  }
}

#pragma mark - Private

- (void)onRouteChange:(id)sender {
}

- (void)onHangup:(id)sender {
}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
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

- (void)appClient:(LiveEBAppClient *)client
    didChangeState:(LiveEBClientState)state {
  RTCLog(@"LiveEB view Client  state:.%ld" , (long)state);
  
  switch (state) {
    case kLiveEBClientStateConnected:
          RTCLog(@"Client connected.");
          if (_delegate && [_delegate respondsToSelector:@selector(onPrepared:)]) {
              [_delegate onPrepared:self];
          }
      
      _isRTCPlaying = false;
      break;
      
    case kLiveEBClientStateConnecting:
      RTCLog(@"LiveEB view Client connecting.");
      
      _isRTCPlaying = false;
      break;
      
    case kLiveEBClientStatePlaying:
      RTCLog(@"LiveEB view Client playing.");
      
      _isRTCPlaying = true;
      _isStringRetryConnect = FALSE;
      self->_currConnectRetryCount = 0;
      break;
      
    case kLiveEBClientStateDisconnected:
      RTCLog(@"LiveEB view Client disconnected.");
      
      _isRTCPlaying = false;
      
      @synchronized (self) {
        if (!_isStringRetryConnect && self->_currConnectRetryCount == 0) {
          _isStringRetryConnect = true;
        } else if (self->_currConnectRetryCount >= [LiveEBManager sharedManager].connectRetryCount) {
          if (self.delegate && [self.delegate respondsToSelector:@selector(onCompletion:)]) {
              [self.delegate onCompletion:self];
          }
          
          _isStringRetryConnect = FALSE;
        }
        
        if (!_isStringRetryConnect) {
          break;
        }
        
        self->_currConnectRetryCount++;
      }

      {
        __weak LiveEBVideoView *weakSelf = self;
        void (^_sendMsg)(void) = ^() {
          
          LiveEBVideoView *strongSelf = weakSelf;
          if (!strongSelf) {
              return;
          }
          
          //[strongSelf restart];
          @synchronized(strongSelf) {
            [strongSelf stop];
            [strongSelf start];
          }
        };
        
       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [LiveEBManager sharedManager].connectRetryCount
                                    * [LiveEBManager sharedManager].connectRetryInterval * NSEC_PER_SEC),
                                    dispatch_get_main_queue(), _sendMsg);
      }
      break;
      
    case kLiveEBClientStateClosed: {
      
      @synchronized (self) {
        if (!self->_isStringRetryConnect) {
          if (self.delegate && [self.delegate respondsToSelector:@selector(onCompletion:)]) {
              [self.delegate onCompletion:self];
          }
        } else {
          dispatch_async(dispatch_get_main_queue(), ^{

            [self appClient:client didChangeState:kLiveEBClientStateDisconnected];
          });
        }
      }
//      NSString *domain = @"com.liveeb.rtc.ErrorDomain";
//      NSString *desc = NSLocalizedString(@"Peer Connection state failed.", @"");
//      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
//
//      [self.delegate videoView:self didError:[NSError errorWithDomain:domain code:-101 userInfo:userInfo]];
      _isRTCPlaying = false;
    }
      
      break;
  }
}

- (void)appClient:(LiveEBAppClient *)client
    didChangeConnectionState:(RTCIceConnectionState)state {
  RTCLog(@"LiveEB view ICE state changed: %ld", (long)state);
  __weak LiveEBVideoView *weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    LiveEBVideoView *strongSelf = weakSelf;
  });
    
     
}

- (void)appClient:(LiveEBAppClient *)client
    didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack {
}

- (void)appClient:(LiveEBAppClient *)client
    didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack {
  self.remoteVideoTrack = remoteVideoTrack;
}

- (void)appClient:(LiveEBAppClient *)client
    didReceiveRemoteAudioTrack:(RTCAudioTrack *)remoteAudioTrack {
  self.remoteAudioTrack = remoteAudioTrack;
    
    remoteAudioTrack.isEnabled = _audioTrackEnable;
}

- (void)appClient:(LiveEBAppClient *)client
      didGetStats:(NSArray *)stats {
    
    if (_delegate && [_delegate respondsToSelector:@selector(showStats:strStat:)]) {
    //if (!_delegate && [_delegate respondsToSelector:NSSelectorFromString(@"showStats:stat:")]) {
        if (_statsBuilder != NULL) {
            for (RTCLegacyStatsReport *report in stats) {
              [_statsBuilder parseStatsReport:report];
            }
            
            [_delegate showStats:self strStat:_statsBuilder.statsString];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(showStats:stat:)]) {
        [_delegate showStats:self stat:stats];
    }
}

- (void)appClient:(LiveEBAppClient *)client
         didError:(NSError *)error {
  [self.delegate videoView:self didError:error];
}

#pragma mark - LiveEBVideoViewControllerDelegate

-(void)start {
  @synchronized(self) {
    RTCLog("LiveEB view start");
    
    _audioPlayer = [LiveEBAudioPlayer new];
     
     [_audioPlayer loadPlayer];
     
     RTCAudioSession *session = [RTCAudioSession sharedInstance];
     [session addDelegate:self];
     
     if (_useLiveEventBroadcasting) {
         [_client connectLiveBroadcast];
      }
  }
}

-(void)stop {
//  RTCAudioSession *session = [RTCAudioSession sharedInstance];
//  [session addDelegate:nil];
  @synchronized(self) {
    RTCLog("LiveEB view stop");
    
    [_audioPlayer finished];

    [_client disconnect];
  }
}


- (void)pause {
  RTCLog("LiveEB view pause");
  
  @synchronized(self) {
    [_remoteVideoView pause:TRUE];
    if (_remoteAudioTrack) {
        _remoteAudioTrack.isEnabled = FALSE;
    }
  }
}

- (void)restart {
  RTCLog("LiveEB view restart");
  
  @synchronized(self) {
    if (!_isStringRetryConnect) {
      //开始重试
      _isStringRetryConnect = TRUE;
      self->_currConnectRetryCount = 0;
      
      [self stop];
      [self start];
      
    } else {
      //重新开始重试
      self->_currConnectRetryCount = 0;
      _isStringRetryConnect = TRUE;
    }
  }
}

- (void)resume {
  @synchronized(self) {
    [_remoteVideoView pause:FALSE];
    
    if (_remoteAudioTrack) {
        _remoteAudioTrack.isEnabled = TRUE;
    }
  }
}

- (BOOL)isPlaying {
  return _isRTCPlaying && _remoteAudioTrack.isEnabled;
}

-(void)setStatState:(BOOL)stat {
    _client.shouldGetStats = stat;
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

- (void)setAudioMute:(BOOL)mute {
    _audioTrackEnable = !mute;
    
    if (_remoteAudioTrack) {
        _remoteAudioTrack.isEnabled = !mute;
    }
}
@end
