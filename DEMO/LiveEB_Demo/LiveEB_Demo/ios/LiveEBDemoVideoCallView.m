#import "LiveEBDemoVideoCallView.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImage+LiveEBUtilities.h"
#import "ConvertWAV.h"

static CGFloat const kButtonPadding = 16;
static CGFloat const kButtonSize = 48;
static CGFloat const kLocalVideoViewSize = 120;
static CGFloat const kLocalVideoViewPadding = 8;
static CGFloat const kStatusBarHeight = 20;

@interface LiveEBDemoVideoCallView () <LiveEBVideoViewDelegate>

@property(nonatomic, strong) LiveEBVideoView *remoteVideoView2;

@end

@implementation LiveEBDemoVideoCallView {
  UIButton *_routeChangeButton;
  UIButton *_cameraSwitchButton;
  UIButton *_hangupButton;
  UIButton *_pauseResumeButton;
  UIButton *_restartButton;
  UIButton *_captureButton;
  UIButton *_rotationBtn;
  UIButton *_renderBtn;
  
  CGSize _remoteVideoSize;
  BOOL _isPushView;
}

@synthesize statusLabel = _statusLabel;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame isPush:(BOOL)isPush {
  if (self = [super initWithFrame:frame]) {
      
      self.backgroundColor = [UIColor blackColor];
      // _remoteVideoView2 = [[LiveEBVideoView alloc] init];
      _isPushView  = isPush;
      _remoteVideoView2 = [[LiveEBVideoView alloc] initWithFrame:CGRectZero PushPreview:_isPushView];

      _remoteVideoView2.delegate = self;
      
      
      [self addSubview:_remoteVideoView2];
      
//      [_remoteVideoView2 setRenderRotation:LEBVideoRotation_270];
    
      //_remoteVideoView2.transform = CGAffineTransformMakeRotation(90 *M_PI / 180.0);
      _controlDelegate = _remoteVideoView2;
      UIImage *image;

      _statsView = [[LiveEBDemoStatView alloc] initWithFrame:CGRectMake(0, 0, kLocalVideoViewSize, kLocalVideoViewSize)];
      //_statsView.hidden = YES;

      [self addSubview:_statsView];
      
      if (true) {
        _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hangupButton.backgroundColor = [UIColor redColor];
        _hangupButton.layer.cornerRadius = kButtonSize / 2;
        _hangupButton.layer.masksToBounds = YES;
        image = [UIImage imageForName:@"ic_call_end_black_24dp.png"
                                color:[UIColor whiteColor]];
        [_hangupButton setImage:image forState:UIControlStateNormal];
        [_hangupButton addTarget:self
                          action:@selector(onHangup:)
                forControlEvents:UIControlEventTouchUpInside];
              [self addSubview:_hangupButton];
          
      }
    
    if (true) {
      _pauseResumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _pauseResumeButton.backgroundColor = [UIColor blueColor];
      [_pauseResumeButton setTitle:@"P/R" forState:UIControlStateNormal];
      _pauseResumeButton.layer.cornerRadius = kButtonSize / 2;
      _pauseResumeButton.layer.masksToBounds = YES;
           [_pauseResumeButton addTarget:self
                        action:@selector(onPauseResume:)
              forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_pauseResumeButton];
        
    }
    
    if (true) {
      _restartButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _restartButton.backgroundColor = [UIColor grayColor];
      [_restartButton setTitle:@"RS" forState:UIControlStateNormal];
      _restartButton.layer.cornerRadius = kButtonSize / 2;
      _restartButton.layer.masksToBounds = YES;
           [_restartButton addTarget:self
                        action:@selector(onRestart:)
              forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_restartButton];
        
    }
    
      _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
      _captureButton.backgroundColor = [UIColor grayColor];
      [_captureButton setTitle:@"Cap" forState:UIControlStateNormal];
      _captureButton.layer.cornerRadius = kButtonSize / 2;
      _captureButton.layer.masksToBounds = YES;
           [_captureButton addTarget:self
                        action:@selector(onCapture:)
              forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_captureButton];
        
    
    
    _rotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotationBtn.backgroundColor = [UIColor grayColor];
    _rotationBtn.layer.cornerRadius = kButtonSize / 2;
    _rotationBtn.layer.masksToBounds = YES;
    [_rotationBtn setTitle:@"RA" forState:UIControlStateNormal];
    [_rotationBtn addTarget:self action:@selector(onRotation:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotationBtn];
    
    
    _renderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _renderBtn.backgroundColor = [UIColor grayColor];
    _renderBtn.layer.cornerRadius = kButtonSize / 2;
    _renderBtn.layer.masksToBounds = YES;
    [_renderBtn setTitle:@"RE" forState:UIControlStateNormal];
    [_renderBtn addTarget:self action:@selector(onRenderMode:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_renderBtn];
       
    

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _statusLabel.font = [UIFont fontWithName:@"Roboto" size:16];
    _statusLabel.textColor = [UIColor whiteColor];
    [self addSubview:_statusLabel];

    UITapGestureRecognizer *tapRecognizer =
        [[UITapGestureRecognizer alloc]
            initWithTarget:self
                    action:@selector(didTripleTap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self addGestureRecognizer:tapRecognizer];
  }
  return self;
}


- (void)setRtcHost:(NSString *)rtcHost {
    _remoteVideoView2.rtcHost = rtcHost;
}

-(void)setStreamURL:(NSString*)streamURL isPush:(BOOL)isPush {
  if (isPush) {
    [_remoteVideoView2 setStreamURL:streamURL
                 pullSignalStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/pullstream"
                 stopSignalStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/stopstream"];
  } else {
    [_remoteVideoView2 setLiveURL:streamURL
                       pullStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/pullstream"
                       stopStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/stopstream"];
  }
}

- (void)setLiveEBURL:(NSString *)liveEBURL {
//    _remoteVideoView2.liveEBURL = liveEBURL;
    //_remoteVideoView2.sessionid = @"";
  
 
    [_remoteVideoView2 setLiveURL:liveEBURL
                       pullStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/pullstream"
                       stopStream:@"https://overseas-webrtc.liveplay.myqcloud.com/webrtc/v1/stopstream"];

  
  
  
  
}

- (void)layoutSubviews {
  CGRect bounds = self.bounds;
  LiveEBLogInfo("LiveEB view layoutSubviews x%f %f : w:%f h:%f %f %f",
        bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height, _remoteVideoSize.width, _remoteVideoSize.height);
        
  if (!_isPushView) {
    if (_remoteVideoSize.width > 0 && _remoteVideoSize.height > 0) {
      // Aspect fill remote video into bounds.
      CGRect remoteVideoFrame =
          AVMakeRectWithAspectRatioInsideRect(_remoteVideoSize, bounds);
        
      _remoteVideoView2.frame = remoteVideoFrame;
  //    _remoteVideoView2.center =
  //        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    } else {
      _remoteVideoView2.frame = bounds;
    }

    LiveEBLogInfo("LiveEB view [ %f %f] x=%f y=%f width=%f height=%f _remoteVideoSize:%f %f ",
          _remoteVideoView2.center.x, _remoteVideoView2.center.y, _remoteVideoView2.frame.origin.x,
          _remoteVideoView2.frame.origin.y, _remoteVideoView2.frame.size.width, _remoteVideoView2.frame.size.height
          ,_remoteVideoSize.width, _remoteVideoSize.height);
    
  } else {
    
    // Aspect fit local video view into a square box.
    CGRect localVideoFrame = bounds;
//        CGRectMake(0, 0, kLocalVideoViewSize, kLocalVideoViewSize);
    // Place the view in the bottom right.
//    localVideoFrame.origin.x = CGRectGetMaxX(bounds)
//        - localVideoFrame.size.width - kLocalVideoViewPadding;
//    localVideoFrame.origin.y = CGRectGetMaxY(bounds)
//        - localVideoFrame.size.height - kLocalVideoViewPadding;
    _remoteVideoView2.frame = localVideoFrame;
  }
  

  
  
  
  
  // Place stats at the top.
  CGSize statsSize = [_statsView sizeThatFits:bounds.size];
  _statsView.frame = CGRectMake(CGRectGetMinX(bounds),
                                CGRectGetMinY(bounds) + kStatusBarHeight,
                                _remoteVideoView2.frame.size.width, CGRectGetMinY(_remoteVideoView2.frame));
    
  
  
  
  
  
  // Place hangup button in the bottom left.
  _hangupButton.frame =
    CGRectMake(CGRectGetMinX(bounds) + kButtonPadding,
               CGRectGetMaxY(bounds) - kButtonPadding -
                   kButtonSize,
                    kButtonSize,
                    kButtonSize);

  // Place button to the right of hangup button.
  CGRect cameraSwitchFrame = _hangupButton.frame;
  cameraSwitchFrame.origin.x =
      CGRectGetMaxX(cameraSwitchFrame) + kButtonPadding;
  _pauseResumeButton.frame = cameraSwitchFrame;

  // Place route button to the right of camera button.
  CGRect routeChangeFrame = _pauseResumeButton.frame;
  routeChangeFrame.origin.x =
      CGRectGetMaxX(routeChangeFrame) + kButtonPadding;
  _restartButton.frame = routeChangeFrame;
  
  CGRect capFrame = _restartButton.frame;
  capFrame.origin.x =
      CGRectGetMaxX(capFrame) + kButtonPadding;
  
  _captureButton.frame = capFrame;
  
  
  CGRect rotationFrame = _captureButton.frame;
  rotationFrame.origin.x =
      CGRectGetMaxX(rotationFrame) + kButtonPadding;
  _rotationBtn.frame = rotationFrame;
  
  
  CGRect renderFrame = _rotationBtn.frame;
  renderFrame.origin.x =
      CGRectGetMaxX(renderFrame) + kButtonPadding;
  _renderBtn.frame = renderFrame;
  
  
  
  [_statusLabel sizeToFit];
  _statusLabel.center =
      CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(LiveEBVideoView *)videoView didError:(NSError *)error {
    NSLog(@"LiveEB view _remoteVideoView ");
}

- (void)showStats:(LiveEBVideoView *)videoView stat:(NSArray*)stat {
    
}

- (void)showStats:(LiveEBVideoView *)videoView strStat:(nonnull NSString *)strStat {

    
}

- (void)showStats:(LiveEBVideoView *)videoView statReport:(LEBStatReport *)statReport {
  //NSLog(@"LiveEB view statReport %@", [statReport description]);
  
  [self.statsView setStats:[statReport description]];
}

- (void)showStats:(LiveEBVideoView *)videoView rtcStatReport:(LEBRTCStatReport*)rtcStatReport {
   NSLog(@"RTCStatistics== :%f %d %f %f %d %d %u",
         rtcStatReport.totalFreezesDuration, rtcStatReport.freezeCount,
          rtcStatReport.totalFramesDuration, rtcStatReport.sumSquaredFrameDurationsSec,
         rtcStatReport.pauseCount, rtcStatReport.isPaused, rtcStatReport.fromLastFrameRenderedDuraMS);
}


- (void)videoView:(LiveEBVideoView *)videoView didChangeVideoSize:(CGSize)size {
     if (videoView == _remoteVideoView2) {
        _remoteVideoSize = size;
      }
      [self setNeedsLayout];
  [self layoutIfNeeded];
}

- (void)onPrepared:(LiveEBVideoView*)videoView {
    NSLog(@"LiveEB view _remoteVideoView onPrepared ");
}


//onCompletion里重试。
- (void)onCompletion:(LiveEBVideoView*)videoView {
    NSLog(@"LiveEB view _remoteVideoView onCompletion ");
  
  //重试
  
//  __weak LiveEBVideoView *weakSelf = videoView;
//  dispatch_async(dispatch_get_main_queue(), ^{
//
//    LiveEBVideoView *strongSelf = weakSelf;
//
//    [_delegate videoCallViewDidRestart:strongSelf];
//  });
  
}

-(void)onFirstFrameRender:(LiveEBVideoView *)videoView {
  NSLog(@"LiveEB view _remoteVideoView onFirstFrameRender ");
}

- (void)onSeiMetadata:(NSData *)bitstream {
  NSLog(@"LiveEB view onSeiMetadata ");
  NSLog(@"onSEIData %ld", [bitstream length]);
  
}

#pragma mark - Private

-(void)onRotation:(id)sender {
  static BOOL rotate = false;
  if (!rotate) {
    rotate = true;
    
    
    [_remoteVideoView2 setRenderRotation:LEBVideoRotation_90];
  } else {
    rotate = false;
    
    [_remoteVideoView2 setRenderRotation:LEBVideoRotation_0];
  }
  
}

-(UIImage *)imageWithCaputureView:(UIView *)view {
  CGSize size = CGSizeMake(view.bounds.size.width, view.bounds.size.height);

  // 开启位图上下文
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);

  // 获取上下文
  CGContextRef ctx = UIGraphicsGetCurrentContext();

  // 把控件上的图层渲染到上下文,layer只能渲染
  [view.layer renderInContext:ctx];

  // 生成新图片
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  // 关闭上下文
  UIGraphicsEndImageContext();

  return image;
}

-(void)onRenderMode:(id)sender {
  static LEBVideoRenderMode mode = LEBVideoRenderMode_ScaleAspect_FIT;
  if (mode == LEBVideoRenderMode_ScaleAspect_FIT) {
    mode = LEBVideoRenderMode_ScaleAspect_FILL;
  } else {
    mode = LEBVideoRenderMode_ScaleAspect_FIT;
  }
  
  [_remoteVideoView2 setRenderMode:mode];
  
}

- (void)onRouteChange:(id)sender {
  [_delegate videoCallViewDidChangeRoute:self];
}

- (void)onHangup:(id)sender {
  [_delegate videoCallViewDidHangup:self];
}

- (void)onPauseResume:(id)sender {
  [_delegate videoCallViewDidPauseResume:self];
}

- (void)onRestart:(id)sender {
  [_delegate videoCallViewDidRestart:self];
}


-(NSString*)getSavePath {
  NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentPath = [path firstObject];
  NSString *defaultPath = [documentPath stringByAppendingPathComponent:@"IMG"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager createDirectoryAtPath:defaultPath withIntermediateDirectories:NO attributes:nil error:nil];
  
  return defaultPath;
}


-(UIImage *)imageWithCaputureView2:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage *)imageWithCaputureView3:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)onCapture:(id)sender {
//  imageWithCaputureView(_remoteVideoView2);
  //[_delegate onCapture];
  //NSString *filepath = [self getSavePath];
  
  [ConvertWAV testOutputFile];
  
  
  UIImage* image = [self imageWithCaputureView3:_remoteVideoView2];
  
  
  static int index = 0;
  if (image != NULL) {
    NSString *filePath = [[self getSavePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"/img_%d.png", index++]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      BOOL wy = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
      
      NSLog(@"write file wy %d", wy);
    });
    
  }
  
}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
    [_delegate videoCallViewDidEnableStats:self];
}

@end
