//
//  DKActivityIndicatorAnmationView.h
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DKActivityIndicatorAnimationType) {
    DKBallClipRotateAnimation
};

@interface DKActivityIndicatorAnmationView : UIView

//init
- (id)initWithType:(DKActivityIndicatorAnimationType)type;
- (id)initWithType:(DKActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor;
- (id)initWithType:(DKActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor size:(CGFloat)size;

@property (nonatomic) DKActivityIndicatorAnimationType type;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic) CGFloat size;

@property (nonatomic, readonly) BOOL animating;

- (void)startAnimating;
- (void)stopAnimating;


@end
