//
//  YLASEUtil.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/9/6.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLASEUtil : NSObject

+ (NSDictionary*_Nullable)decodeWithStr:(NSString*_Nullable)str;
+ (NSDictionary*)encodeDic:(NSDictionary*)dic;

@end
