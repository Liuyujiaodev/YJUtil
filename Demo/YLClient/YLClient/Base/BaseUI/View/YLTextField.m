//
//  YLTextField.m
//  YLZhiNengYun
//
//  Created by 刘玉娇 on 2017/10/16.
//  Copyright © 2017年 yunli. All rights reserved.
//

#import "YLTextField.h"

@implementation YLTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return self;
}




@end
