//
//  YLLoadModel.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/26.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLoadModel.h"

@implementation YLLoadModel
+ (YLLoadModel*)modelWithDic:(NSDictionary*)dic {
    YLLoadModel* model = [[YLLoadModel alloc] init];
    NSDictionary* descDic = [dic dicWithKey:@"desc3"];
    
    model.name = [dic stringWithKey:@"name"];
    model.price = [[descDic dicWithKey:@"priceMax"] stringWithKey:@"content"];
    model.desc = [dic stringWithKey:@"desc"];
    model.number = [[[descDic dicWithKey:@"applyCount"] stringWithKey:@"content"] stringByAppendingString:@"人申请"];
    model.rate = [[descDic dicWithKey:@"rateMin"] stringWithKey:@"content"];
    model.needCantact = [dic stringWithKey:@"phoneContacts"].intValue == 1 ? YES : NO;
    model.needLocation = [dic stringWithKey:@"position"].intValue == 1 ? YES : NO;
    model.submitCheckOwe = [dic stringWithKey:@"submitCheckOwe"].intValue == 1 ? YES : NO;
    model.whetherApply = [dic stringWithKey:@"whetherApply"].intValue == 1 ? NO : YES;
    model.notApply = [dic stringWithKey:@"notApply"].intValue == 1 ? YES : NO;
    model.onlyMembers = [dic stringWithKey:@"onlyMembers"].intValue == 1 ? YES : NO;
    model.submitUrl = [dic stringWithKey:@"submitUrl"];
    model.message = [dic stringWithKey:@"message"];
    model.status = [dic stringWithKey:@"status"];
    model.statusTitles = [dic stringWithKey:@"submitText"];
    model.productId = [dic stringWithKey:@"productId"];
    return model;
}

+ (YLLoadStatus)statusWithStauts:(NSInteger)status{
    YLLoadStatus clientStatus;
    switch (status) {
        case 1:
            clientStatus = YLLoadStatusNoRequest;
            break;
        case 2:
            clientStatus = YLLoadStatusInWrite;
            break;
        case 3:
            clientStatus = YLLoadStatusInCheck;
            break;
        case 4:
            clientStatus = YLLoadStatusSupply;
            break;
        case 5:
            clientStatus = YLLoadStatusPass;
            break;
        case 6:
            clientStatus = YLLoadStatusRefund;
            break;
        case 7:
            clientStatus = YLLoadStatusInCheckOrder;
            break;
        case 8:
            clientStatus = YLLoadStatusLoad;
            break;
        case 9:
            clientStatus = YLLoadStatusLoadRefund;
            break;
        case 10:
            clientStatus = YLLoadStatusFinsh;
            break;
        case 11:
            clientStatus = YLLoadStatusOverDue;
            break;
        default:
            break;
    }
    return clientStatus;
}

+ (NSString*)statusTitleWith:(NSInteger)status{
    NSString* clientStatus;
    switch (status) {
        case 1:
            clientStatus = @"未申请";
            break;
        case 2:
            clientStatus = @"资料填写中";
            break;
        case 3:
            clientStatus = @"资料审核中";
            break;
        case 4:
            clientStatus = @"补件";
            break;
        case 5:
            clientStatus = @"审核通过";
            break;
        case 6:
            clientStatus = @"审核不通过";
            break;
        case 7:
            clientStatus = @"订单审批中";
            break;
        case 8:
            clientStatus = @"打款完成";
            break;
        case 9:
            clientStatus = @"订单审批拒绝";
            break;
        case 10:
            clientStatus = @"还款完成";
            break;
        case 11:
            clientStatus = @"还款有逾期";
            break;
        default:
            break;
    }
    return clientStatus;
}

@end
