//
//  XLBaseListController.h
//  YiMeiBusiness
//
//  Created by 刘玉娇 on 15/9/7.
//  Copyright (c) 2015年 Xiaolinxiaoli. All rights reserved.
//

#import "BaseController.h"

@interface BaseListController : BaseController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* dataSource;

@property (nonatomic, retain) NSArray* sections;

@property (nonatomic, copy) NSString* page;
@property (nonatomic, strong) UIView* noDataView;
@property (nonatomic, strong) UILabel *noDataLabel;

/**
 * 子类需要重写该方法
 *
 *  @param object 传入item
 *
 *  @return 返回cell class
 */
- (Class)cellClassForObject:(id)object;

/**
 *  是否添加上拉、下拉
 *
 *  @param isAddHeaderRefresh 上拉 (YES则需要重写headerRereshing)
 *  @param isAddFooterRefresh 下拉 (YES则需要重写footerRereshing)
 */
- (void)addHeaderRefresh:(BOOL)isAddHeaderRefresh footerRefresh:(BOOL)isAddFooterRefresh;

- (void)loadData:(BOOL)loadMore;

- (void)rightButtonTouched;

- (void)stopLoading;

@end
