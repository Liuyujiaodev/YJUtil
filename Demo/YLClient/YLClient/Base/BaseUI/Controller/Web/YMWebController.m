//
//  YMWebController.m
//  YiMei
//
//  Created by apple on 14-10-30.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import "YMWebController.h"
//#import "WebViewJavascriptBridge.h"

@interface YMWebController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@property (nonatomic, strong) UIImage* shareImage;
//@property WebViewJavascriptBridge* bridge;
@end


@implementation YMWebController

#pragma mark - user agent

+ (void)setUserAgent {
    NSString *oldAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSRange range = [oldAgent rangeOfString:@"rxzny_ios"];
    
    NSString* userAgent = @"rxzny_ios";
    if (range.location != NSNotFound && range.length != 0) {
        oldAgent = [oldAgent stringByReplacingCharactersInRange:NSMakeRange(range.location, oldAgent.length - range.location) withString:@""];
    }
    
    NSString *newAgent = [oldAgent stringByAppendingString:userAgent];
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavBar];
    [self createWebPage];
    self.view.backgroundColor = RGBColor(246, 246, 246);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.shareImageUrl]];
        self.shareImage  = [UIImage imageWithData:data];
    });

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark
#pragma mark - 创建web页面

- (void)createWebPage {
    NSString *newUrl = self.url;
    
//    // url后面拼接suid
//    if ([YMUtil getSuid] != nil && ![[YMUtil getSuid] isEqualToString:@""]) {
//        NSRange range = [newUrl rangeOfString:@"?"];
//        if (range.location != NSNotFound && range.length != 0) {
//            newUrl = [newUrl stringByAppendingFormat:@"&suid=%@", [YMUtil getSuid]];
//        } else {
//            newUrl = [newUrl stringByAppendingFormat:@"?suid=%@", [YMUtil getSuid]];
//        }
//    }
//
//    if ([YMUtil getCurrentShopId] != nil && ![[YMUtil getCurrentShopId] isEqualToString:@""]) {
//        NSRange range = [newUrl rangeOfString:@"?"];
//        if (range.location != NSNotFound && range.length != 0) {
//            newUrl = [newUrl stringByAppendingFormat:@"&studio_id=%@", [YMUtil getCurrentShopId]];
//        } else {
//            newUrl = [newUrl stringByAppendingFormat:@"?studio_id=%@", [YMUtil getCurrentShopId]];
//        }
//    }
    
    self.url = newUrl;
    DLog(@"url:%@",newUrl);
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.bar.bottom, APPWidth, APPHeight-self.bar.bottom)];
    self.webView.delegate = self;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];

    [self.webView loadRequest:request];
    self.webView.scalesPageToFit = YES;
    self.webView.mediaPlaybackAllowsAirPlay = NO;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    [self.view addSubview:self.webView];
    NSString *oldAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"-------userAgent:-%@",oldAgent);
//    [WebViewJavascriptBridge enableLogging];
//
//    
//    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
//    
//    [self registerHandler];

}


#pragma mark 
#pragma mark - UIWebViewDelegate 方法

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((APPWidth - 30)/2, (APPHeight - APP_STATUS_NAVBAR_HEIGHT- 30)/2, 30, 30)];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.activityView startAnimating];
    [self.view addSubview:self.activityView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.titleLabel.text = self.title;
//    NSString* jsCode = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://d.beauty.xiaolinxiaoli.com/app_js.txt"] encoding:NSUTF8StringEncoding error:nil];
//    [webView stringByEvaluatingJavaScriptFromString:jsCode];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
}


#pragma mark
#pragma mark - create nav bar

- (void)createNavBar {
    CGFloat height = kDevice_Is_iPhoneX ? 88 : 64;

    self.bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, height)];
    self.bar.backgroundColor = kCOMMON_COLOR;
    [self.view addSubview:self.bar];
    
    UIButton* backBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, self.bar.height - 40, 75, 37)];
    [backBtn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 5, 8, 25)];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [self.bar addSubview:backBtn];

    if (!self.hiddenShareButton) {
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(APPWidth - 14 - 50, 15, 50, 50)];
        [rightButton setImage:[UIImage imageNamed:@"lockProject_icon"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        [self.bar addSubview:rightButton];
    }
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, self.bar.height - 33 - 5, APPWidth-140, 33)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = kCOMMON_FONT_MEDIUM_18;
    self.titleLabel.text = APP_Name;
    [self.bar addSubview:self.titleLabel];

}


#pragma mark
#pragma mark - 点击nav上的左右按钮触发的事件

- (void)leftButtonAction {
    if (self.webView.canGoBack) {
        [self.webView goBack];
        
        UIButton *btn = (UIButton *)[self.bar viewWithTag:100];
        if (!btn) {
            UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 33, 42, 14)];
            closeButton.tag = 100;
            [closeButton setImage:[UIImage imageNamed:@"nav_close_button"] forState:UIControlStateNormal];
            [closeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
            
            [self.bar addSubview:closeButton];
        }
    } else {
        
        [self.webView stopLoading];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeButtonAction {

    [self.webView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareAction {

}

- (void)registerHandler {
    //同意协议
   
}

@end
