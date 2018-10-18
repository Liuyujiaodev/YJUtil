//
//  DKActivityIndicatorView.m
//  DKActivityIndicator
//
//  Created by qiangxiao on 16/7/5.
//  Copyright © 2016年 xiaoqiang. All rights reserved.
//

#import "DKActivityIndicatorView.h"
#import "DKActivityIndicatorAnmationView.h"

#define kDGActivityIndicatorDefaultSize 60

@interface DKActivityIndicatorView ()

@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *functionButton;

@end

@implementation DKActivityIndicatorView

- (instancetype)initActivityIndicatorViewWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle buttonType:(DKActivityIndicatorButtonActionType)buttonType {
    if (self = [super initWithFrame:CGRectMake(0, 0, APPWidth, APPHeight)]) {
        self.backgroundColor = [UIColor whiteColor];
        [self createActivityIndicatorViewWithTitle:title buttonTitle:buttonTitle buttonType:buttonType];
    }
    return self;
}

- (void)createActivityIndicatorViewWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle buttonType:(DKActivityIndicatorButtonActionType)buttonType{
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(APPWidth - 60, 10, 60, 80)];
    [self.deleteButton setImage:[UIImage imageNamed:@"activityIndicatorDelete"] forState:UIControlStateNormal];
    self.deleteButton.imageEdgeInsets = UIEdgeInsetsMake((80 - 40) / 2, (60 - 40) / 2, (80 - 40) / 2, (60 - 40) / 2);
    [self.deleteButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    DKActivityIndicatorAnmationView *anmationView = [[DKActivityIndicatorAnmationView alloc] initWithType:DKBallClipRotateAnimation tintColor:RGBColor(56, 170, 249)];
    [self addSubview:anmationView];
    [anmationView startAnimating];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((APPWidth - 92/2) / 2, 206 * APPHeight / 667 + (kDGActivityIndicatorDefaultSize - 33) / 2, 92/2, 33)];
    logoImageView.image = [UIImage imageNamed:@"activityIndicator_logo"];
    [self addSubview:logoImageView];

    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,206 * APPWidth / 667 + kDGActivityIndicatorDefaultSize + 42, APPWidth, 18.0f)];
    self.stateLabel.text = title;
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.font = [UIFont systemFontOfSize:18.0f];
    self.stateLabel.textColor = RGBColor(94, 94, 94);
    [self addSubview:self.stateLabel];
    
    self.functionButton = [[UIButton alloc] initWithFrame:CGRectMake((APPWidth - 166/2) / 2, self.stateLabel.bottom + 52/2, 166/2, 52/2)];
    self.functionButton.backgroundColor = [UIColor whiteColor];
    [self.functionButton setTitleColor:RGBColor(94, 94, 94) forState:UIControlStateNormal];
    [self.functionButton setTitle:buttonTitle forState:UIControlStateNormal];
    self.functionButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.functionButton.layer.cornerRadius = 5.0f;
    self.functionButton.layer.borderColor = RGBColor(188, 188, 188).CGColor;
    self.functionButton.layer.borderWidth = 0.5f;
    
    if (buttonType == DKActivityIndicatorButtonActionTypeForBack) {
        [self.functionButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    } else if (buttonType == DKActivityIndicatorButtonActionTypeForRefresh) {
        [self.functionButton addTarget:self action:@selector(functionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:self.functionButton];
}

- (void)backButtonAction {
    if ([self.delegate respondsToSelector:@selector(activityIndicatorBackAction)]) {
        [self.delegate activityIndicatorBackAction];
    }
}
- (void)functionButtonAction {
    if ([self.delegate respondsToSelector:@selector(activityIndicatorRefreshAction)]) {
        [self.delegate activityIndicatorRefreshAction];
    }
}
- (void)removeActivityIndicatorView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });
}


- (void)setShowTitle:(NSString *)showTitle {
    _showTitle = showTitle;
    self.stateLabel.text = showTitle;
}
- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.functionButton setTitle:buttonTitle forState:UIControlStateNormal];
}

@end
