//
//  YLLoginController.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/24.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLoginController.h"
#import "YLLoadController.h"
#import "YLNavController.h"

#define NUMBERS @"0123456789n"
#define MAX_SECOND  60

@interface YLLoginController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField* phoneTextField;
@property (nonatomic, strong) UITextField* codeTextField;
@property (nonatomic, strong) UIButton* loginBtn;
@property (nonatomic, strong) UIButton* sendCodeBtn;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) NSInteger i;

@end

@implementation YLLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self yl_createUI];
}

#pragma mark - 请求接口
- (void)yl_getVerifyCode {
    if (self.phoneTextField.text.length != 11) {
        [self alertErrorMsg:@"手机号输入错误"];
        return;
    }
    self.i = MAX_SECOND;
    if (!self.phoneTextField.text || [self.phoneTextField.text isEqualToString:@""]) {
        [self alertErrorMsg:@"请填写手机号"];
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:self.phoneTextField.text forKey:@"phone"];
    [params setObject:[NSNumber numberWithInteger:3] forKey:@"type"];
    NSString* pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
    if (pushToken && ![pushToken isEmptyStr]) {
        [params setObject:pushToken forKey:@"pushToken"];
    }
    [[YLHttpRequest sharedInstance] sendRequest:YL_API_GET_VERIFYCODE params:params success:^(NSDictionary *dic) {
        if (@available(iOS 10.0, *)) {
            self.sendCodeBtn.enabled = NO;
            [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)self.i] forState:UIControlStateDisabled];

            [self.timer invalidate];
            self.timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
                if (self.i > 0) {
                    self.i--;
                    self.sendCodeBtn.enabled = NO;
                    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)self.i] forState:UIControlStateDisabled];
                } else {
                    self.sendCodeBtn.enabled = YES;
                    [self.timer invalidate];
                }
            }];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        } else {
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(yl_timerActoin:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        }

    } requestFailure:^(NSDictionary *dic) {
        if ([[dic stringWithKey:@"code"] isEqualToString:@"3001"]) {
            [self yl_requestCode];
        }
        [self alertErrorMsg:dic];
    } failure:^(NSError *error) {
        [self requestError];
    }];
}

- (void)yl_requestCode {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:self.phoneTextField.text forKey:@"phone"];
    [params setObject:[NSNumber numberWithInteger:4] forKey:@"type"];//type为4发送语音验证码
    [[YLHttpRequest sharedInstance] sendRequest:YL_API_GET_VERIFYCODE params:params success:^(NSDictionary *dic) {
        
    } requestFailure:^(NSDictionary *dic) {
        [self alertErrorMsg:dic];
    } failure:^(NSError *error) {
        [self requestError];
    }];
}
- (void)yl_timerActoin:(NSTimer*)timer {
    if (self.i > 0) {
        self.i--;
        self.sendCodeBtn.enabled = NO;
        [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)self.i] forState:UIControlStateDisabled];
    } else {
        self.sendCodeBtn.enabled = YES;
        [self.timer invalidate];
    }
}

- (void)yl_loginBtnAction {

    if (!self.phoneTextField.text || [self.phoneTextField.text isEqualToString:@""]) {
        [self alertErrorMsg:@"请填写手机号"];
        return;
    }
    if (!self.codeTextField.text || [self.codeTextField.text isEqualToString:@""]) {
        [self alertErrorMsg:@"请填写验证码"];
        return;
    }
    
    NSString* pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];

    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:self.phoneTextField.text forKey:@"phone"];
    [params setObject:self.codeTextField.text forKey:@"verifyCode"];
    [params setObject:[NSNumber numberWithInteger:3] forKey:@"platform"];
    if (pushToken) {
        [params setObject:pushToken forKey:@"pushToken"];
    }
    [[YLHttpRequest sharedInstance] sendRequestBaseUrl:YL_BASE_API_WEIXIN apiName:@"mobile/login" params:params success:^(NSDictionary *dic) {
        NSString* cuid = [[dic dicWithKey:@"customer"] stringWithKey:@"cuid"];
        [YLUserDataManager saveCuid:cuid];
        [YLUserDataManager savePhone:self.phoneTextField.text];
        YLLoadController *loginAndRegVc = [[YLLoadController alloc] init];
        [self.navigationController pushViewController:loginAndRegVc animated:YES];
    } requestFailure:^(NSDictionary *dic) {
        [self alertErrorMsg:dic];
    } failure:^(NSError *error) {
        [self requestError];
    }];
   
}

#pragma mark - delegate

//点击go移动光标到下一个textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.codeTextField becomeFirstResponder];
    if (self.codeTextField == textField) {
        [self yl_loginBtnAction];
    }
    return YES;
}

//限制只能输入数字 限制输入数字的位数最多为11位
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (self.phoneTextField == textField) {
        NSCharacterSet *cs;
        cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS]invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
        BOOL canChange = [string isEqualToString:filtered];
        
        if ([toBeString length] > 11) {
            return NO;
        }
        
        return canChange;
    }
    return YES;
}



#pragma mark - create UI

- (void)yl_createUI {
    NSLog(@"Current method: %@",NSStringFromSelector(_cmd));    //loading view

    UIView* contentView = [[UIView alloc] initWithFrame:self.view.frame];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentView];
    
    UIImageView* bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, APPHeight)];
    bgView.image = [UIImage imageNamed:[YLCompanySettingUtil getLoginBgImageStr]];
    bgView.contentMode = UIViewContentModeScaleAspectFill;
    bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yl_tapAction)];
    [self.view addGestureRecognizer:tap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(yl_tapAction)];
    [self.view addGestureRecognizer:pan];
    [self.view addSubview:bgView];
    
    
    UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 189, APPWidth, 40)];
    tagLabel.font = kCOMMON_FONT_MEDIUM_30;
    tagLabel.textColor = RGBColor(255, 255, 255);
    tagLabel.textAlignment = NSTextAlignmentLeft;
    tagLabel.text = @"登录";
    [bgView addSubview:tagLabel];
    
    UIView* textView = [[UIView alloc] initWithFrame:CGRectMake(23, tagLabel.bottom + 30, APPWidth - 46, 100)];
    textView.backgroundColor = RGBColor(255, 255, 255);
    [bgView addSubview:textView];
    
    textView.layer.cornerRadius = 4;
    textView.layer.masksToBounds = YES;
    
    NSString *phoneHolder = @"请输入手机号码";
    NSMutableAttributedString *phonePlaceHodler = [[NSMutableAttributedString alloc] initWithString:phoneHolder];
    [phonePlaceHodler addAttribute:NSForegroundColorAttributeName
                             value:RGBColor(152, 161, 172)
                             range:NSMakeRange(0, phoneHolder.length)];
    [phonePlaceHodler addAttribute:NSFontAttributeName
                             value:kCOMMON_FONT_REGULAR_16
                             range:NSMakeRange(0, phoneHolder.length)];
    
    self.phoneTextField = [[YLTextField alloc] initWithFrame:CGRectMake(16, 0, textView.width - 20, 50)];
    self.phoneTextField.attributedPlaceholder = phonePlaceHodler;
    self.phoneTextField.backgroundColor = [UIColor whiteColor];
    self.phoneTextField.returnKeyType = UIReturnKeyGo;
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.phoneTextField.delegate = self;
    self.phoneTextField.font = kCOMMON_FONT_REGULAR_16;
    if ([YLUserDataManager getPhone] && ![[YLUserDataManager getPhone] isEmptyStr]) {
        self.phoneTextField.text = [YLUserDataManager getPhone];
    }
    [textView addSubview:self.phoneTextField];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.phoneTextField.bottom, textView.width, 0.5)];
    lineView.backgroundColor = RGBColor(216, 216, 216);
    [textView addSubview:lineView];
    
    NSString *pwdHolder = @"验证码";
    NSMutableAttributedString *pwdPlaceHodler = [[NSMutableAttributedString alloc] initWithString:pwdHolder];
    [pwdPlaceHodler addAttribute:NSForegroundColorAttributeName
                           value:RGBColor(152, 161, 172)
                           range:NSMakeRange(0, pwdHolder.length)];
    [pwdPlaceHodler addAttribute:NSFontAttributeName
                           value:kCOMMON_FONT_REGULAR_16
                           range:NSMakeRange(0, pwdHolder.length)];
    self.codeTextField = [[YLTextField alloc] initWithFrame:CGRectMake(self.phoneTextField.left, lineView.bottom, self.phoneTextField.width - 98 - 10, 50)];
    self.codeTextField.attributedPlaceholder = pwdPlaceHodler;
    self.codeTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.codeTextField.font = kCOMMON_FONT_REGULAR_16;
    self.codeTextField.returnKeyType = UIReturnKeyGo;
    self.codeTextField.backgroundColor = [UIColor whiteColor];
    [textView addSubview:self.codeTextField];
    
    self.sendCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(textView.width - 10 - 98, (50 - 34)/2 + 50, 98, 34)];
    self.sendCodeBtn.backgroundColor = kCOMMON_COLOR;
    [self.sendCodeBtn addTarget:self action:@selector(yl_getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCodeBtn setTitleColor:RGBColor(255, 255, 255) forState:UIControlStateNormal];
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [textView addSubview:self.sendCodeBtn];
    self.sendCodeBtn.layer.cornerRadius = 4;
    self.sendCodeBtn.titleLabel.font = kCOMMON_FONT_REGULAR_14;
    self.sendCodeBtn.layer.masksToBounds = YES;
    
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake((APPWidth - textView.width)/2, textView.bottom + 28, textView.width, 45)];
    [self.loginBtn addTarget:self action:@selector(yl_loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.loginBtn setBackgroundColor:[UIColor whiteColor]];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = kCOMMON_FONT_MEDIUM_16;
    [self.loginBtn setTitleColor:RGBColor(249, 86, 13) forState:UIControlStateNormal];
    [self.view addSubview:self.loginBtn];
    
    self.loginBtn.layer.cornerRadius = 4;
    self.loginBtn.layer.masksToBounds = YES;
    
    if ([YLCompanySettingUtil getCompanyCid] == nil) {
        UIImageView* icon = [[UIImageView alloc] initWithFrame:CGRectMake((APPWidth - 26)/2, APPHeight - 43 - 17, 26, 17)];
        icon.image = [UIImage imageNamed:@"login_icon"];
        [bgView addSubview:icon];
        
        UILabel* compayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, icon.bottom + 6, APPWidth, 17)];
        compayLabel.font = kCOMMON_FONT_REGULAR_12;
        compayLabel.text = @"Powered by AlphaElephant";
        compayLabel.textAlignment = NSTextAlignmentCenter;
        compayLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
        [bgView addSubview:compayLabel];
    }
}

#pragma mark - private

- (void)yl_tapAction {
    [self.phoneTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
}
@end
