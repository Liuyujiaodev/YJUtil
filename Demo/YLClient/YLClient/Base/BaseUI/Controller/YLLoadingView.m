//
//  YLLoadingView.m
//  YLZhiNengYun
//
//  Created by 刘玉娇 on 2017/12/22.
//  Copyright © 2017年 yunli. All rights reserved.
//

#import "YLLoadingView.h"

@interface YLLoadingView ()
@property (nonatomic, strong) UIActivityIndicatorView* loading;
@end

@implementation YLLoadingView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat superWidth = frame.size.width;
        CGFloat superHeight = frame.size.height;
        CGFloat width = 80;
        UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake((superWidth - 80)/2, (superHeight - 80)/2, width, width)];
        contentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        [self addSubview:contentView];
        
        contentView.layer.cornerRadius = 4;
        contentView.layer.masksToBounds = YES;
        
        self.loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((width - 50)/2, (width - 50)/2, 50, 50)];
        self.loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [contentView addSubview:self.loading];
        
        [self.loading startAnimating];
        
    }
    return self;
}

- (void)stopLoading {
    [self.loading stopAnimating];
    [self removeFromSuperview];
}

@end
