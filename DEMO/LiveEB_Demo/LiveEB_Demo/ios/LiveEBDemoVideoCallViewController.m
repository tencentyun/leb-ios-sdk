
#import "LiveEBDemoVideoCallViewController.h"
#import <LiveEB_IOS/LiveEB_IOS.h>

#import "LiveEBDemoVideoCallView.h"

@interface LiveEBDemoVideoCallViewController () < LiveEBDemoVideoCallViewDelegate >
@property(nonatomic, readonly) LiveEBDemoVideoCallView *videoCallView;
 
@end

@implementation LiveEBDemoVideoCallViewController {

    BOOL _useLiveEventBroadcasting;
    NSString *_liveUrl;
    NSString *_rtcHost;
    
    BOOL _isSetStatState;
  BOOL _isPaused;
  
  BOOL _isPush;
  NSString *_pushURL;
}

@synthesize videoCallView = _videoCallView;
@synthesize delegate = _delegate;

- (instancetype)initForRoom:(NSString *)liveUrl
                    rtcHost:(NSString *)rtcHost
                 isLoopback:(BOOL)isLoopback
                 useLiveEventBroadcasting:(BOOL)useLiveEventBroadcasting
                   delegate:(id<LiveEBDemoVideoCallViewControllerDelegate>)delegate {
  if (self = [super init]) {
   
    _delegate = delegate;
    _liveUrl = liveUrl;
    _rtcHost = rtcHost;
      
    _isSetStatState = FALSE;
    
    _isPaused = false;

  }
  return self;
}


- (instancetype)initForPushRoom:(NSString *)pushUrl
                     rtcHost:(NSString *)rtcHost
                    delegate:(id<LiveEBDemoVideoCallViewControllerDelegate>)delegate {
  if (self = [self init]) {
    _isPush = TRUE;
    _pushURL = pushUrl;
    _rtcHost = rtcHost;
    _delegate = delegate;
  }
  
  return self;
}

- (void)loadView {
  _videoCallView = [[LiveEBDemoVideoCallView alloc] initWithFrame:CGRectZero isPush:_isPush];
  _videoCallView.delegate = self;
  if (!_isPush) {
    _videoCallView.liveEBURL = _liveUrl;
  } else {
    [_videoCallView setStreamURL:_pushURL isPush:YES];
  }
    
  _videoCallView.rtcHost = _rtcHost;
  _controlDelegate = _videoCallView.controlDelegate;
    
  [_controlDelegate setStatState:true];
  // [_controlDelegate setAudioMute:YES];
  self.view = _videoCallView;
    
    
  [_controlDelegate start];
  //[_controlDelegate start];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

#pragma mark - LiveEBDemoVideoCallViewDelegate

- (void)videoCallViewDidHangup:(LiveEBDemoVideoCallView *)view {
  [_controlDelegate stop];

  [self hangup];
}

- (void)videoCallViewDidstop:(LiveEBDemoVideoCallView *)view {
     [_controlDelegate stop];
}

- (void)videoCallViewDidPauseResume:(LiveEBDemoVideoCallView *)view {
  
  if (_isPaused) {
    [_controlDelegate resume];
  } else {
    [_controlDelegate pause];
  }
  
  
  _isPaused = !_isPaused;
}

-(NSString*)getSavePath {
  NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentPath = [path firstObject];
  NSString *defaultPath = [documentPath stringByAppendingPathComponent:@"IMG"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager createDirectoryAtPath:defaultPath withIntermediateDirectories:NO attributes:nil error:nil];
  
  return defaultPath;
}

- (void)onCapture {
  static int index = 0;
  UIImage* pic = [_controlDelegate captureVideoFrame];
  if (pic != NULL) {
    NSString *filePath = [[self getSavePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/img_%d.png", index++]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      BOOL wy = [UIImagePNGRepresentation(pic) writeToFile:filePath atomically:YES];
      
      NSLog(@"write file wy %d", wy);
    });
    
  }
}

- (void)videoCallViewDidRestart:(LiveEBDemoVideoCallView *)view {
    [_controlDelegate restart];
}

- (void)videoCallViewDidEnableStats:(LiveEBDemoVideoCallView *)view {
    
    _isSetStatState = !_isSetStatState;
    [_controlDelegate setStatState:_isSetStatState];
    view.statsView.hidden = !_isSetStatState;
}

#pragma mark - RTCAudioSessionDelegate

#pragma mark - Private

- (void)hangup {
    [_delegate viewControllerDidFinish:self];
}

- (void)showAlertWithMessage:(NSString*)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:nil
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                        }];

  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
}

@end
