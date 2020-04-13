//
//  DropDown1.m
//  DropTextView
//
//  Created by ts on 2020/3/6.
//  Copyright © 2020 abc. All rights reserved.
//

#import "LiveEBDemoDropDownTextView.h"

@interface DropDownTextView()  <UITextFieldDelegate>
{
     BOOL showList;//是否弹出下拉列表
}

-(void)dropdown;

@end


@interface SubTextField()

@property (nonatomic, weak) DropDownTextView *fatherRView;

@end

@implementation SubTextField



- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
//    if (action == @selector(paste:))//粘贴
//    {
//        return NO;
//    }
//    else if (action == @selector(copy:))//赋值
//    {
//        return NO;
//    }
//    else if (action == @selector(select:))//选择
//    {
//        return NO;
//    }
    
    //if (self.fatherRVi)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.fatherRView dropdown];
        });
    }
    
   
    return [super canPerformAction:action withSender:sender];
}

@end



@implementation DropDownTextView



//@synthesize tv,tableArray,textField;



//- (void)dealloc
//
//{
////
////    [tv release];
////
////    [tableArray release];
////
////    [textField release];
//
////    [super dealloc];
//
//}



-(id)initWithFrame:(CGRect)frame
{
if (self = [super initWithFrame:frame]) {
//    self.backgroundColor = [UIColor grayColor];
    showList = NO; //默认不显示下拉框
    
    _tv = [[UITableView alloc] initWithFrame:CGRectZero];//(0, 30, self.frame.size.width, 0)];

    _tv.delegate = self;

    _tv.dataSource = self;

    _tv.backgroundColor = [UIColor grayColor];

    _tv.separatorColor = [UIColor lightGrayColor];

    _tv.hidden = YES;

    [self addSubview:_tv];

           _textField = [[SubTextField alloc] initWithFrame:CGRectZero];//CGRectMake(0, 0, self.frame.size.width, 30)];
//            _textField.backgroundColor = [UIColor lightGrayColor];
//           _textField.borderStyle=UITextBorderStyleRoundedRect;//设置文本框的边框风格

           _textField.borderStyle = UITextBorderStyleRoundedRect;
            
           _textField.font = [UIFont systemFontOfSize:15];
           _textField.placeholder = @"input LiveBroadcasting url ：";
            //[_textField setValue:[UIColor greenColor] forKeyPath:@"_placeholderLabel.textColor"];
    
            _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"input LiveBroadcasting url ：" attributes:@{NSForegroundColorAttributeName: [UIColor greenColor]}];
    
           _textField.autocorrectionType = UITextAutocorrectionTypeNo;
           _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
           _textField.clearButtonMode = UITextFieldViewModeAlways;
           _textField.delegate = self;
            _textField.fatherRView = self;
           //[_textField addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchDragInside];

           [self addSubview:_textField];
}
    return self;

}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //NSLog(@"%@",textField.text);
    
    [self dropdown];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSLog(@"%@",textField.text);
    
    [self dropdown];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // There is no other control that can take focus, so manually resign focus
  // when return (Join) is pressed to trigger |textFieldDidEndEditing|.
  [textField resignFirstResponder];
  return YES;
}

- (void)layoutSubviews  {
    NSLog(@"layoutSubviews");
    
    if (self.frame.size.height<100) {
        
        tabCellHeight = 50;
        frameHeight = 100;

    }else{

        frameHeight = self.frame.size.height;

    }

    tabheight = frameHeight-tabCellHeight;

    _tv.frame = CGRectMake(0, tabCellHeight, self.frame.size.width, tabheight);
    _textField.frame = CGRectMake(0, 0, self.frame.size.width, tabCellHeight);
    //self.frame.size.height = tabCellHeight;

    //self.frame.size.height = 200;

    //self=[super initWithFrame:self.frame];




}

-(void)dropdown{

//    [_textField resignFirstResponder];

    if (showList) {//如果下拉框已显示，什么都不做
        
//        showList = NO;
//
//        _tv.hidden = YES;
        CGRect frame = self.frame;
       frame.size.height = frameHeight;
        self.frame = frame;
        return;

    }else {//如果下拉框尚未显示，则进行显示

        

        CGRect sf = self.frame;

        sf.size.height = frameHeight;

        

        //把dropdownList放到前面，防止下拉框被别的控件遮住

        [self.superview bringSubviewToFront:self];

        _tv.hidden = NO;

        showList = YES;//显示下拉框

        

        CGRect frame = _tv.frame;

        frame.size.height = 0;

        _tv.frame = frame;

        frame.size.height = tabheight;

        [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];

        [UIView setAnimationCurve:UIViewAnimationCurveLinear];

        self.frame = sf;

        _tv.frame = frame;
        
        [UIView commitAnimations];

    }

}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView

{

    return 1;

}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{

    return [_tableArray count];

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{

    static NSString *CellIdentifier = @"Cell";

    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }

    

    cell.textLabel.text = [_tableArray objectAtIndex:[indexPath row]];

    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];

    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    

    return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{

    return tabCellHeight;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{

    _textField.text = [_tableArray objectAtIndex:[indexPath row]];

    showList = NO;

    _tv.hidden = YES;

    

    CGRect sf = self.frame;
    sf.size.height = tabCellHeight;
    self.frame = sf;

    CGRect frame = _tv.frame;
    frame.size.height = 0;
    _tv.frame = frame;

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{

    // Return YES for supported orientations

    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}



@end


