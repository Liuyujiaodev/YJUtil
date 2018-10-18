//
//  YMTabBarButton.m
//  YiMei
//
//  Created by bolin on 14-9-22.
//  Copyright (c) 2014年 Xiaolinxiaoli. All rights reserved.
//

#import "YLTabBarButton.h"

@interface YLTabBarButton()
{
    UIButton *_badge;
}
@end

@implementation YLTabBarButton

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        // 不需要在用户长按的时候调整图片为灰色
        self.adjustsImageWhenHighlighted = NO;
        self.backgroundColor = [UIColor whiteColor];
        // 设置UIImageView的图片居中
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        // 设置文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置字体大小
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        if (iSiOS7) {
            [self setTitleColor:RGBColor(117, 117, 177) forState:UIControlStateNormal];
            [self setTitleColor:RGBColor(242, 117, 172) forState:UIControlStateSelected];
        }
        [self setBackgroundImage:[UIImage imageWithColor:RGBColor(255, 255, 255)] forState:UIControlStateNormal];
//        [self setBackgroundImage:[UIImage imageWithColor:RGBColor(248, 248, 248)] forState:UIControlStateSelected];

    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    
}

- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    [item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
}

//#pragma mark - 覆盖父类的2个方法
//#pragma mark 设置按钮标题的frame
//- (CGRect)titleRectForContentRect:(CGRect)contentRect {
//    UIImage *image =  [self imageForState:UIControlStateNormal];
//    CGFloat titleY = image.size.height;
//    CGFloat titleHeight = self.bounds.size.height - titleY;
//    return CGRectMake(0, titleY +5, self.bounds.size.width,  titleHeight);
//}
#pragma mark 设置按钮图片的frame
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake((self.width - self.item.image.size.width) / 2, (49 - self.item.image.size.height) / 2, self.item.image.size.width, self.item.image.size.height);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setImage:_item.image forState:UIControlStateNormal];
    [self setImage:_item.selectedImage forState:UIControlStateSelected];
    [self setTitle:_item.title forState:UIControlStateNormal];
    [self setTitleColor:RGBColor(175, 174, 174) forState:UIControlStateNormal];

}

#pragma mark KVO监听必须在监听器释放的时候，移除监听操作
- (void)dealloc
{
    [_item removeObserver:self forKeyPath:@"title"];
    [_item removeObserver:self forKeyPath:@"image"];
    [_item removeObserver:self forKeyPath:@"selectedImage"];
}

@end

