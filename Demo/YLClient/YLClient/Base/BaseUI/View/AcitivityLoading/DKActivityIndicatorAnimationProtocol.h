//
//  DKActivityIndicatorAnimationProtocol.h
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DKActivityIndicatorAnimationProtocol <NSObject>

- (void)setupAnimationInLayer:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)tintColor;

@end
