//
//  YMUpLoadModel.m
//  DaoDao
//
//  Created by apple on 14-8-14.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "UpLoadModel.h"
#import "UpYunFormUploader.h" //图片，小文件，短视频
#import "Base64.h"

@interface UpLoadModel()

@end

@implementation UpLoadModel

+ (void)uploadImage:(UIImage*)image success:(void(^)(NSString*))success failure:(void(^)(NSError *))failure  {
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    NSString *bucketName = @"yb-test";
    [up uploadWithBucketName:bucketName
                    operator:@"yanjun"
                    password:@"yunbei123"
                    fileData:UIImagePNGRepresentation(image)
                    fileName:nil
                     saveKey:[self getSaveKey]
             otherParameters:@{@"apps": @"app"}
                     success:^(NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传成功 responseBody：%@", responseBody);
                         NSLog(@"file url：https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]);
                         dispatch_async(dispatch_get_main_queue(), ^(){
                             success([NSString stringWithFormat:@"https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]]);
                         });
                         //主线程刷新ui
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         failure(error);
                     }
     
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                    }];
}

+ (void)uploadData:(NSData*)data type:(UpLoadType)type success:(void(^)(NSString*))success failure:(void(^)(NSError *))failure progress:(void(^)(int64_t completedBytesCount, int64_t totalBytesCount))process {
    UpYunFormUploader *up = [[UpYunFormUploader alloc] init];
    NSString* saveKey = [self getSaveKeyWithType:type];
    
    NSString *bucketName = @"yb-test";
    [up uploadWithBucketName:bucketName
                    operator:@"yanjun"
                    password:@"yunbei123"
                    fileData:data
                    fileName:nil
                     saveKey:saveKey
             otherParameters:@{@"apps": @"app"}
                     success:^(NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         NSLog(@"上传成功 responseBody：%@", responseBody);
                         NSLog(@"file url：https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]);
                         dispatch_async(dispatch_get_main_queue(), ^(){
                             success([NSString stringWithFormat:@"https://%@.b0.upaiyun.com/%@", bucketName, [responseBody objectForKey:@"url"]]);
                         });
                         //主线程刷新ui
                     }
                     failure:^(NSError *error,
                               NSHTTPURLResponse *response,
                               NSDictionary *responseBody) {
                         failure(error);
                     }
     
                    progress:^(int64_t completedBytesCount,
                               int64_t totalBytesCount) {
                        process(completedBytesCount,totalBytesCount);
                        NSString *progress = [NSString stringWithFormat:@"%lld / %lld", completedBytesCount, totalBytesCount];
                        NSString *progress_rate = [NSString stringWithFormat:@"upload %.1f %%", 100 * (float)completedBytesCount / totalBytesCount];
                    }];
}

+ (NSString*)getSaveKeyWithType:(UpLoadType)type {
    NSDate *d = [NSDate date];

    if (type == UpLoadTypeImage ) {
        return [NSString stringWithFormat:@"/%@/%d/%d/%.0f/%@.png", @"yl", [self getYear:d],[self getMonth:d],[[NSDate date] timeIntervalSince1970], [Util getRandomStr]];
    } else if (type == UpLoadTypeVideo) {
        return [NSString stringWithFormat:@"/%@/%d/%d/%.0f.mp4", @"yl", [self getYear:d],[self getMonth:d],[[NSDate date] timeIntervalSince1970]];
    }
    return nil;
}

+(NSString * )getSaveKey {
    return [self getSaveKeyWithType:UpLoadTypeImage];
    /**
     *	@brief	方式1 由开发者生成saveKey
     */
    
    /**
     *	@brief	方式2 由服务器生成saveKey
     */
    //    return [NSString stringWithFormat:@"/{year}/{mon}/{filename}{.suffix}"];
    
    /**
     *	@brief	更多方式 参阅 http://wiki.upyun.com/index.php?title=Policy_%E5%86%85%E5%AE%B9%E8%AF%A6%E8%A7%A3
     */
    
}

+ (int)getYear:(NSDate *) date{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int year=[comps year];
    return year;
}

+ (int)getMonth:(NSDate *) date{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSMonthCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    int month = [comps month];
    return month;
}


@end
