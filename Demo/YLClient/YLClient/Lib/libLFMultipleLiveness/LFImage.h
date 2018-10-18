//
//  LFImage.h
//  LFLivenessDetector
//
//  Copyright (c) 2017-2018 LINKFACE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LFLivenessEnumType.h"

@interface LFImage : NSObject

/**
 *  图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  图片在动作序列中的位置, 0为第一个
 */
@property (nonatomic, assign) int iIndex;

/**
 *  图片所属的检测模块类型
 */
@property (nonatomic, assign) LivefaceDetectionType iDetectionType;

@end
