//
//  XLBaseEntityController.h
//  YiMeiBusiness
//
//  Created by 刘玉娇 on 15/9/7.
//  Copyright (c) 2015年 Xiaolinxiaoli. All rights reserved.
//

#import "BaseController.h"

@interface BaseEntityController : BaseController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView* scrollerView;
@property (nonatomic, assign) CGFloat contentHeight;

- (void)addRefresh;
-(void)loadData;
- (void)endLoad;
@end
