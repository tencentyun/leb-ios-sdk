//
//  DropDown1.h
//  DropTextView
//
//  Created by ts on 2020/3/6.
//  Copyright © 2020 abc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class DropDownTextView;
@interface SubTextField : UITextField


@end

@interface DropDownTextView : UIView <UITableViewDelegate,UITableViewDataSource> {

//    UITableView *tv;//下拉列表

//    NSArray *tableArray;//下拉列表数据

//    UITextField *textField;//文本输入框

   

    CGFloat tabheight;//table下拉列表的高度
    CGFloat tabCellHeight;
    CGFloat frameHeight;//frame的高度

}



@property (nonatomic,retain) UITableView *tv;

@property (nonatomic,retain) NSArray *tableArray;

@property (nonatomic,retain) SubTextField *textField;



@end

NS_ASSUME_NONNULL_END
