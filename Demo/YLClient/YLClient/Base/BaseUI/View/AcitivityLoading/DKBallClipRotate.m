//
//  DKBallClipRotate.m
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import "DKBallClipRotate.h"


@implementation DKBallClipRotate

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor {
    CGFloat circleSize = size.width;
    
    CGFloat oX = (APPWidth - circleSize) / 2.0f;
    CGFloat oY =  (APPHeight - 140) / 2;
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    CGFloat lineWidth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(size.width / 2, size.height / 2) radius:size.width / 2 startAngle:(-3 * M_PI_4) endAngle:(-M_PI_4) clockwise:NO];
    circle.fillColor = nil;
    circle.strokeColor = tintColor.CGColor;
    circle.lineWidth = lineWidth;
    circle.backgroundColor = nil;
    circle.path = path.CGPath;
    
    
    CGRect frame = CGRectMake(oX, oY, size.width, size.height);
    circle.frame = frame;
    [layer addSublayer:circle];
    
    CAKeyframeAnimation *rotateAnimation =  [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.keyTimes = @[@0, @0.5, @1];
    rotateAnimation.values = @[@0, @M_PI, @(2 * M_PI)];
    
    CAAnimationGroup *transformAnimation = [CAAnimationGroup animation];
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transformAnimation.animations = @[rotateAnimation];
    transformAnimation.duration = 0.75;
    transformAnimation.repeatCount = HUGE_VALF;
    transformAnimation.removedOnCompletion = NO;
    
    [circle addAnimation:transformAnimation forKey:@"animation"];
}


@end
