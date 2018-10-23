//
//  YLCompanySettingUtil.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/8/28.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLCompanySettingUtil.h"

@implementation YLCompanySettingUtil

+ (NSString*)getCompanyCid {
    NSString* path = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"privateCompanySetting" ofType:@"plist"];

    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* companyDic = [dic dicWithKey:bundleId];
    if (companyDic && companyDic.allKeys.count > 0) {
        return [companyDic stringWithKey:@"cid"];
    }
    return nil;
}

+ (NSString*)getBaiduMap {
    NSString* path = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"privateCompanySetting" ofType:@"plist"];
    
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* companyDic = [dic dicWithKey:bundleId];
    if (companyDic && companyDic.allKeys.count > 0) {
        return [companyDic stringWithKey:@"baiduMapKey"];
    }
    return BAIDU_MAP_KEY;
}

+(NSString*)getLoginBgImageStr {
    NSString* path = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"privateCompanySetting" ofType:@"plist"];
    
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary* companyDic = [dic dicWithKey:bundleId];
    if (companyDic && companyDic.allKeys.count > 0) {
        return [companyDic stringWithKey:@"loginBg"];
    }
    return @"default";
}
@end
