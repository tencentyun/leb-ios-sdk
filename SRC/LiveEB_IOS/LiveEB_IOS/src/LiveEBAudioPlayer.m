//
//  LiveEBAudioPlayer.m
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import "LiveEBAudioPlayer.h"
#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCAudioSessionConfiguration.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import "ARDSettingsModel.h"


@interface LiveEBAudioPlayer() <RTCAudioSessionDelegate>

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;



@end

@implementation LiveEBAudioPlayer

-(void) loadPlayer {
    RTCAudioSessionConfiguration *webRTCConfig =
        [RTCAudioSessionConfiguration webRTCConfiguration];
    webRTCConfig.categoryOptions = webRTCConfig.categoryOptions |
        AVAudioSessionCategoryOptionDefaultToSpeaker;
    [RTCAudioSessionConfiguration setWebRTCConfiguration:webRTCConfig];

    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    [session addDelegate:self];

    [self configureAudioSession];
    [self setupAudioPlayer];
    
    
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];

    RTCAudioSession *audiosession = [RTCAudioSession sharedInstance];
    audiosession.useManualAudio = [settingsModel currentUseManualAudioConfigSettingFromStore];
    audiosession.isAudioEnabled = NO;
}

- (void)configureAudioSession {
  RTCAudioSessionConfiguration *configuration =
  [[RTCAudioSessionConfiguration alloc] init];
    
  configuration.category = AVAudioSessionCategoryAmbient;
  configuration.categoryOptions = AVAudioSessionCategoryOptionDuckOthers;
  configuration.mode = AVAudioSessionModeDefault;

  RTCAudioSession *session = [RTCAudioSession sharedInstance];
  [session lockForConfiguration];
  [session addDelegate:self];
    
  BOOL hasSucceeded = NO;
  NSError *error = nil;
  if (session.isActive) {
    hasSucceeded = [session setConfiguration:configuration error:&error];
  } else {
    hasSucceeded = [session setConfiguration:configuration
                                      active:YES
                                       error:&error];
  }
  if (!hasSucceeded) {
    RTCLogError(@"Error setting configuration: %@", error.localizedDescription);
  }
  [session unlockForConfiguration];
}


- (void)setupAudioPlayer {
  NSString *audioFilePath =
      [[NSBundle mainBundle] pathForResource:@"mozart" ofType:@"mp3"];
  NSURL *audioFileURL = [NSURL URLWithString:audioFilePath];
  _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL
                                                        error:nil];
  _audioPlayer.numberOfLoops = -1;
  _audioPlayer.volume = 1.0;
  [_audioPlayer prepareToPlay];
}

- (void)restartAudioPlayerIfNeeded {
  [self configureAudioSession];
    
  if (_isAudioLoopPlaying /*&& !self.presentedViewController*/) {
    RTCLog(@"Starting audio loop due to WebRTC end.");
    [_audioPlayer play];
  }
}


#pragma mark - RTCAudioSessionDelegate

- (void)audioSessionDidStartPlayOrRecord:(RTCAudioSession *)session {
  // Stop playback on main queue and then configure WebRTC.
  [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeMain
                               block:^{
                                 if (self.isAudioLoopPlaying) {
                                   RTCLog(@"Stopping audio loop due to WebRTC start.");
                                   [self.audioPlayer stop];
                                 }
                                 RTCLog(@"Setting isAudioEnabled to YES.");
                                 session.isAudioEnabled = YES;
                               }];
}

- (void)audioSessionDidStopPlayOrRecord:(RTCAudioSession *)session {
  // WebRTC is done with the audio session. Restart playback.
  [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeMain
                               block:^{
    RTCLog(@"audioSessionDidStopPlayOrRecord");
    [self restartAudioPlayerIfNeeded];
  }];
}



-(void)play {
    
}

-(void)stop {
    
}

-(void)audioLoop {
    if (_isAudioLoopPlaying) {
      [_audioPlayer stop];
    } else {
      [_audioPlayer play];
    }
    
    _isAudioLoopPlaying = _audioPlayer.playing;
}

- (void)finished {
    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    session.isAudioEnabled = NO;
}
@end
