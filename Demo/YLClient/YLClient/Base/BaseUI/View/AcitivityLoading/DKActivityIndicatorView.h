//
//  DKActivityIndicatorView.h
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DKActivityIndicatorButtonActionType) {
    DKActivityIndicatorButtonActionTypeForBack,
    DKActivityIndicatorButtonActionTypeForRefresh
};

@protocol DKActivityIndicatorDelegate <NSObject>

- (void)activityIndicatorRefreshAction;

- (void)activityIndicatorBackAction;

@end

@interface DKActivityIndicatorView : UIView

@property (nonatomic, strong) id <DKActivityIndicatorDelegate> delegate;

//显示文字
@property (nonatomic, strong) NSString *showTitle;

//修改底部button 文字
@property (nonatomic, strong) NSString *buttonTitle;

//init
- (instancetype)initActivityIndicatorViewWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle buttonType:(DKActivityIndicatorButtonActionType)buttonType;

//删除
- (void)removeActivityIndicatorView;

@end
