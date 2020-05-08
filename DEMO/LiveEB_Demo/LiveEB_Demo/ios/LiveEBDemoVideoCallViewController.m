
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

  }
  return self;
}

- (void)loadView {
  _videoCallView = [[LiveEBDemoVideoCallView alloc] initWithFrame:CGRectZero];
  _videoCallView.delegate = self;
    _videoCallView.liveEBURL =_liveUrl;
    _videoCallView.rtcHost = _rtcHost;
    _controlDelegate = _videoCallView.controlDelegate;
  self.view = _videoCallView;
    
    
    [_controlDelegate start];

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}

#pragma mark - LiveEBDemoVideoCallViewDelegate

- (void)videoCallViewDidHangup:(LiveEBDemoVideoCallView *)view {
  [self hangup];
}

#pragma mark - RTCAudioSessionDelegate

#pragma mark - Private

- (void)hangup {
    [_controlDelegate stop];
    
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
