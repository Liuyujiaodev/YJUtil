//
//  YLLivenessModel.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/9/27.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLivenessModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@implementation YLLivenessModel

+ (void)saveImages:(NSArray*)imageArray videoData:(NSData*)videoData productId:(NSString*)productId {
    NSMutableArray* imageDataArray = [NSMutableArray array];
    for (UIImage* img in imageArray) {
        [imageDataArray addObject:UIImageJPEGRepresentation(img, 0.8)];
    }
    NSString* imagePath = [Util filePathForDocument:@"image" folerId:productId];
    [imageDataArray writeToFile:imagePath atomically:YES];
    
    NSString* videoPath = [Util filePathForDocument:@"video" folerId:productId];
    [videoData writeToFile:videoPath atomically:YES];
}

+ (NSData*)getCompressVideoWithProductId:(NSString*)productId {
    NSString* videoPath = [Util filePathForDocument:@"video" folerId:productId];
    NSData* videoData = [NSData dataWithContentsOfFile:videoPath];
    return videoData;
}
+ (NSArray*)getImageArrayWithProductId:(NSString*)productId {
    NSString* imagePath = [Util filePathForDocument:@"image" folerId:productId];
    NSArray* imageDataArray = [NSArray arrayWithContentsOfFile:imagePath];
    NSMutableArray* imgArray = [NSMutableArray array];
    for (NSData* data in imageDataArray) {
        [imgArray addObject:[UIImage imageWithData:data]];
    }
    return imgArray;
}
+ (void)deleteAllWithProductId:(NSString*)productId {
    NSString* imagePath = [Util filePathForDocument:@"image" folerId:productId];
    NSString* videoPath = [Util filePathForDocument:@"video" folerId:productId];

    [Util removeFileAtPath:imagePath];
    [Util removeFileAtPath:videoPath];
}

+ (BOOL)isExistImageProduct:(NSString*)productId {
    if ([self getImageArrayWithProductId:productId].count > 0) {
        return YES;
    }
    return NO;
}
@end
