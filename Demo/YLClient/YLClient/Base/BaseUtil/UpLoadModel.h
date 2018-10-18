//
//  YMUpLoadModel.h
//  DaoDao
//
//  Created by apple on 14-8-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UpLoadType) {
    UpLoadTypeImage = 1,
    UpLoadTypeVideo = 2,
};
@interface UpLoadModel : NSObject

+ (void)uploadImage:(UIImage*)image success:(void(^)(NSString*))success failure:(void(^)(NSError *))failure;
+ (void)uploadData:(NSData*)data type:(UpLoadType)type success:(void(^)(NSString*))success failure:(void(^)(NSError *))failure progress:(void(^)(int64_t completedBytesCount, int64_t totalBytesCount))process;
@end
