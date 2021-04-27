//
//  LiveEBDebugView.m
//  LiveEBDebugView
//
//  Created by lusty on 2021/1/20.
//

#import "LiveEBDebugView.h"

#import "UIImage+LiveEBUtilities.h"
#import "LiveEBDemoDropDownTextView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

static CGFloat const kRoomTextFieldHeight = 40;
static CGFloat const kRoomTextFieldMargin = 8;
static CGFloat const kCallControlMargin = 18;

@interface LiveEBDebugView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *containerStackView;
@property (nonatomic, strong) DropDownTextView *codeStreamTF;
@property (nonatomic, strong) DropDownTextView *signalTF;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) CGFloat maxY;

@end

@implementation LiveEBDebugView

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
    self.scrollView = scrollView;
    [self setupSignalView];
    [self setupCodeStreamInputView];
    [self setupSignalInputView];
    [self setupVideoDecodeView];
    [self setupAudioFormatView];
    [self setupEncryptView];
    [self setupSEIView];
    [self setupButtonView];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.maxY + kRoomTextFieldMargin);
}

- (void)setupSignalView {
    UILabel *label = [self labelWithTitle:@"信令接口版本："];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"V0", @"V1"] action:@selector(signalVersionChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
}

- (void)setupCodeStreamInputView {
    UILabel *label = [self labelWithTitle:@"码流URL"];
    label.textAlignment = NSTextAlignmentCenter;
//    DropDownTextView *textField = [self textFieldWithPlaceholder:nil text:@"码流地址"];
  
  CGFloat width = CGRectGetWidth(self.frame);
    DropDownTextView  *textField = [[DropDownTextView alloc] initWithFrame:CGRectMake(0, self.maxY + kRoomTextFieldMargin, width, kRoomTextFieldHeight + kRoomTextFieldMargin) hintText:@"码流URL："];
//  DropDownTextView  *textField = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"码流地址："];

  NSArray* arr=[[NSArray alloc]initWithObjects:@"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a", nil];

     textField.tableArray = arr;
  
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[textField]];
    
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
  
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
    self.codeStreamTF = textField;
}

- (void)setupSignalInputView {
    UILabel *label = [self labelWithTitle:@"信令URL"];
    label.textAlignment = NSTextAlignmentCenter;
//    UITextField *textField = [self textFieldWithPlaceholder:nil text:@"信令地址"];
  
    DropDownTextView *textField = [[DropDownTextView alloc] initWithFrame:CGRectZero hintText:@"信令地址:"];

      NSArray* arr2=[[NSArray alloc]initWithObjects:@"https://webrtc.liveplay.myqcloud.com", nil];

      textField.tableArray = arr2;
  
  
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[ textField]];
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
    self.signalTF = textField;
}

- (void)setupVideoDecodeView {
    UILabel *label = [self labelWithTitle:@"Video解码器(H264和H265)"];
    label.textAlignment = NSTextAlignmentCenter;
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"h264", @"hevc"] action:@selector(videoDecodeChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    stackView.frame = CGRectMake(0, self.maxY, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
}

- (void)setupAudioFormatView {
    UILabel *label = [self labelWithTitle:@"Audio格式"];
    NSArray *titles = @[@"OPUS", @"AAC(MP4A-LATM)", @"AAC(MP4A-ADTS)"];
    UISegmentedControl *control = [self segmentedControlWithTitles:titles action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
}

- (void)setupEncryptView {
    UILabel *label = [self labelWithTitle:@"加密："];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"开", @"关"] action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
}

- (void)setupSEIView {
    UILabel *label = [self labelWithTitle:@"SEI回调"];
    UISegmentedControl *control = [self segmentedControlWithTitles:@[@"开", @"关"] action:@selector(audioFormatChanged:)];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisVertical
                                           alignment:UIStackViewAlignmentFill
                                            subviews:@[label, control]];
    stackView.frame = CGRectMake(0, self.maxY + kRoomTextFieldMargin, SCREEN_WIDTH, 80);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
}

- (void)setupButtonView {
    UILabel *leftLabel = [self labelWithTitle:nil];
    UIButton *button = [self buttonWithTitle:@"开始拉流"
                                      action:@selector(startPullStream)];
    button.frame = CGRectMake(0, 0, 150, 60);
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self
            action:@selector(onStartRegularCall:)
     forControlEvents:UIControlEventTouchUpInside];
    
  
#if 0
    /*
    UIButton *pushButton = [self buttonWithTitle:@"开始推流"
                                          action:@selector(startPushStream)];
    pushButton.frame = CGRectMake(0, 0, 150, 60);
    pushButton.backgroundColor = [UIColor lightGrayColor];
    
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisHorizontal
                                           alignment:UIStackViewAlignmentCenter
                                            subviews:@[leftLabel, button, pushButton, rightLabel]];
     */
#else
  UILabel *rightLabel = [self labelWithTitle:nil];
    UIStackView *stackView = [self stackViewWithAxis:UILayoutConstraintAxisHorizontal
                                         alignment:UIStackViewAlignmentCenter
                                          subviews:@[leftLabel, button, rightLabel]];
#endif
  
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.frame = CGRectMake(0, self.maxY + 20, SCREEN_WIDTH, 60);
    [self.scrollView addSubview:stackView];
    self.maxY = CGRectGetMaxY(stackView.frame);
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

- (void)startPushStream {
  [_delegate mainView:self didInputRoom:self.codeStreamTF.textField.text didInputHost:self.signalTF.textField.text isLoopback:NO isPush:YES];
}

- (void)onStartRegularCall:(id)sender {
  [_delegate mainView:self didInputRoom:self.codeStreamTF.textField.text didInputHost:self.signalTF.textField.text isLoopback:NO isPush:NO];
}

@end

