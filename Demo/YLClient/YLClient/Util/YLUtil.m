//
//  YLUtil.m
//  YLZhiNengYun
//
//  Created by 刘玉娇 on 2017/10/16.
//  Copyright © 2017年 yunli. All rights reserved.
//

#import "YLUtil.h"
#import "Base64.h"

@implementation YLUtil

+ (BOOL)isLogin {
    
    if ([YLUserDataManager getCuid] != nil && ![[YLUserDataManager getCuid] isEmptyStr]) {
        return YES;
    }
    return NO;
}

+ (void)showAlertView:(UIViewController*)vc title:(NSString*)title message:(NSString*)msg okAction:(NSString*)ok cancelAction:(NSString*)cancel okHandler:(void (^ __nullable)(UIAlertAction *action))okHandler cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    if (ok && ![ok isEmptyStr]) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ok style:UIAlertActionStyleDefault handler:okHandler];
        [alertController addAction:okAction];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:cancelHandler];
    [alertController addAction:cancelAction];
    [vc presentViewController:alertController animated:YES completion:nil];
    
}

+ (CAGradientLayer *)setGradualChangingColor:(UIView *)view fromColor:(UIColor*)fromColor toColor:(UIColor *)toColor{
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

+ (CAGradientLayer *)setHorizontalChangingColor:(UIView *)view fromColor:(UIColor*)fromColor toColor:(UIColor *)toColor{
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    //(0,0)(0,0)不渐变   (0,0)(0,1)竖直上到下 (0,0)(1,0)左到右 (0,0)(1,1)左上到右下
    //(1,0)(0,0)水平从左到右 (1,0)(0,1)右上到左下 (1,0)(1,0)无 (1,0)(1,1)上到下
    //(0,1)(0,0)下到上  (0,1)(0,1)无 (0,1)(1,0)左下到右上 (0,1)(1,1)左到右
    //(1,1)(0,0)左上到右下  (1,1)(0,1) (1,1)(1,0) (1,1)(1,1)
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

+ (CAGradientLayer *)setCorNerChangingColor:(UIView *)view fromColor:(UIColor*)fromColor toColor:(UIColor *)toColor{
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    //(0,0)(0,0)不渐变   (0,0)(0,1)竖直上到下 (0,0)(1,0)左到右 (0,0)(1,1)左上到右下
    //(1,0)(0,0)水平从左到右 (1,0)(0,1)右上到左下 (1,0)(1,0)无 (1,0)(1,1)上到下
    //(0,1)(0,0)下到上  (0,1)(0,1)无 (0,1)(1,0)左下到右上 (0,1)(1,1)左到右
    //(1,1)(0,0)左上到右下  (1,1)(0,1) (1,1)(1,0) (1,1)(1,1)
    gradientLayer.startPoint = CGPointMake(1, 1);
    gradientLayer.endPoint = CGPointMake(0, 0);
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

+ (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMidY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMidY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

+ (NSMutableAttributedString*)attributeStrWithStr:(NSString*)str withBeforFont:(UIFont*)font afterFont:(UIFont*)afterFont {
    if (str) {
        NSMutableAttributedString* attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [str length]-1)];
        [attributeStr addAttribute:NSFontAttributeName value:afterFont range:NSMakeRange([str length]-1, 1)];
        return attributeStr;
    }
    return @"";
}


+ (NSMutableAttributedString*)attributeStrWithStr:(NSString*)str {
    if (str) {
        NSMutableAttributedString* attributeStr = [self attributeStrWithStr:str withBeforFont:kCOMMON_FONT_MEDIUM_30 afterFont:kCOMMON_FONT_MEDIUM_16];
        return attributeStr;
    }
    return @"";
}

+ (BOOL)isToday:(NSString*)timestamp {
    NSString* time = [Util convertDate:[NSNumber numberWithLong:timestamp.longLongValue] formatString:@"yyyy-MM-dd" ];
    NSString* today = [self getCurrentDate];
    if ([time isEqualToString:today]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getCurrentDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

+ (NSString*)timeFormat:(NSString*)timestamp {
    NSInteger intevalTime = [[NSDate date] timeIntervalSince1970] - [timestamp longLongValue];
    NSInteger hours = intevalTime / 60 / 60;
    if (hours >= 24) {
        return [NSString stringWithFormat:@"%ld天", hours / 24];
    } else if (hours > 0) {
        return [NSString stringWithFormat:@"%ld小时", hours];
    } else {
        return [NSString stringWithFormat:@"%ld分钟", intevalTime/60];
    }
}

+ (NSString*)convertDate:(NSNumber*)timestamp formatString:(NSString*)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timestamp longValue]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString*)dateFormat:(NSString*)timestamp {
    NSDate *yesterdayDate = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *yesterday = [formatter stringFromDate:yesterdayDate];
    NSString* dateStr = [Util convertDate:[NSNumber numberWithLong:timestamp.longLongValue] formatString:@"yyyy-MM-dd"];
    
    NSDate *tomorrowData = [NSDate dateWithTimeIntervalSinceNow:+(24*60*60)];
    NSString* tomorrow = [formatter stringFromDate:tomorrowData];
    
    if ([dateStr isEqualToString:[self getCurrentDate]]) {
        return @"今天";
    } else if ([dateStr isEqualToString:yesterday]) {
        return @"昨天";
    } else if ([dateStr isEqualToString:tomorrow]) {
        return @"明天";
    } else {
        return [Util convertDate:[NSNumber numberWithLong:[timestamp longLongValue]] formatString:@"yyyy-MM-dd"];
    }
}

+ (NSArray*)jsonArrayWithStr:(NSString*)str {
    NSError* error = nil;
    NSMutableArray* array = [NSMutableArray array];
    id object = [[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
                                                 options:NSJSONReadingAllowFragments
                                                   error:&error] mutableCopy];
    if ([object isKindOfClass:[NSArray class]]) {
        [array addObjectsFromArray:object];
    } else if ([object isKindOfClass:[NSString class]]){
        [array addObject:object];
    }
    return array;
}

+ (NSString*)jsonStrWithArray:(NSArray*)array {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+(NSString*)getStringFromConfig:(NSString*)str {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"CommonStrConfig" ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    return [dic stringWithKey:str];
}

+ (UIFont*)fontWithName:(NSString*)name size:(CGFloat)fontSize {
    UIFont* font = [UIFont fontWithName:name size:fontSize];
    if (font) {
        return font;
    } else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

+ (void)getBtnAuthFromServer {
    //    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    //    [params setObject:[YLUserDataManager getAid] forKey:@"aid"];
    //    [[YLHttpRequest sharedInstance] sendRequest:YL_API_GET_BTN_AUTH params:params success:^(NSDictionary *dic) {
    //        [[NSUserDefaults standardUserDefaults] setObject:[dic arrayWithKey:@"data"] forKey:kBUTTON_AUTH];
    //    } requestFailure:^(NSDictionary *dic) {
    //
    //    } failure:^(NSError *error) {
    //
    //    }];
}

+ (NSArray*)getBtnAuthId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kBUTTON_AUTH];
}

+ (BOOL)checkLocation {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return YES;
    } else {
        return NO;
    }
}

@end

