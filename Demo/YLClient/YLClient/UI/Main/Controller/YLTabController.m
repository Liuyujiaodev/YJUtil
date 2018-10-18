//
//  YMTabController.m
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import "YLTabController.h"
#import "YLNavController.h"

@interface YLTabController () <YLTabBarDelegate>
{
    YLTabBar *_customTabbar;
}
@end

@implementation YLTabController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // 添加新的条
    [self addTabBar];
    
    // 添加所有的子控制器
    [self addChildViewControllers];
}

#pragma mark - 在view即将显示的时候
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 移除YMTabBar以外的其他控件
    for (int i = 0; i<self.tabBar.subviews.count; i++) {
        UIView *child = self.tabBar.subviews[i];
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
    self.tabBar.layer.shadowColor = RGBAlphaColor(0, 0, 0, 0.05).CGColor;
    self.tabBar.layer.shadowRadius = 10;
    self.tabBar.layer.shadowOpacity = 1;
    self.tabBar.layer.masksToBounds = NO;

    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.tabBar.clipsToBounds = NO;
}

#pragma mark 添加条
- (void)addTabBar
{
    
    _customTabbar = [[YLTabBar alloc] initWithFrame:self.tabBar.bounds];
    _customTabbar.delegate = self;
    [self.tabBar addSubview:_customTabbar];
}

#pragma mark - YMTabBar的代理方法
- (void)tabBar:(YLTabBar *)tabBar didSelectButtonFrom:(NSUInteger)from to:(NSUInteger)to
{
    self.selectedIndex = to;
}

#pragma mark 添加所有的子控制器
- (void)addChildViewControllers
{
////    // 项目
//    YLClientRequestController *clientRequestVC = [[YLClientRequestController alloc] init];
//    [self addChildViewController:clientRequestVC title:@"" image:[SVGKImage imageNamed:@"tab1"].UIImage selectedImage:[SVGKImage imageNamed:@"tab1_selected"].UIImage];
//    
//    YLCreditController *creditVC = [[YLCreditController alloc] init];
//    [self addChildViewController:creditVC title:@"" image:[SVGKImage imageNamed:@"tab2"].UIImage selectedImage:[SVGKImage imageNamed:@"tab2_selected"].UIImage];
//    
//    YLPaymentController *payVC = [[YLPaymentController alloc] init];
//    [self addChildViewController:payVC title:@"" image:[SVGKImage imageNamed:@"tab3"].UIImage selectedImage:[SVGKImage imageNamed:@"tab3_selected"].UIImage];
//    
//    YLMyController *myVC = [[YLMyController alloc] init];
//    [self addChildViewController:myVC title:@"" image:[SVGKImage imageNamed:@"tab4"].UIImage selectedImage:[SVGKImage imageNamed:@"tab4_selected"].UIImage];
}

#pragma mark 初始化子控制器的属性
- (void)addChildViewController:(UIViewController *)child title:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    
    // 设置选项卡标签属性
//    child.tabBarItem.title = title;
    child.tabBarItem.image = image;
    child.tabBarItem.selectedImage = selectedImage;
    if (IS_IPHONE_5) {
        child.tabBarItem.selectedImage = [child.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    // 设置标题和包装导航控制器
    child.title = title;
    YLNavController *nav = [[YLNavController alloc] initWithRootViewController:child];
    [self addChildViewController:nav];
    
    // 添加按钮
    [_customTabbar addTabBarButtonWithItem:child.tabBarItem];
}

- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.tabBar.bounds);
    self.tabBar.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.tabBar.layer.shadowColor = color.CGColor;
    self.tabBar.layer.shadowOffset = offset;
    self.tabBar.layer.shadowRadius = radius;
    self.tabBar.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.tabBar.clipsToBounds = NO;
    self.tabBar.layer.masksToBounds = NO;
}
@end
