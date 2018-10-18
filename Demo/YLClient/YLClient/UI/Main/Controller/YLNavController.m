//
//  YLNavController.m
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import "YLNavController.h"

@interface YLNavController ()

@property (nonatomic, strong) UIImageView *barImageView;
@property (nonatomic, strong) UIView *bar;

@end

@implementation YLNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINavigationBar *bar = [UINavigationBar appearance];
    // 去掉bar下面的底线
    bar.barStyle = UIBaselineAdjustmentNone;
    [bar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           RGBColor(255, 255, 255), NSForegroundColorAttributeName,
                                                           [UIFont boldSystemFontOfSize:17.0], NSFontAttributeName, nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = self.viewControllers.count;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)popViewControllerWithAnimated:(BOOL)animated completion:(void(^)())completion{
    [self popViewControllerAnimated:animated];
    
    completion();
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self.viewControllers lastObject] preferredStatusBarStyle];
}

@end
