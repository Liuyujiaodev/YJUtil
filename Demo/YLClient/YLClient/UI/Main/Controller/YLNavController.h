//
//  YLNavController.h
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLNavController : UINavigationController

- (void)popViewControllerWithAnimated:(BOOL)animated completion:(void(^)())completion;

@end
