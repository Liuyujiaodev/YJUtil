//
//  YMTabBar.m
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import "YLTabBar.h"
#import "YLTabBarButton.h"

@interface YLTabBar()
{
    YLTabBarButton *_selectedButton;
    NSUInteger _tabButtonCount;
}
@end

@implementation YLTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark 添加一个按钮
- (void)addTabBarButtonWithItem:(UITabBarItem *)item
{
    // 1.创建按钮
    YLTabBarButton *button = [YLTabBarButton buttonWithType:UIButtonTypeCustom];

    // 2.设置背景
    button.item = item;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
    
    // 3.添加
    [self addSubview:button];
    
    // 4.默认选中第0个按钮
    button.tag = _tabButtonCount;
    if (_tabButtonCount == 0) {
        [self buttonClick:button];
    }
    
    // 5.设置按钮frame
    CGFloat buttonW = self.frame.size.width / 4;
    CGFloat height = kDevice_Is_iPhoneX ? self.frame.size.height + 34 : self.frame.size.height;
    button.frame = CGRectMake(_tabButtonCount * buttonW, 0, buttonW, height);
    _tabButtonCount++;
}


#pragma mark 监听按钮点击

- (void)buttonClick:(YLTabBarButton *)button
{   
    // 1.通知代理
    if ([_delegate respondsToSelector:@selector(tabBar:didSelectButtonFrom:to:)]) {
        NSInteger from = _selectedButton ? _selectedButton.tag : -1;
        [_delegate tabBar:self didSelectButtonFrom:from to:button.tag];
    }
    _selectedButton.selected = NO;
    button.selected = YES;
    _selectedButton = button;
}

@end
