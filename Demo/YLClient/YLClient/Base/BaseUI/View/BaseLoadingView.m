//
//  YMBLoadingView.m
//  DaoDao
//
//  Created by Liu Yujiao on 14-8-1.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "BaseLoadingView.h"

#define WIDTH           90
#define HEIGHT          80

@implementation BaseLoadingView

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APPWidth, APPHeight - APP_STATUS_NAVBAR_HEIGHT);
        self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        
        UIView *activityBack = [[UIView alloc] initWithFrame:CGRectMake((APPWidth - WIDTH) / 2, (CGRectGetHeight(self.frame) - HEIGHT) / 2 , WIDTH, HEIGHT)];
        activityBack.backgroundColor = [UIColor grayColor];
        activityBack.alpha = 0.9;
        activityBack.layer.masksToBounds = YES;
        activityBack.layer.cornerRadius = 4;
        [self addSubview:activityBack];
        
        self.activityVC = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((WIDTH - 30)/2, (HEIGHT - 30)/2, 30, 30)];
        [self.activityVC setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityVC startAnimating];
        [activityBack addSubview: self.activityVC];
    }
    return self;
}

- (void)removeFromSuperview {
    [self.activityVC stopAnimating];
    [super removeFromSuperview];
    
}


@end
