//
//  LFLivenessDetector.h
//  LFLivenessDetector
//
//  Copyright (c) 2017-2018 LINKFACE Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LFLivenessDetectorDelegate.h"
#import "LFImage.h"

@interface LFLivenessDetector : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  初始化方法
 *
 *  @param dDurationPerModel    每个模块允许的最大检测时间,小于等于0时为不设置超时时间.
 *  @param strBundlePath        资源路径
 *  @param strLicensePath       license的路径
 *
 *  @return 活体检测器实例
 */
- (instancetype)initWithDuration:(double)dDurationPerModel
             resourcesBundlePath:(NSString *)strBundlePath
                     licensePath:(NSString *)strLicensePath;


/**
 *  活体检测器配置方法
 *
 *  @param delegate     回调代理
 *  @param queue        回调线程
 *  @param arrDetection 动作序列, 如 @[@(LIVE_BLINK) ,@(LIVE_MOUTH) ,@(LIVE_NOD) ,@(LIVE_YAW)] , 参照 LFLivenessEnumType.h
 */
- (void)setDelegate:(id <LFLivenessDetectorDelegate>)delegate
      callBackQueue:(dispatch_queue_t)queue
  detectionSequence:(NSArray *)arrDetection;

/**
 *  设置活体检测器默认输出方案及难易度, 可根据需求在 startDetection 之前调用使生效 , 且需要在调用setDelegate:callBackQueue:detectionSequence:之后调用.
 *
 *  @param iOutputType 活体检测成功后的输出方案, 默认为 LIVE_OUTPUT_SINGLE_IMAGE
 *  @param iComplexity 活体检测的复杂度, 默认为 LIVE_COMPLEXITY_NORMAL
 */
- (void)setOutputType:(LivefaceOutputType)iOutputType
           complexity:(LivefaceComplexity)iComplexity;

/**
 *  对连续输入帧进行人脸跟踪及活体检测
 *
 *  @param sampleBuffer    每一帧的图像数据
 *  @param faceOrientation 人脸的朝向
 */
- (void)trackAndDetectWithCMSampleBuffer:(CMSampleBufferRef)sampleBuffer
                         faceOrientation:(LivefaceOrientation)faceOrientation;


/**
 *  开始检测, 检测的输出方案以及难易程度为之前最近一次调用 setOutputType:complexity: 所指定方案及难易程度.
 */
- (void)startDetection;



/**
 *  取消检测
 */
- (void)cancelDetection;


/**
 *  获取SDK版本
 *
 *  @return SDK版本字符串信息
 */
+ (NSString *)getSDKVersion;


@end
