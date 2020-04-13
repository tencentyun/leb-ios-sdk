#import <UIKit/UIKit.h>


#import <LiveEB_IOS/LiveEB_IOS.h>

@class LiveEBDemoVideoCallView;
@protocol LiveEBDemoVideoCallViewDelegate <NSObject>

// Called when the route change button is pressed.
- (void)videoCallViewDidChangeRoute:(LiveEBDemoVideoCallView *)view;

// Called when the hangup button is pressed.
- (void)videoCallViewDidHangup:(LiveEBDemoVideoCallView *)view;

// Called when stats are enabled by triple tapping.
- (void)videoCallViewDidEnableStats:(LiveEBDemoVideoCallView *)view;

@end

// Video call view that shows local and remote video, provides a label to
// display status, and also a hangup button.
@interface LiveEBDemoVideoCallView : UIView

@property(nonatomic, readonly) UILabel *statusLabel;
@property(nonatomic, weak) id<LiveEBDemoVideoCallViewDelegate> delegate;




@property(nonatomic, weak) id<LiveEBVideoViewControllerDelegate> controlDelegate;
@property (nonatomic, copy) NSString *liveEBURL;

@end
