//
//  LiveEBDebugView.m
//  LiveEBDebugView
//
//  Created by lusty on 2021/1/20.
//

#import "LiveEBDebugView.h"

#import "UIImage+LiveEBUtilities.h"
#import "LiveEBDemoDropDownTextView.h"

static CGFloat const kRoomTextFieldHeight = 40;
static CGFloat const kRoomTextFieldMargin = 8;
static CGFloat const kCallControlMargin = 18;

@interface LiveEBDebugView ()

@property (nonatomic, strong) UIStackView *containerStackView;
@property (nonatomic, strong) DropDownTextView *codeStreamTF;
@property (nonatomic, strong) UITextField *signalTF;

@end

@implementation LiveEBDebugView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerStackView.frame = self.bounds;
  
//  CGRect bounds = self.bounds;
//  if (self.codeStreamTF.frame.size.width < 10 || self.codeStreamTF.frame.size.height <  10) {
//        CGFloat roomTextWidth = bounds.size.width - 2 * kRoomTextFieldMargin;
//        CGFloat roomTextHeight = kRoomTextFieldHeight;
//        self.codeStreamTF.frame =
//            CGRectMake(kRoomTextFieldMargin, kRoomTextFieldMargin, roomTextWidth,
//                       roomTextHeight);
//    }
//
//  if (self.signalTF.frame.size.width < 10 || self.signalTF.frame.size.height <  10) {
//      CGFloat roomTextWidth = bounds.size.width - 2 * kRoomTextFieldMargin;
//      CGFloat roomTextHeight = kRoomTextFieldHeight;
//      self.signalTF.frame =
//    CGRectMake(kRoomTextFieldMargin, kRoomTextFieldMargin + CGRectGetMaxY(self.codeStreamTF.frame), roomTextWidth,
//                     roomTextHeight);
//  }
  
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
  self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupSubviews];
    }
  
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)setupSubviews {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self addSubview:scrollView];
    self.containerStackView = [[UIStackView alloc] initWithFrame:self.bounds];
    self.containerStackView.axis = UILayoutConstraintAxisVertical;
//    self.containerStackView.alignment = UIStackViewAlignmentFill;
    self.containerStackView.spacing = 20;
    [scrollView addSubview:self.containerStackView];
    [self setupSignalView];
    [self setupCodeStreamInputView];
    [self setupSignalInputView];
    [self setupVideoDecodeView];
    [self setupAudioFormatView];
    [self setupEncryptView];
    [self setupSEIView];
    [self setupButtonView];
    [self setupPlaceholderView];
}

- (void)setupSignalView {
    UILabel *label = [self labelWithTitle:@"信令接口版本："];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"V0", @"V1"] action:@selector(signalVersionChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupCodeStreamInputView {
    UILabel *label = [self labelWithTitle:@"码流URL"];
    label.textAlignment = NSTextAlignmentCenter;
//    DropDownTextView *textField = [self textFieldWithPlaceholder:nil text:@"码流地址"];
  
  CGFloat width = CGRectGetWidth(self.frame);
  DropDownTextView  *textField = [[DropDownTextView alloc] initWithFrame:CGRectMake(0, 0, width, kRoomTextFieldHeight + kRoomTextFieldMargin) hintText:@"input LiveBroadcasting url ："];
  
//  DropDownTextView  *textField = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"码流地址："];

  NSArray* arr=[[NSArray alloc]initWithObjects:@"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a", nil];

     textField.tableArray = arr;
  
//    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
//                                           alignment:UIStackViewAlignmentFill
//                                            subviews:@[label, textField]];
    [self.containerStackView addArrangedSubview:textField];
    self.codeStreamTF = textField;
}

- (void)setupSignalInputView {
    UILabel *label = [self labelWithTitle:@"信令URL"];
    label.textAlignment = NSTextAlignmentCenter;
    UITextField *textField = [self textFieldWithPlaceholder:nil text:@"信令地址"];
  
//    DropDownTextView *textField = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"信令地址:"];
//
//      NSArray* arr2=[[NSArray alloc]initWithObjects:@"https://webrtc.liveplay.myqcloud.com", nil];
//
//      textField.tableArray = arr2;
  
  
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, textField]];
    [self.containerStackView addArrangedSubview:stackView];
    self.signalTF = textField;
}

- (void)setupVideoDecodeView {
    UILabel *label = [self labelWithTitle:@"Video解码器(H264和H265)"];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"硬解", @"软解"] action:@selector(videoDecodeChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupAudioFormatView {
    UILabel *label = [self labelWithTitle:@"Audio格式"];
    NSArray *titles = @[@"OPUS", @"AAC(MP4A-LATM)", @"AAC(MP4A-ADTS)"];
    UISegmentedControl *control = [self segmentedControlWithTitles:titles action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupEncryptView {
    UILabel *label = [self labelWithTitle:@"加密："];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"开", @"关"] action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupSEIView {
    UILabel *label = [self labelWithTitle:@"SEI回调"];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"开", @"关"] action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupButtonView {
    UILabel *leftLabel = [self labelWithTitle:nil];
    UIButton *button = [self buttonWithTitle:@"开始拉流"
                                      action:@selector(startPullStream)];
    button.frame = CGRectMake(0, 0, 150, 80);
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self
            action:@selector(onStartRegularCall:)
     forControlEvents:UIControlEventTouchUpInside];
  
    UILabel *rightLabel = [self labelWithTitle:nil];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisHorizontal
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[leftLabel, button, rightLabel]];
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self.containerStackView addArrangedSubview:stackView];
}

- (void)setupPlaceholderView {
    UILabel *label = [self labelWithTitle:nil];
    [label setContentHuggingPriority:240
                             forAxis:UILayoutConstraintAxisVertical];
    [label setContentCompressionResistancePriority:240
                                           forAxis:UILayoutConstraintAxisVertical];
    [self.containerStackView addArrangedSubview:label];
}

- (UIStackView *)stackViewWithAxis:(UILayoutConstraintAxis)axis alignment:(UIStackViewAlignment)alignment subviews:(NSArray *)subviews {
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:subviews];
    stackView.axis = axis;
    stackView.alignment = alignment;
    stackView.spacing = 10;
    return stackView;
}

- (UILabel *)labelWithTitle:(NSString *)title {
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    return label;
}

- (UISegmentedControl *)segmentedControlWithTitles:(NSArray<NSString *> *)titles
                                            action:(SEL)action {
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:titles];
    [control addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    if (titles.count > 0) {
        [control setSelectedSegmentIndex:0];
    }
    return control;
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder text:(NSString *)text {
    UITextField *textField = [UITextField new];
    textField.text = text;
    textField.placeholder = placeholder;
    textField.textColor = [UIColor blackColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    return textField;
}

- (void)signalVersionChanged:(UISegmentedControl *)control {
    NSLog(@"%s=====%@", __FUNCTION__, @(control.selectedSegmentIndex));
}

- (void)videoDecodeChanged:(UISegmentedControl *)control {
    NSLog(@"%s=====%@", __FUNCTION__, @(control.selectedSegmentIndex));
}

- (void)audioFormatChanged:(UISegmentedControl *)control {
    NSLog(@"%s=====%@", __FUNCTION__, @(control.selectedSegmentIndex));
}

- (void)encryptSelectionChanged:(UISegmentedControl *)control {
    NSLog(@"%s=====%@", __FUNCTION__, @(control.selectedSegmentIndex));
}

- (void)SEICallbackChanged:(UISegmentedControl *)control {
    NSLog(@"%s=====%@", __FUNCTION__, @(control.selectedSegmentIndex));
}

- (void)startPullStream {
    NSLog(@"%s=====", __FUNCTION__);
}


- (void)onStartRegularCall:(id)sender {
  [_delegate mainView:self didInputRoom:self.codeStreamTF.textField.text didInputHost:self.signalTF.text isLoopback:NO];
}

@end
