//
//  WebRtcView.m
//  WRTCDemo
//
//  Created by AlexiChen on 2020/6/30.
//  Copyright © 2020 AlexiChen. All rights reserved.
//

#import "WebRtcView.h"



@implementation WebRtcView

- (void)dealloc
{
    NSLog(@"%p | %p release", self, _videoView);
}

//- (BOOL)startWebRtc:(NSString *)qurl{
//    BOOL playwrtc = NO;
//    if ([qurl.lowercaseString hasPrefix:@"webrtc://"]) {
//        _videoView.liveEBURL = qurl;
//        [_videoView start];
//        [_videoView setStatState:YES];
//        playwrtc = YES;
//    }
//
//    return playwrtc;
//}
//
//- (BOOL)stopWebRtc {
//    [_videoView stop];
//    return YES;
//}

- (void)setVideoSize:(CGSize)videoSize {
    _videoSize = videoSize;
    [self setNeedsLayout];
}

- (void)onPlayStop:(UIButton *)btn {
    if (btn.selected) {
        [_videoView stop];
    } else {
        [_videoView start];
    }
    btn.selected = !btn.selected;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _videoView = [[LiveEBVideoView alloc] init];
        [self addSubview:_videoView];
        
        self.backgroundColor = [UIColor colorWithRed:(arc4random()%50 + 50)/100.0 green:(arc4random()%50 + 50)/100.0 blue:(arc4random()%50 + 50)/100.0 alpha:1];
        
        
        _playButton = [[UIButton alloc] init];
        [_playButton setBackgroundColor:[UIColor orangeColor]];
        [_playButton setTitle:@"开始" forState:UIControlStateNormal];
        [_playButton setTitle:@"停止" forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(onPlayStop:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    return self;
}

- (instancetype)initWith:(NSString *)qurl {
    if (self = [self initWithFrame:CGRectZero]) {
        _videoView.liveEBURL = qurl;
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    if (_videoSize.width > 0 && _videoSize.height > 0) {
        // Aspect fill remote video into bounds.
        CGRect remoteVideoFrame = AVMakeRectWithAspectRatioInsideRect(_videoSize, bounds);
        _videoView.frame = remoteVideoFrame;
        _videoView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
        _videoView.frame = CGRectInset(bounds, 0, bounds.size.height/6);
    }
    
    _playButton.frame = CGRectInset(bounds, (bounds.size.width - 40)/2, (bounds.size.height - 40)/2);
    
    
}
#pragma LiveEBVideoViewDelegate
- (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error {
    NSLog(@"didError : %p, %@", videoView, error);
}

- (void)showStats:(LiveEBVideoView *)videoView stat:(NSArray*)stat {
//    NSLog(@"LiveEBVideoView : =====>>>>>  %@",stat);
}

- (void)showStats:(LiveEBVideoView *)videoView strStat:(nonnull NSString *)strStat {
    NSLog(@"showStats : %p, %@", videoView, strStat);
}

- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size {
    if (videoView == _videoView) {
        self.videoSize = size;
    }
    NSLog(@"didChangeVideoSize : %p, %@", videoView, NSStringFromCGSize(size));
}

- (void)onPrepared:(LiveEBVideoView*)videoView {
    NSLog(@"onPrepared : %p", videoView);
    
}


//尽量不要在onCompletion里重试。
- (void)onCompletion:(LiveEBVideoView*)videoView {
    NSLog(@"onCompletion : %p", videoView);
    
}

-(void)onFirstFrameRender:(LiveEBVideoView *)videoView {
    NSLog(@"onFirstFrameRender : %p", videoView);
}


@end
