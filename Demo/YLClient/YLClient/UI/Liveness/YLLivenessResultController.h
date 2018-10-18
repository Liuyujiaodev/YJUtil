//
//  YLLivenessResultController.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/8/28.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "BaseEntityController.h"

@interface YLLivenessResultController : BaseEntityController

+ (instancetype)presentLivenessScanResultController:(UIViewController *)controller images:(NSArray *)images videoData:(NSData *)videoData productId:(NSString*)productId;

@end
