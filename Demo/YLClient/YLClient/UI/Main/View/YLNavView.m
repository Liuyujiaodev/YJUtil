//
//  YMNavView.m
//  YiMei
//
//  Created by 刘玉娇 on 15/10/27.
//  Copyright © 2015年 Xiaolinxiaoli. All rights reserved.
//

#import "YLNavView.h"

@interface YLNavView ()

@property (nonatomic, strong) UIImageView* barImageView;

@end

@implementation YLNavView

static YLNavView *instance;

+(YLNavView*) shareInstance {
    if (!instance) {
        instance = [[YLNavView alloc] init];
    }
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.barImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        self.barImageView.image = [UIImage imageNamed:@"Nav_background"];
        
        self.barImageView.alpha = 1;
        [self addSubview:self.barImageView];
    }
    return self;
}
@end
