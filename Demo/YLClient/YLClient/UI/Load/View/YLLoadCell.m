//
//  YLLoadCell.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/26.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLoadCell.h"
#import "YLLoadModel.h"

@interface YLLoadCell ()
@property (nonatomic, strong) UIImageView* bgView;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UILabel* descLabel;
@property (nonatomic, strong) UILabel* priceLabel;
@property (nonatomic, strong) UILabel* statusLabel;
@property (nonatomic, strong) UILabel* onlyMemberLabel;
@property (nonatomic, strong) UILabel* rateLabel;
@property (nonatomic, strong) UILabel* numberLabel;

@end

@implementation YLLoadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, APPWidth - 26, 220*(350/(APPWidth - 26)))];
        self.bgView.image = [UIImage imageNamed:@"load_bg"];
        [self.contentView addSubview:self.bgView];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 13, 0, 18)];
        self.statusLabel.font = kCOMMON_FONT_REGULAR_13;
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.statusLabel];
        self.statusLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.statusLabel.layer.borderWidth = 0.5;
        self.statusLabel.layer.cornerRadius = 2;
        self.statusLabel.layer.masksToBounds = YES;
        
    
        self.onlyMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 0, 18)];
        self.onlyMemberLabel.font = kCOMMON_FONT_REGULAR_13;
        self.onlyMemberLabel.textColor = [UIColor whiteColor];
        self.onlyMemberLabel.textAlignment = NSTextAlignmentCenter;
        self.onlyMemberLabel.hidden = YES;
        self.onlyMemberLabel.text = @"仅会员可申请";
        [self.bgView addSubview:self.onlyMemberLabel];
        
        CGFloat memberWidth = [Util calculateSingleStringSizeWithString:self.onlyMemberLabel.text andFont:self.onlyMemberLabel.font].width + 18;
        self.onlyMemberLabel.width = memberWidth;
        self.onlyMemberLabel.left = self.bgView.width - 13 - memberWidth;
        
        self.onlyMemberLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.onlyMemberLabel.layer.borderWidth = 0.5;
        self.onlyMemberLabel.layer.cornerRadius = 2;
        self.onlyMemberLabel.layer.masksToBounds = YES;
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, APPWidth, 21)];
        self.nameLabel.font = kCOMMON_FONT_REGULAR_15;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.nameLabel];
      
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.nameLabel.bottom + 5, APPWidth, 48)];
        self.priceLabel.font = kCOMMON_FONT_HELVETICA_NEUE_BOLD_40;
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.priceLabel];
        
        UIImageView* pageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(28, 120, self.bgView.width - 56, 37*(self.bgView.width - 56)/320)];
        pageIcon.image = [UIImage imageNamed:@"load_page"];
        [self.bgView addSubview:pageIcon];
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(100/2, 0, pageIcon.width - 100, pageIcon.height-6)];
        self.descLabel.font = kCOMMON_FONT_REGULAR_16;
        self.descLabel.textColor = kCOMMON_COLOR;
        self.descLabel.textAlignment = NSTextAlignmentCenter;
        [pageIcon addSubview:self.descLabel];
        
        self.rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, self.bgView.height - 13 - 18, 0, 18)];
        self.rateLabel.font = kCOMMON_FONT_REGULAR_13;
        self.rateLabel.textColor = [UIColor whiteColor];
        self.rateLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.rateLabel];
        
        self.rateLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.rateLabel.layer.borderWidth = 0.5;
        self.rateLabel.layer.cornerRadius = 2;
        self.rateLabel.layer.masksToBounds = YES;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.height - 13 - 18, 0, 18)];
        self.numberLabel.font = kCOMMON_FONT_REGULAR_13;
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.numberLabel];
        
        self.numberLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.numberLabel.layer.borderWidth = 0.5;
        self.numberLabel.layer.cornerRadius = 2;
        self.numberLabel.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setObject:(id)object {
    YLLoadModel* model = (YLLoadModel*)object;
    self.nameLabel.text = model.name;
    self.priceLabel.text = model.price;
    self.descLabel.text = model.desc;
    self.rateLabel.text = model.rate;
    self.numberLabel.text = model.number;
    
    if (model.onlyMembers) {
        self.onlyMemberLabel.hidden = NO;
    } else {
        self.onlyMemberLabel.hidden = YES;
    }
    if ([model.statusTitles isEmptyStr]) {
        self.statusLabel.hidden = YES;
    } else {
        self.statusLabel.hidden = NO;
        self.statusLabel.text = model.statusTitles;
        CGFloat statusWidth = [Util calculateSingleStringSizeWithString:self.statusLabel.text andFont:self.statusLabel.font].width + 18;
        self.statusLabel.width = statusWidth;
    }
   
    
    CGFloat rateWidth = [Util calculateSingleStringSizeWithString:self.rateLabel.text andFont:self.rateLabel.font].width + 18;
    self.rateLabel.width = rateWidth;
    
    CGFloat numberWidth = [Util calculateSingleStringSizeWithString:self.numberLabel.text andFont:self.rateLabel.font].width + 18;
    self.numberLabel.width = numberWidth;
    self.numberLabel.left = self.bgView.width - 13 - numberWidth;
    
    //app review
    if ([[YLUserDataManager getPhone] isEqualToString:@"18888888888"]) {
        self.rateLabel.hidden = YES;
        self.numberLabel.hidden = YES;
    } else {
        self.rateLabel.hidden = NO;
        self.numberLabel.hidden = NO;
    }
}

+(CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    return 220*(350/(APPWidth - 26)) + 20;
}


@end
