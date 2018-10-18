//
//  YMWebController.h
//  YiMei
//
//  Created by apple on 14-10-30.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
// web 页面

#import <UIKit/UIKit.h>
//#import "WebViewJavascriptBridge.h"

@interface YMWebController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *shareUrl;//分享链接
@property (nonatomic, strong) NSString *shareName;//分享标题
@property (nonatomic, assign) BOOL hiddenShareButton;
@property (nonatomic, assign) BOOL isComplain;

@property (nonatomic, strong) UIView *bar;
@property (nonatomic, strong) UIImageView *barImageView;
@property (nonatomic, copy) NSString *shareImageUrl;//分享图片
@property (nonatomic, strong) NSString *shareDesc;//分享描述
@property (nonatomic, strong) UILabel *titleLabel;

//服务协议签署
@property (nonatomic, copy) NSString* agreement_id;
@property (nonatomic, assign) BOOL isDismiss;

//如果isLogin为yes，则是从登陆页面过来的，返回的时候要把suid清掉，否则点击拨打客服电话，可能会弹同意服务协议页面
@property (nonatomic, assign) BOOL isLogin;
+ (void)setUserAgent;

@end
