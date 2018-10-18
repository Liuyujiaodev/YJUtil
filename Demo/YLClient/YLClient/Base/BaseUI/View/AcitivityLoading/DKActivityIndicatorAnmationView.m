//
//  DKActivityIndicatorAnmationView.m
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import "DKActivityIndicatorAnmationView.h"
#import "DKActivityIndicatorAnimationProtocol.h"
#import "DKBallClipRotate.h"

#define kDGActivityIndicatorDefaultSize  60

@implementation DKActivityIndicatorAnmationView

#pragma mark init
- (id)initWithType:(DKActivityIndicatorAnimationType)type {
    return [self initWithType:type tintColor:[UIColor whiteColor] size:kDGActivityIndicatorDefaultSize];
}
- (id)initWithType:(DKActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor {
    return [self initWithType:type tintColor:tintColor size:kDGActivityIndicatorDefaultSize];
}
- (id)initWithType:(DKActivityIndicatorAnimationType)type tintColor:(UIColor *)tintColor size:(CGFloat)size {
    self = [super init];
    if (self) {
        _type = type;
        _size = size;
        _tintColor = tintColor;
    }
    return self;
}


#pragma mark Methods
- (void)setupAnimation {
    self.layer.sublayers = nil;
    
    id<DKActivityIndicatorAnimationProtocol> animation = [DKActivityIndicatorAnmationView activityIndicatorAnimationForAnimationType:_type];
    
    if ([animation respondsToSelector:@selector(setupAnimationInLayer:withSize:tintColor:)]) {
        [animation setupAnimationInLayer:self.layer withSize:CGSizeMake(_size, _size) tintColor:_tintColor];
        self.layer.speed = 0.0f;
    }
}
- (void)startAnimating {
    if (!self.layer.sublayers) {
        [self setupAnimation];
    }
    self.layer.speed = 1.0f;
    _animating = YES;
}
- (void)stopAnimating {
    self.layer.speed = 0.0f;
    _animating = NO;
}


#pragma mark Setters
- (void)setType:(DKActivityIndicatorAnimationType)type {
    if (_type != type) {
        _type = type;
        
        [self setupAnimation];
    }
}
- (void)setSize:(CGFloat)size {
    if (_size != size) {
        _size = size;
        
        [self setupAnimation];
    }
}
- (void)setTintColor:(UIColor *)tintColor {
    if (![_tintColor isEqual:tintColor]) {
        _tintColor = tintColor;
        
        for (CALayer *sublayer in self.layer.sublayers) {
            sublayer.backgroundColor = tintColor.CGColor;
        }
    }
}

#pragma mark Getters
+ (id<DKActivityIndicatorAnimationProtocol>)activityIndicatorAnimationForAnimationType:(DKActivityIndicatorAnimationType)type {
    switch (type) {
        case DKBallClipRotateAnimation:
            return [[DKBallClipRotate alloc] init];
    }
    return nil;
}

@end
