//
//  XLBaseListController.m
//  YiMeiBusiness
//
//  Created by 刘玉娇 on 15/9/7.
//  Copyright (c) 2015年 Xiaolinxiaoli. All rights reserved.
//

#import "BaseListController.h"
#import "BaseCell.h"
#import <objc/runtime.h>
#import "YLLoadController.h"

#define kCELL_BGCOLOR                  RGBColor(246, 246, 246)

@implementation BaseListController

-(instancetype)init {
    if (self = [super init]) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navBar.height, APPWidth, APPHeight - self.navBar.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGBColor(255, 255, 255);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view insertSubview:self.tableView belowSubview:self.leftTitleLabel];

    [self createNoDataView];
}


- (void)createNoDataView {
    self.noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.tableView.height)];
    self.noDataView.hidden = YES;
    self.noDataView.backgroundColor = RGBColor(249, 249, 249);
    [self.tableView addSubview:self.noDataView];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.noDataView.width - 56)/2, (self.noDataView.height - 56 - 16 - 22)/2, 56, 56)];
    imgView.image = [UIImage imageNamed:@"nodata"];
    [self.noDataView addSubview:imgView];
    
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 16, self.noDataView.width, 22)];
    self.noDataLabel.text = @"请先搜索渠道";
    self.noDataLabel.font = kCOMMON_FONT_REGULAR_14;
    self.noDataLabel.textColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1/1.0];
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    [self.noDataView addSubview:self.noDataLabel];
}

-(void)addHeaderRefresh:(BOOL)isAddHeaderRefresh footerRefresh:(BOOL)isAddFooterRefresh {
    if (isAddHeaderRefresh) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadData)];
    }
    if (isAddFooterRefresh) {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightButtonTouched {
}

- (void)reloadData {
    [self loadData:NO];
}

- (void)loadMore {
    [self loadData:YES];
}

- (void)loadData:(BOOL)loadMore {
    
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DLog(@"%ld",(long)[[self.dataSource objectAtIndex:section] count]);
    return [[self.dataSource objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    Class cellClass = [self cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className length:strlen(className) encoding:NSASCIIStringEncoding freeWhenDone:NO];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    ((BaseCell*)cell).object = object;
    ((BaseCell*)cell).delegate = self;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [[self.dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cls = [self cellClassForObject:object];
    return [cls tableView:tableView rowHeightForObject:object];
}

- (void)stopLoading {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    if ([self.page isEqualToString:@"-1"]) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}
//需要重写
- (Class)cellClassForObject:(id)object {
    return [NSObject class];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self isKindOfClass:[YLLoadController class]]) {
        self.rightButtonOnBellow.top = -scrollView.contentOffset.y + self.navBar.height;
        self.leftTitleLabel.top = -scrollView.contentOffset.y + self.navBar.height;
        if (scrollView.contentOffset.y >= 33) {
            self.titleLabel.hidden = NO;
            self.rightButton.hidden = NO;
            self.rightButtonOnBellow.hidden = YES;
        } else if (scrollView.contentOffset.y >= 0){
            self.titleLabel.hidden = YES;
            self.rightButton.hidden = YES;
            self.rightButtonOnBellow.hidden = NO;
        } else {
            self.titleLabel.hidden = YES;
            self.rightButton.hidden = YES;
            self.rightButtonOnBellow.hidden = NO;
        }
    }
}
@end
