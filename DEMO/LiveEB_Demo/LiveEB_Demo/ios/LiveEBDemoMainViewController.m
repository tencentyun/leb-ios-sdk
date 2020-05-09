#import "LiveEBDemoMainViewController.h"

#import <AVFoundation/AVFoundation.h>

#import <LiveEB_IOS/LiveEB_IOS.h>


#import "LiveEBDemoMainView.h"
#import "LiveEBDemoVideoCallViewController.h"

static NSString *const barButtonImageString = @"ic_settings_black_24dp.png";

// Launch argument to be passed to indicate that the app should start loopback immediatly
static NSString *const loopbackLaunchProcessArgument = @"loopback";

@interface LiveEBDemoMainViewController () <
    LiveEBDemoMainViewDelegate,
    LiveEBDemoVideoCallViewControllerDelegate
>

@property(nonatomic, strong) LiveEBDemoMainView *mainView;

@end

@implementation LiveEBDemoMainViewController {
  BOOL _useManualAudio;
}

@synthesize mainView = _mainView;
//@synthesize audioPlayer = _audioPlayer;

- (void)viewDidLoad {
  [super viewDidLoad];
  if ([[[NSProcessInfo processInfo] arguments] containsObject:loopbackLaunchProcessArgument]) {
    [self mainView:nil didInputRoom:@"" isLoopback:YES];
  }
}

- (void)loadView {
  self.title = @"xbright Live Event Broadcasting";
  _mainView = [[LiveEBDemoMainView alloc] initWithFrame:CGRectZero];
  _mainView.delegate = self;
  self.view = _mainView;
}

+ (NSString *)loopbackRoomString {
  NSString *loopbackRoomString =
      [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
  return loopbackRoomString;
}

#pragma mark - ARDMainViewDelegate

- (void)mainView:(LiveEBDemoMainView *)mainView didInputRoom:(NSString *)liveUrl isLoopback:(BOOL)isLoopback {
    BOOL useLiveEventBroadcasting = YES;
    NSString *rtcHost = NULL;
  if (!liveUrl.length) {
      liveUrl=@"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a";
      
      
    useLiveEventBroadcasting = YES;
  }
    
    
    if ([liveUrl rangeOfString:@"liveplay.now.qq.com" ].location != NSNotFound) {
        rtcHost = @"live.rtc.qq.com";
    } else if ([liveUrl rangeOfString:@"webrtc.liveplay.myqcloud.com" ].location != NSNotFound) {
        rtcHost = @"webrtc.liveplay.myqcloud.com";
    }
  // Trim whitespaces.
  NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceCharacterSet];
  NSString *trimmedRoom = [liveUrl stringByTrimmingCharactersInSet:whitespaceSet];

    if (!useLiveEventBroadcasting) {
        // Check that room name is valid.
        NSError *error = nil;
        NSRegularExpressionOptions options = NSRegularExpressionCaseInsensitive;
        NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:@"\\w+"
                                                      options:options
                                                        error:&error];
        if (error) {
          [self showAlertWithMessage:error.localizedDescription];
          return;
        }
        NSRange matchRange =
            [regex rangeOfFirstMatchInString:liveUrl
                                     options:0
                                       range:NSMakeRange(0, trimmedRoom.length)];
        if (matchRange.location == NSNotFound ||
            matchRange.length != trimmedRoom.length) {
          [self showAlertWithMessage:@"Invalid room name."];
          return;
        }
    }
  
  LiveEBDemoVideoCallViewController *videoCallViewController =
      [[LiveEBDemoVideoCallViewController alloc] initForRoom:trimmedRoom
                                            rtcHost:rtcHost
                                           isLoopback:isLoopback
                                           useLiveEventBroadcasting:useLiveEventBroadcasting
                                             delegate:self];
  videoCallViewController.modalTransitionStyle =
      UIModalTransitionStyleFlipHorizontal;
  [self presentViewController:videoCallViewController
                     animated:YES
                   completion:nil];
}

#pragma mark - LiveEBDemoVideoCallViewControllerDelegate

- (void)viewControllerDidFinish:(LiveEBDemoVideoCallViewController *)viewController {
  if (![viewController isBeingDismissed]) {
    NSLog(@"Dismissing VC");
    [self dismissViewControllerAnimated:YES completion:^{
      [self restartAudioPlayerIfNeeded];
    }];
  }
NSLog(@"Dismissing VC");
//     [_audioPlayer finished];
}

#pragma mark - Private

- (void)presentViewControllerAsModal:(UIViewController *)viewController {
  [self presentViewController:viewController animated:YES completion:nil];
}

- (void)restartAudioPlayerIfNeeded {
    
//    [_audioPlayer restartAudioPlayerIfNeeded];
    
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
