//
//  YMTabBar.h
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YLTabBar, YLTabBarButton;

@protocol YLTabBarDelegate <NSObject>

@optional
- (void)tabBar:(YLTabBar *)tabBar didSelectButtonFrom:(NSUInteger)from to:(NSUInteger)to;
@end

@interface YLTabBar : UIImageView

@property (nonatomic, weak) id<YLTabBarDelegate> delegate;

- (void)addTabBarButtonWithItem:(UITabBarItem *)item;

@end

