
//
//  XLBaseCell.h
//  YiMeiBusiness
//
//  Created by 刘玉娇 on 15/9/7.
//  Copyright (c) 2015年 Xiaolinxiaoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCell : UITableViewCell

@property (nonatomic, strong) id object;
@property (nonatomic, assign) id delegate;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;

@end
