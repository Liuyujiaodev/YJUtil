//
//  YLLoadModel.h
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/26.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, YLLoadStatus) {
    YLLoadStatusNoRequest = 1,//未申请
    YLLoadStatusInWrite = 2,//资料填写中
    YLLoadStatusInCheck = 3,//资料审核中
    YLLoadStatusSupply = 4,//审核-补件
    YLLoadStatusPass = 5,//审核通过
    YLLoadStatusRefund = 6,//审核不通过
    YLLoadStatusInCheckOrder = 7,//订单审批中
    YLLoadStatusLoad = 8,//打款完成
    YLLoadStatusLoadRefund = 9,//订单审批拒绝
    YLLoadStatusFinsh = 10, //还款完成
    YLLoadStatusOverDue = 11//还款有逾期
};

@interface YLLoadModel : NSObject

@property (nonatomic, copy) NSString* channelId;
@property (nonatomic, copy) NSString* productId;

@property (nonatomic, copy) NSString* cid;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* desc;
@property (nonatomic, copy) NSString* price;
@property (nonatomic, copy) NSString* rate;
@property (nonatomic, copy) NSString* number;

@property (nonatomic, assign) BOOL needCantact;
@property (nonatomic, assign) BOOL needLocation;
@property (nonatomic, assign) BOOL submitCheckOwe;
@property (nonatomic, assign) BOOL notApply;
@property (nonatomic, assign) BOOL whetherApply;
@property (nonatomic, assign) BOOL onlyMembers;//仅会员申请
@property (nonatomic, copy) NSString* submitUrl;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* statusTitles;

+ (YLLoadModel*)modelWithDic:(NSDictionary*)dic;
@end
