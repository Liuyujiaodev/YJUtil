//
//  YLLivenessStartController.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/8/27.
//  Copyright © 2018年 yunli. All rights reserved.
//

#define kIconHeight      70
#define kLabelHeight     40

#import "YLLivenessStartController.h"
#import "LFLivefaceViewController.h"
#import "LFMultipleLivenessController.h"
#import "LFAlertView.h"
#import "YLLivenessResultController.h"
#import "YLLivenessModel.h"

@interface YLLivenessStartController () <LFMultipleLivenessDelegate, LFAlertViewDelegate>

@property (nonatomic, weak) LFMultipleLivenessController *multipleLiveVC;

@end

@implementation YLLivenessStartController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navBar setBackgroundColor:[UIColor whiteColor]];
    [self yl_createUI];
}

- (void)yl_createUI {
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(APPWidth - 21 - 26, 51, 21, 21)];
    [btn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(yl_multiLivenessDidCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UILabel*  titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 96, APPWidth - 60, 30)];
    titleLabel.textColor = kCOMMON_COLOR;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = kCOMMON_FONT_MEDIUM_25;
    titleLabel.text = @"开始申请";
    [self.view addSubview:titleLabel];
    
    UIView* locationView = [self yl_viewWithIcon:@"liveness1" title:@"准备人脸识别" desc:@"请本人在光线充足下操作"];
    locationView.top = titleLabel.bottom + 40;
    [self.view addSubview:locationView];
    
    UIView* contactView = [self yl_viewWithIcon:@"liveness2" title:@"提交申请资料" desc:@"提交申请资料，等待审核通过"];
    contactView.top = locationView.bottom + 40;
    [self.view addSubview:contactView];
    
    
    UIButton* agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(12.5, self.view.height - 22 - 47, APPWidth - 25, 47)];
    [agreeBtn setImage:[UIImage imageNamed:@"btn_agree"] forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(yl_startBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
}

- (void)yl_startBtnAction {
    [self.navigationController presentViewController:[self yl_setupMultiController] animated:NO completion:^{
        [self yl_restart];
    }];
}

- (void)yl_restart
{
    [self.multipleLiveVC restart];
}

- (void)yl_handleResultWithData:(NSData *)data lfImages:(NSArray *)arrLFImage lfVideoData:(NSData *)lfVideoData SDKVersion:(NSString *)strVersion
{
    NSMutableArray* imgArray = [NSMutableArray array];
    for (LFImage* lfImage in arrLFImage) {
        [imgArray addObject:lfImage.image];
    }
    [YLLivenessModel saveImages:imgArray videoData:lfVideoData productId:self.productId];
    
    [YLLivenessResultController presentLivenessScanResultController:self.multipleLiveVC images:[YLLivenessModel getImageArrayWithProductId:self.productId] videoData:[YLLivenessModel getCompressVideoWithProductId:self.productId] productId:self.productId];
}

#pragma - mark LFMultipleLivenessDelegate

- (void)yl_multiLivenessDidStart
{
    
}

- (void)yl_multiLivenessDidSuccessfulGetData:(NSData *)encryTarData lfImages:(NSArray *)arrLFImage lfVideoData:(NSData *)lfVideoData
{
    [self yl_handleResultWithData:encryTarData lfImages:arrLFImage lfVideoData:lfVideoData SDKVersion:[LFLivefaceViewController getSDKVersion]];
}

- (void)yl_multiLivenessDidFailWithType:(LFMultipleLivenessError)iErrorType DetectionType:(LFDetectionType)iDetectionType DetectionIndex:(NSInteger)iIndex Data:(NSData *)encryTarData lfImages:(NSArray *)arrLFImage lfVideoData:(NSData *)lfVideoData
{
    //第一个动作跟丢不弹框
    if (iErrorType == LFMultipleLivenessFaceChanged && iIndex == 0) {
        [self yl_restart];
        return;
    }
    switch (iErrorType) {
            
        case LFMultipleLivenessInitFaild: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"算法SDK初始化失败：可能是授权文件或模型路径错误，SDK权限过期，包名绑定错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
            
        case LFMultipleLivenessCameraError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"相机权限获取失败或权限被拒绝" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
            
        case LFMultipleLivenessFaceChanged: {
            LFAlertView *alert = [[LFAlertView alloc] initWithTitle:@"采集失败，再试一次吧" delegate:self];
            [alert showOnView:[UIApplication sharedApplication].keyWindow];
        }
            break;
            
        case LFMultipleLivenessTimeOut: {
            LFAlertView *alert = [[LFAlertView alloc] initWithTitle:@"动作超时" delegate:self];
            [alert showOnView:[UIApplication sharedApplication].keyWindow];
            
        }
            break;
            
        case LFMultipleLivenessWillResignActive: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"活体检测失败, 请保持前台运行,点击确定重试" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
            break;
            
        case LFMultipleLivenessInternalError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"内部错误" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
            
        case LFMultipleLivenessBadJson: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"bad json"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
            break;
            
        case LFMultipleLivenessBundleIDError: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"未替换包名或包名错误"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
            break;
        case LFMultipleLivenessAuthExpire: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"授权文件过期"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        default:
            break;
    }
}

- (void)yl_multiLivenessDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma - mark AlertViewDelegate

- (void)alertView:(LFAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self.multipleLiveVC cancel];
        }
            break;
        case 1: {
            [self yl_restart];
        }
            break;
            
        default: {
            [self.multipleLiveVC cancel];
        }
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self.multipleLiveVC cancel];
        }
            break;
        case 1: {
            [self yl_restart];
        }
            break;
            
        default: {
            [self.multipleLiveVC cancel];
        }
            break;
    }
}

#pragma mark - 延迟加载
- (LFMultipleLivenessController *)yl_setupMultiController
{
    LFMultipleLivenessController *multipleLiveVC = [[LFMultipleLivenessController alloc] init];
    self.multipleLiveVC = multipleLiveVC;
    multipleLiveVC.delegate = self;
    [multipleLiveVC setVoicePromptOn:YES];
   

    NSDictionary *dictJson = @{@"sequence":  @[@"BLINK", @"MOUTH", @"NOD", @"YAW"],
                               @"outType": @"video",
                               @"Complexity": @(LIVE_COMPLEXITY_NORMAL)};
    
    NSString* strJson = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dictJson options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [multipleLiveVC setJsonCommand:strJson];
    return multipleLiveVC;
}


- (UIView*)yl_viewWithIcon:(NSString*)iconName title:(NSString*)title desc:(NSString*)desc {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, 56)];
    
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 56, 56)];
    iconView.image = [UIImage imageNamed:iconName];
    [view addSubview:iconView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right + 23, 0, 200, 30)];
    titleLabel.text = title;
    titleLabel.font = kCOMMON_FONT_LIGHT_22;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = RGBColor(63, 63, 63);
    [view addSubview:titleLabel];
    
    UILabel* descLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom + 5, 200, 19)];
    descLabel.text = desc;
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.font = kCOMMON_FONT_LIGHT_13;
    descLabel.textColor = RGBColor(74, 74, 74);
    [view addSubview:descLabel];
    return view;
}

@end
