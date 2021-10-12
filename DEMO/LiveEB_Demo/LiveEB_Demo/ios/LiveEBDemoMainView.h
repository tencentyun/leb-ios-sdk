#import <UIKit/UIKit.h>

@class LiveEBMainView;

@protocol LiveEBDemoMainViewDelegate <NSObject>
- (void)mainView:(LiveEBMainView *)mainView isOffical:(BOOL)isOffical;
- (void)mainView:(LiveEBMainView *)mainView didInputRoom:(NSString *)url didInputHost:(NSString *)didInputHost isLoopback:(BOOL)isLoopback isPush:(BOOL)isPush;
- (void)mainViewDidToggleAudioLoop:(LiveEBMainView *)mainView;

@end

// The main view of AppRTCMobile. It contains an input field for entering a room
// name on apprtc to connect to.
@interface LiveEBDemoMainView : UIView

@property(nonatomic, weak) id<LiveEBDemoMainViewDelegate> delegate;
// Updates the audio loop button as needed.
@property(nonatomic, assign) BOOL isAudioLoopPlaying;

@end
