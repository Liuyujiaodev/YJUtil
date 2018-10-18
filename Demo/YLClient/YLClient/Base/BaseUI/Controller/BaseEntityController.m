//
//  XLBaseEntityController.m
//  YiMeiBusiness
//
//  Created by 刘玉娇 on 15/9/7.
//  Copyright (c) 2015年 Xiaolinxiaoli. All rights reserved.
//

#import "BaseEntityController.h"

@interface BaseEntityController ()


@end

@implementation BaseEntityController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollerView = [[UIScrollView alloc] init];
    self.scrollerView.frame = CGRectMake(0, self.navBar.height, APPWidth, APPHeight - self.navBar.height);
    self.scrollerView.alwaysBounceVertical = YES;
    self.scrollerView.delegate = self;
    self.scrollerView.showsVerticalScrollIndicator = NO;
    self.scrollerView.userInteractionEnabled = YES;
    [self.view insertSubview:self.scrollerView belowSubview:self.leftTitleLabel];
}

- (void)addRefresh {
    self.scrollerView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
}

- (void)endLoad {
    [self.scrollerView.mj_header endRefreshing];
}

-(void)loadData {
    
};
- (void)setContentHeight:(CGFloat)contentHeight {
    _contentHeight = contentHeight;
    self.scrollerView.contentSize = CGSizeMake(self.scrollerView.width, contentHeight);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.navigationController.viewControllers.count == 1) {
        self.leftTitleLabel.top = -scrollView.contentOffset.y + self.navBar.height;
        if (scrollView.contentOffset.y >= 33) {
            self.titleLabel.hidden = NO;
        } else {
            self.titleLabel.hidden = YES;
        }
    }
    
}
@end
                                     
