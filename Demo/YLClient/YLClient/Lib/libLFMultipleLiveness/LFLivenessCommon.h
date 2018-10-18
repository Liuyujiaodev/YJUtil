//
//  LFLivenessCommon.h
//  LFLivenessController
//
//  Copyright (c) 2017-2018 LINKFACE Corporation. All rights reserved.
//

#ifndef LFLivenessCommon_h
#define LFLivenessCommon_h


#define kSTColorWithRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

#define kLFScreenWidth [UIScreen mainScreen].bounds.size.width
#define kLFScreenHeight [UIScreen mainScreen].bounds.size.height

// iPhone X
#define LFiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define  LFStatusBarHeight      (LFiPhoneX ? 44.f : 20.f)
#define kTabBarHeight         (LFiPhoneX ? (49.f+34.f) : 49.f)//83
#define LFStatusBarAndNavigationBarHeight  (LFiPhoneX ? 88.f : 64.f)
#define LFNavigationBarHeightMargin  (LFiPhoneX ? 24.f : 0.f)
#define LFTabbarSafeBottomMargin         (LFiPhoneX ? 34.f : 0.f)

#endif /* LFLivenessCommon_h */
