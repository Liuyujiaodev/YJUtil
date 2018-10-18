//
//  YLRSAUtil.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/6/6.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLRSAUtil : NSObject

+ (NSDictionary*_Nullable)decodeWithStr:(NSString*_Nullable)str;
+ (NSDictionary*)encodeDic:(NSDictionary*)dic;

@end
