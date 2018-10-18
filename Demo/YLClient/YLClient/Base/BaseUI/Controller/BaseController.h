//
//  BaseController.h
//  YLXD
//
//  Created by 刘玉娇 on 2017/10/9.
//  Copyright © 2017年 yj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseController : UIViewController

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIImageView* navBar;
@property (nonatomic, strong) UIButton* rightButton;
@property (nonatomic, strong) UIButton* rightButtonOnBellow;

@property (nonatomic, strong) UILabel* leftTitleLabel;
- (void)setTitle:(NSString*)title isRoot:(BOOL)isRoot;
- (void)setRightNavBtn:(NSString*)str;
- (void)setTitle:(NSString*)title isRoot:(BOOL)isRoot rightBtn:(NSString*)rightBtnStr;

- (void)alertErrorMsg:(id)dic;
-(void)rightButtonTouched;

- (void)requestError;
@end
