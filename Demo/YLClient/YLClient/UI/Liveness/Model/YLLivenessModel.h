//
//  YLLivenessModel.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/9/27.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLLivenessModel : NSObject

+ (void)saveImages:(NSArray*)imageArray videoData:(NSData*)videoData productId:(NSString*)productId;
+ (NSData*)getCompressVideoWithProductId:(NSString*)productId;
+ (NSArray*)getImageArrayWithProductId:(NSString*)productId;
+ (void)deleteAllWithProductId:(NSString*)productId;
+ (BOOL)isExistImageProduct:(NSString*)productId;
@end
