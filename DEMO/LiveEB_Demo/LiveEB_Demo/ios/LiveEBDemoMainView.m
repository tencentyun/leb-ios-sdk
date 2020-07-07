#import "LiveEBDemoMainView.h"

#import "UIImage+LiveEBUtilities.h"
#import "LiveEBDemoDropDownTextView.h"

static CGFloat const kRoomTextFieldHeight = 40;
static CGFloat const kRoomTextFieldMargin = 8;
static CGFloat const kCallControlMargin = 18;

// Helper view that contains a text field and a clear button.
@interface LiveEBRoomTextField : UIView <UITextFieldDelegate>
@property(nonatomic, readonly) NSString *roomText;
@end

@implementation LiveEBRoomTextField {
  UITextField *_roomText;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _roomText = [[UITextField alloc] initWithFrame:CGRectZero];
    _roomText.borderStyle = UITextBorderStyleNone;
    _roomText.font = [UIFont systemFontOfSize:12];
    _roomText.placeholder = @"LiveBroadcasting url";
    _roomText.autocorrectionType = UITextAutocorrectionTypeNo;
    _roomText.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _roomText.clearButtonMode = UITextFieldViewModeAlways;
    _roomText.delegate = self;
    [self addSubview:_roomText];

    // Give rounded corners and a light gray border.
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.cornerRadius = 2;
  }
  return self;
}

- (void)layoutSubviews {
  _roomText.frame =
      CGRectMake(kRoomTextFieldMargin, 0, CGRectGetWidth(self.bounds) - kRoomTextFieldMargin,
                 kRoomTextFieldHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
  size.height = kRoomTextFieldHeight;
  return size;
}

- (NSString *)roomText {
  return _roomText.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // There is no other control that can take focus, so manually resign focus
  // when return (Join) is pressed to trigger |textFieldDidEndEditing|.
  [textField resignFirstResponder];
  return YES;
}

@end

 

@implementation LiveEBDemoMainView {
  DropDownTextView *_roomText;
  DropDownTextView *_roomText2;
  UIButton *_startRegularCallButton;
  UIButton *_startLoopbackCallButton;
  UIButton *_audioLoopButton;
}

@synthesize delegate = _delegate;
@synthesize isAudioLoopPlaying = _isAudioLoopPlaying;

#pragma mark - UITextFieldDelegate



- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    //webrtc://6721.liveplay.now.qq.com/live/6721_c21f14dc5c3ce1b2513f5810f359ea15?txSecret=c96521895c01742114c033f3cb585339&txTime=5DDE5CBC
    _roomText = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"input LiveBroadcasting url ："];

      NSArray* arr=[[NSArray alloc]initWithObjects:@"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a", nil];

         _roomText.tableArray = arr;
    [self addSubview:_roomText];
    
    
    _roomText2 = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"input host:"];
    
//    NSArray* arr2=[[NSArray alloc]initWithObjects:@"219.151.31.40", nil];
     NSArray* arr2=[[NSArray alloc]initWithObjects:@"https://webrtc.liveplay.myqcloud.com", nil];
    
    _roomText2.tableArray = arr2;
    [self addSubview:_roomText2];
    

    UIFont *controlFont = [UIFont boldSystemFontOfSize:18.0];
    UIColor *controlFontColor = [UIColor whiteColor];

    _startRegularCallButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _startRegularCallButton.titleLabel.font = controlFont;
    [_startRegularCallButton setTitleColor:controlFontColor forState:UIControlStateNormal];
    _startRegularCallButton.backgroundColor
        = [UIColor colorWithRed:66.0/255.0 green:200.0/255.0 blue:90.0/255.0 alpha:1.0];
    [_startRegularCallButton setTitle:@"LiveBroadcasting call" forState:UIControlStateNormal];
    [_startRegularCallButton addTarget:self
                                action:@selector(onStartRegularCall:)
                      forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_startRegularCallButton];

    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)setIsAudioLoopPlaying:(BOOL)isAudioLoopPlaying {
  if (_isAudioLoopPlaying == isAudioLoopPlaying) {
    return;
  }
  _isAudioLoopPlaying = isAudioLoopPlaying;
  [self updateAudioLoopButton];
}

- (void)layoutSubviews {
  CGRect bounds = self.bounds;
    if (_roomText.frame.size.width < 10 || _roomText.frame.size.height <  10) {
        CGFloat roomTextWidth = bounds.size.width - 2 * kRoomTextFieldMargin;
        CGFloat roomTextHeight = kRoomTextFieldHeight;
        _roomText.frame =
            CGRectMake(kRoomTextFieldMargin, kRoomTextFieldMargin, roomTextWidth,
                       roomTextHeight);
    }
  
  if (_roomText2.frame.size.width < 10 || _roomText2.frame.size.height <  10) {
      CGFloat roomTextWidth = bounds.size.width - 2 * kRoomTextFieldMargin;
      CGFloat roomTextHeight = kRoomTextFieldHeight;
      _roomText2.frame =
          CGRectMake(kRoomTextFieldMargin, kRoomTextFieldMargin + CGRectGetMaxY(_roomText.frame), roomTextWidth,
                     roomTextHeight);
  }
  

  CGFloat buttonHeight =
      (CGRectGetMaxY(self.bounds) - CGRectGetMaxY(_roomText2.frame) - kCallControlMargin * 4) / 3;

  CGFloat regularCallFrameTop = CGRectGetMaxY(_roomText2.frame) + kCallControlMargin;
  CGRect regularCallFrame = CGRectMake(kCallControlMargin,
                                       regularCallFrameTop,
                                       bounds.size.width - 2*kCallControlMargin,
                                       buttonHeight);

  _startRegularCallButton.frame = regularCallFrame;
//  _startLoopbackCallButton.frame = loopbackCallFrame;
//  _audioLoopButton.frame = audioLoopFrame;
}

#pragma mark - Private

- (void)updateAudioLoopButton {
  if (_isAudioLoopPlaying) {
    [_audioLoopButton setTitle:@"Stop sound" forState:UIControlStateNormal];
  } else {
    [_audioLoopButton setTitle:@"Play sound" forState:UIControlStateNormal];
  }
}

- (void)onToggleAudioLoop:(id)sender {
  [_delegate mainViewDidToggleAudioLoop:self];
}

- (void)onStartRegularCall:(id)sender {
  [_delegate mainView:self didInputRoom:_roomText.textField.text didInputHost:_roomText2.textField.text isLoopback:NO];
}

- (void)onStartLoopbackCall:(id)sender {
  [_delegate mainView:self didInputRoom:_roomText.textField.text  didInputHost:_roomText2.textField.text  isLoopback:YES];
}

@end
