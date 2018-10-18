//
//  YLSearchController.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/27.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLSearchController.h"

@interface YLSearchController ()

@property (nonatomic, strong) UITextField* searchField;

@end

@implementation YLSearchController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"搜索" isRoot:NO];
    [self yl_createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)yl_createView {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, APPWidth, 74)];
    view.backgroundColor = kCOMMON_COLOR;
    [self.view addSubview:view];
    
    UIView* textView = [[UIView alloc] initWithFrame:CGRectMake(16, (74 - 42)/2, APPWidth - 32 - 10 - 98, 42)];
    textView.backgroundColor = RGBColor(255, 255, 255);
    [view addSubview:textView];
    
    textView.layer.cornerRadius = 4;
    textView.layer.masksToBounds = YES;
    
    NSString *pwdHolder = @"请输入渠道简称";
    NSMutableAttributedString *pwdPlaceHodler = [[NSMutableAttributedString alloc] initWithString:pwdHolder];
    [pwdPlaceHodler addAttribute:NSForegroundColorAttributeName
                           value:RGBColor(152, 161, 172)
                           range:NSMakeRange(0, pwdHolder.length)];
    [pwdPlaceHodler addAttribute:NSFontAttributeName
                           value:kCOMMON_FONT_REGULAR_16
                           range:NSMakeRange(0, pwdHolder.length)];
    self.searchField = [[YLTextField alloc] initWithFrame:CGRectMake(16, 0, textView.width - 32, 42)];
    self.searchField.attributedPlaceholder = pwdPlaceHodler;
    self.searchField.clearButtonMode = UITextFieldViewModeAlways;
    self.searchField.font = kCOMMON_FONT_REGULAR_16;
    self.searchField.backgroundColor = [UIColor whiteColor];
    [textView addSubview:self.searchField];
    [self.searchField becomeFirstResponder];
    
    UIButton* searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(textView.right + 10, textView.top, 98, textView.height)];
    [searchBtn setBackgroundColor:[UIColor whiteColor]];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:kCOMMON_COLOR forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(yl_searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:searchBtn];
    
    searchBtn.layer.cornerRadius = 4;
    searchBtn.layer.masksToBounds = YES;
}

- (void)yl_searchBtnAction {
    if (!self.searchField.text || [self.searchField.text isEmptyStr]) {
        [self alertErrorMsg:@"请输入渠道简称"];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(yl_searchWithId:)]) {
        [self.delegate yl_searchWithId:self.searchField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
