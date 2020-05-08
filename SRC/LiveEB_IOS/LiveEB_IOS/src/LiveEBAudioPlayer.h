//
//  LiveEBAudioPlayer.h
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveEBAudioPlayer : NSObject

@property(nonatomic, assign) BOOL isAudioLoopPlaying;

-(void) loadPlayer;
- (void)restartAudioPlayerIfNeeded;

-(void)play;
-(void)stop;
-(void)audioLoop;
-(void)finished;
@end

NS_ASSUME_NONNULL_END
