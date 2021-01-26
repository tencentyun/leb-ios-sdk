//
//  LiveEBDebugView.h
//  LiveEBDebugView
//
//  Created by lusty on 2021/1/20.
//
#import "LiveEBDemoMainView.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveEBDebugView : UIView


@property(nonatomic, weak) id<LiveEBDemoMainViewDelegate> delegate;
// Updates the audio loop button as needed.
@property(nonatomic, assign) BOOL isAudioLoopPlaying;

@end

NS_ASSUME_NONNULL_END
