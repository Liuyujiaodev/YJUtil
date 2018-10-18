//
//  YLLivenessResultController.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/8/28.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLivenessResultController.h"
#import "LFImage.h"
#import "UpLoadModel.h"
#import "DKActivityIndicatorAnmationView.h"
#import "YLLivenessModel.h"

@interface YLLivenessResultController ()

@property (nonatomic, strong) NSData *videoData;
@property (nonatomic, copy) NSArray<UIImage *> *images;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString* productId;

@end

@implementation YLLivenessResultController

#pragma mark - Entry

+ (instancetype)presentLivenessScanResultController:(UIViewController *)controller images:(NSArray *)images videoData:(NSData *)videoData productId:(NSString*)productId
{
    YLLivenessResultController *viewController = nil;
    if (controller) {
        viewController = [[[self class] alloc] init];
        viewController.videoData = videoData;
        viewController.images = images;
        viewController.productId = productId;
        [controller presentViewController:viewController animated:YES completion:nil];
    }
    return viewController;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"正在上传" isRoot:NO];
    [self yl_createUI];
}

- (void)yl_createUI {
    DKActivityIndicatorAnmationView *anmationView = [[DKActivityIndicatorAnmationView alloc] initWithType:DKBallClipRotateAnimation tintColor:kCOMMON_COLOR size:60];
    [self.view addSubview:anmationView];
    [anmationView startAnimating];
                                   
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (APPHeight - 140) / 2 + 60 + 10, APPWidth, 20)];
    titleLabel.textColor = RGBColor(74, 74, 74);
    titleLabel.font = kCOMMON_FONT_REGULAR_14;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"请勿关闭应用";
    [self.view addSubview:titleLabel];
    
    UILabel* descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 10, APPWidth, 20)];
    descLabel.textColor = titleLabel.textColor;
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.font = titleLabel.font;
    descLabel.text = @"正在上传...请稍等";
    [self.view addSubview:descLabel];
    
    self.index = 0;
    [self yl_uploadImageAndVideo];
}

#pragma mark - 上传图片和video
- (void)yl_uploadImageAndVideo {
    __weak typeof(self) weakSelf = self;
    if (self.index < 4) {
        UIImage* image = self.images[self.index];
        [UpLoadModel uploadData:UIImageJPEGRepresentation(image, 1) type:UpLoadTypeImage success:^(NSString *url) {
            self.index++;
            //TODO图片url上传服务器
            DLog(@"------%ld-----%@",(long)self.index, url);
            [weakSelf yl_uploadImageAndVideo];
        } failure:^(NSError *error) {
            
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//            dispatch_main_async_safe((^{
//                self.processLabel.text = [NSString stringWithFormat:@"%.1f%%",5 * self.index + 5 * (float)(completedBytesCount / totalBytesCount * 0.2)];
//                CGFloat width = self.backProcessView.width * 0.05;
//                self.processView.width = width*self.index + width * (float)completedBytesCount / totalBytesCount;
//            }));

        }];
    } else {
        [UpLoadModel uploadData:self.videoData type:UpLoadTypeVideo success:^(NSString *url) {
            DLog(@"-----video-----%@", url);
            [YLLivenessModel deleteAllWithProductId:self.productId];
            //TODO 上传服务器跳到前端
        } failure:^(NSError *error) {
            
        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
//            dispatch_main_async_safe((^{
//                self.processLabel.text = [NSString stringWithFormat:@"%.1f%%", 20 + 80 * (float)(completedBytesCount / totalBytesCount)];
//                self.processView.width = self.backProcessView.width*0.2 + self.backProcessView.width * 0.8 * ((float)completedBytesCount / totalBytesCount);
//            }));

        }];
    }
}



@end
