//
//  YLASEUtil.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/9/6.
//  Copyright © 2018年 yunli. All rights reserved.
//



#import "YLASEUtil.h"
#import "ASEUtil.h"
#import "Base64.h"

@implementation YLASEUtil

+ (NSDictionary*_Nullable)decodeWithStr:(NSString*_Nullable)str {
//    str = @"AyCCGxwcU9e9Js24U8nsXjI1jnpM13tSMmWobjOnoSRoOFQvGUFbp0/8Daqq7L3hzaEcwSZX7xXXkatUMbmSOp5oe+yPPEDfvWSg+l/kyUW2LY+qrf2ygEyD8aARGltMJcR9ymVF9Csza86Xu4hkAg==";

    NSData* data = [str base64DecodedData];
    NSString* jsonStr = [ASEUtil AES256DecryptWithData:data];
    NSError* error = nil;
    NSDictionary* dic = [[NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                                                   options:NSJSONReadingMutableContainers
                                                     error:&error] mutableCopy];
    return dic;
}

+ (NSDictionary*)encodeDic:(NSDictionary*)dic {
    NSError *parseError = nil;
    //前端先把数据格式化成json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *base64Str = [ASEUtil AES256EncryptWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary* finalDic = [NSDictionary dictionaryWithObject:base64Str forKey:@"requestAesData"];
    return finalDic;
}

@end
