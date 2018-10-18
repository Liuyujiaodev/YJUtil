//
//  BaseController.m
//  YLXD
//
//  Created by 刘玉娇 on 2017/10/9.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "BaseController.h"
#import <objc/runtime.h>
#import "YLTabBar.h"

@interface BaseController ()
@property (nonatomic, assign) BOOL isAlertShwo;
@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.leftTitleLabel = [[UILabel alloc] init];
    self.leftTitleLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    [self.view addSubview:self.leftTitleLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat height = kDevice_Is_iPhoneX ? 88 : 64;
   
    self.navBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, height)];
    self.navBar.backgroundColor = kCOMMON_COLOR;
    self.navBar.userInteractionEnabled = YES;
    [self.view addSubview:self.navBar];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.navBar addSubview:self.titleLabel];

    if (self.navigationController.viewControllers.count > 1) {
        [self addSwipeBack];
    }
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //umeng统计
    const char* className = class_getName([self class]);
    NSString* viewControllerName = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                                  length:strlen(className)
                                                                encoding:NSASCIIStringEncoding
                                                            freeWhenDone:NO];
    [MobClick beginLogPageView:viewControllerName];
    
    // 当视图作为tab主页时，需要显示tabBar
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController.tabBarController.tabBar setHidden:NO];
        
        // 删除系统自带的tab
        UITabBar *tabBar = self.navigationController.tabBarController.tabBar;
        for (UIView *subView in tabBar.subviews) {
            if (![subView isKindOfClass:[YLTabBar class]]) {
                subView.hidden = YES;
                [subView removeFromSuperview];
            }
        }
    } else {
        [self.navigationController.tabBarController.tabBar setHidden:YES];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

//修复了iphoneX上重影的bug
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UITabBar *tabBar = self.navigationController.tabBarController.tabBar;

    for (UIView * view in tabBar.subviews)
    {
        
        if (![view isKindOfClass:[YLTabBar class]]) {
            
            [view removeFromSuperview];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    const char* className = class_getName([self class]);
    NSString* viewControllerName = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                                  length:strlen(className)
                                                                encoding:NSASCIIStringEncoding
                                                            freeWhenDone:NO];
    [MobClick endLogPageView:viewControllerName];
}
- (void)setTitle:(NSString*)title isRoot:(BOOL)isRoot {
    [self setTitle:title isRoot:isRoot rightBtn:@""];
    self.rightButton.hidden = YES;
    self.rightButton.enabled = NO;
}

- (void)setTitle:(NSString*)title isRoot:(BOOL)isRoot rightBtn:(NSString*)rightBtnStr {
    self.titleLabel.text = title;
    self.titleLabel.frame = CGRectMake((APPWidth - 200)/2, self.navBar.height - 33 - 5, 200, 33);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = kCOMMON_FONT_MEDIUM_18;
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitleColor:[RGBColor(0, 0, 0) colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font =  kCOMMON_FONT_MEDIUM_14;
    [self.rightButton setFrame:CGRectMake(APPWidth - 23 - 80, self.navBar.height - 33 - 10 , 80, 33)];
    self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    

    [self.rightButton setTitle:rightBtnStr forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(rightButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:self.rightButton];
    
    if (isRoot) {
        self.leftTitleLabel.text = title;
        self.titleLabel.hidden = YES;
        self.leftTitleLabel.frame = CGRectMake(16, self.navBar.height, 200, 33);
        self.leftTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.leftTitleLabel.font = kCOMMON_FONT_SEMIBOLD_26;
    } else {
        UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, self.navBar.height - 40, 75, 37)];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 5, 8, 25)];
        [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [self.navBar addSubview:backBtn];
    }
}

- (void)setRightNavBtn:(NSString*)str {
    self.rightButton.enabled = YES;
    [self.rightButton setTitle:str forState:UIControlStateNormal];

    self.rightButtonOnBellow = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButtonOnBellow setTitle:str forState:UIControlStateNormal];
    [self.rightButtonOnBellow setTitleColor:[RGBColor(0, 0, 0) colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    self.rightButtonOnBellow.titleLabel.font =  kCOMMON_FONT_MEDIUM_16;

    [self.rightButtonOnBellow setFrame:CGRectMake(APPWidth - 10-80, self.navBar.height, 80, 33)];
    self.rightButtonOnBellow.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.rightButtonOnBellow addTarget:self action:@selector(rightButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.rightButtonOnBellow];
}

-(void)rightButtonTouched {
    
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSwipeBack {
    id target = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        // 创建全屏滑动手势，调用系统自带滑动手势的target的action方法
//        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
//        // 设置手势代理，拦截手势触发
//        swipe.delegate = self;
//        // 给导航控制器的view添加全屏滑动手势
//        [self.view addGestureRecognizer:swipe];
//        // 禁止使用系统自带的滑动手势
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.view];
    if (point.x > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)back:(UISwipeGestureRecognizer*)swipe {
    if (self.navigationController.viewControllers.count <= 1) return;
    
    // pop返回上一级
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertErrorMsg:(id)dic {
    if ([dic isKindOfClass:[NSDictionary class]]) {
        [YLUtil showAlertView:self title:@"" message:[dic stringWithKey:@"msg"] okAction:@"" cancelAction:@"我知道了" okHandler:nil
                cancelHandler:nil];
    } else if ([dic isKindOfClass:[NSString class]]) {
        [YLUtil showAlertView:self title:@"" message:dic okAction:@"" cancelAction:@"我知道了" okHandler:nil
                cancelHandler:nil];
    }

}

- (void)requestError {
    if (!self.isAlertShwo) {
        [YLUtil showAlertView:self title:@"网络连接失败" message:@"请检查您的网络权限以及网络开关，下拉界面重新加载" okAction:@"好" cancelAction:@"设置" okHandler:^(UIAlertAction * _Nullable action) {
            self.isAlertShwo = NO;
        } cancelHandler:^(UIAlertAction * _Nullable action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            }
            self.isAlertShwo = NO;
        }];
    }
   
}
@end
