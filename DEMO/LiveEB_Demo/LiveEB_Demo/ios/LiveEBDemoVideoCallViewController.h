#import <UIKit/UIKit.h>
#import <LiveEB_IOS/LiveEB_IOS.h>


@class LiveEBDemoVideoCallViewController;
@protocol LiveEBDemoVideoCallViewControllerDelegate <NSObject>

- (void)viewControllerDidFinish:(LiveEBDemoVideoCallViewController *)viewController;

@end

@interface LiveEBDemoVideoCallViewController : UIViewController

@property(nonatomic, weak) id<LiveEBDemoVideoCallViewControllerDelegate> delegate;

@property(nonatomic, weak) id<LiveEBVideoViewControllerDelegate> controlDelegate;

- (instancetype)initForRoom:(NSString *)liveUrl
                 isLoopback:(BOOL)isLoopback
                 useLiveEventBroadcasting:(BOOL)useLiveEventBroadcasting
                   delegate:(id<LiveEBDemoVideoCallViewControllerDelegate>)delegate;
@end
