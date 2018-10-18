//
//  YLUtil.h
//  YLZhiNengYun
//
//  Created by 刘玉娇 on 2017/10/16.
//  Copyright © 2017年 yunli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLUtil : NSObject

+ (BOOL)isLogin;

+ (NSString*_Nullable)getRsaStr:(NSString*_Nullable)str;

+ (void)showAlertView:(UIViewController*_Nullable)vc title:(NSString*_Nullable)title message:(NSString*_Nullable)msg okAction:(NSString*_Nullable)ok cancelAction:(NSString*_Nullable)cancel okHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))okHandler cancelHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))cancelHandler;

+ (void)drawLinearGradient:(CGContextRef _Nullable )context
                      path:(CGPathRef _Nullable )path
                startColor:(CGColorRef _Nonnull )startColor
                  endColor:(CGColorRef _Nonnull )endColor;

+ (CAGradientLayer *_Nullable)setGradualChangingColor:(UIView *_Nullable)view fromColor:(UIColor*_Nullable)fromColor toColor:(UIColor *_Nullable)toColor;
+ (CAGradientLayer *_Nonnull)setHorizontalChangingColor:(UIView *_Nonnull)view fromColor:(UIColor*_Nullable)fromColor toColor:(UIColor *_Nullable)toColor;
+ (CAGradientLayer *_Nullable)setCorNerChangingColor:(UIView *_Nullable)view fromColor:(UIColor*_Nullable)fromColor toColor:(UIColor *_Nullable)toColor;

+ (NSMutableAttributedString*_Nonnull)attributeStrWithStr:(NSString*_Nullable)str withBeforFont:(UIFont*_Nonnull)font afterFont:(UIFont*_Nullable)afterFont;

+ (NSMutableAttributedString*_Nullable)attributeStrWithStr:(NSString*_Nullable)str;

+ (BOOL)isToday:(NSString*_Nonnull)timestamp;

+ (NSString*_Nullable)timeFormat:(NSString*_Nullable)timestamp;

+ (NSString*_Nullable)convertDate:(NSNumber*_Nullable)timestamp formatString:(NSString*_Nullable)format;

+ (UIFont*_Nullable)fontWithName:(NSString*_Nullable)name size:(CGFloat)fontSize;
+ (NSString*_Nullable)dateFormat:(NSString*_Nullable)timestamp;


+(NSString*_Nullable)getStringFromConfig:(NSString*_Nonnull)str;
+ (NSArray*_Nullable)jsonArrayWithStr:(NSString*_Nullable)str;
+ (NSString*_Nonnull)jsonStrWithArray:(NSArray*_Nonnull)array;

+ (void)getBtnAuthFromServer;
+ (NSArray*_Nullable)getBtnAuthId;
+ (BOOL)checkLocation;
@end

