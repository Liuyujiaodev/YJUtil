//
//  YLLoadController.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/26.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "YLLoadController.h"
#import "YLLoadModel.h"
#import "YLLoadCell.h"
#import "YLLoginController.h"
#import "YLNavController.h"
#import "YMWebController.h"
#import "YLSearchController.h"
#import "YLLoadingView.h"
#import "YLLivenessStartController.h"

@interface YLLoadController () <YLSearchDelegate,CLLocationManagerDelegate, BMKLocationManagerDelegate>

@property (nonatomic, strong) UIImageView* topIconView;//顶部购物的图标
@property (nonatomic, strong) UIView* promptView;//开启权限的提示页面

@property (nonatomic, strong) BMKLocationManager* locationManager;//百度地图定位
@property (nonatomic, strong) CLLocationManager* systemLocationManager;//系统定位

@property (nonatomic, copy) NSString* searchId;//搜索的渠道号
@property (nonatomic, strong) UIView* headerView;//顶部按钮视图
@property (nonatomic, strong) UIView* settingView;//拒绝后的浮层提示

@end

@implementation YLLoadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:APP_Name isRoot:YES];
    
    //添加下拉刷新，不需要下拉加载
    [self addHeaderRefresh:YES footerRefresh:NO];

    //创建UI
    [self yl_createUI];
    
    //加载数据
    [self yl_loadData:NO];
}

#pragma mark - 加载数据

- (void)yl_loadData:(BOOL)loadMore {
    DLog(@"=======current method:%@", NSStringFromSelector(_cmd));
    //loading view
    YLLoadingView* loadingView = [[YLLoadingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:loadingView];
    
    //请求参数 cuid channelShortName
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[YLUserDataManager getCuid] forKey:@"cuid"];
    if (self.searchId && ![self.searchId isEmptyStr]) {
        [params setObject:self.searchId forKey:@"channelShortName"];
    }

    [[YLHttpRequest sharedInstance] sendRequest:YL_API_LOAD_LIST params:params success:^(NSDictionary *dic) {
        [loadingView stopLoading];
        //停止上拉加载下拉刷新
        [self stopLoading];

        [self.dataSource removeAllObjects];
        
        //没有渠道的提示
        if ([[dic stringWithKey:@"isChannelExist"] isEqualToString:@"0"]) {
            [self alertErrorMsg:@"输入渠道简称有误，请检查后重新输入"];
        }
        
        //是否有数据,没有数据显示空页面
        if ([dic arrayWithKey:@"list"].count == 0) {
            self.noDataView.hidden = NO;
        } else {
            self.noDataView.hidden = YES;
        }
        
        //分析数据存入数据源，DataSource里有多个dic，dic包含产品列表key为model，公司名字companyName，渠道名字channeName
        for (NSDictionary* dataDic in [dic arrayWithKey:@"list"]) {
            NSMutableDictionary* modelDic = [NSMutableDictionary dictionary];
            
            //公司优先显示简称，无简称显示全称
            NSString* comanyName = [dataDic stringWithKey:@"companyShortName"];
            if ([comanyName isEmptyStr]) {
                comanyName = [dataDic stringWithKey:@"companyName"];
            }
            [modelDic setObject:comanyName forKey:@"companyName"];
            //公司渠道
            [modelDic setObject:[dataDic stringWithKey:@"channeName"] forKey:@"channeName"];
            
            NSString* channelId = [dataDic stringWithKey:@"channelId"];
            NSString* cid = [dataDic stringWithKey:@"cid"];
            //产品列表
            NSArray* list = [dataDic arrayWithKey:@"productList"];
            NSMutableArray* modelArray = [NSMutableArray array];
            for (NSDictionary* listDic in list) {
                YLLoadModel* model = [YLLoadModel modelWithDic:listDic];
                model.channelId = channelId;
                model.cid = cid;
                [modelArray addObject:model];
            }
            [modelDic setObject:modelArray forKey:@"model"];
            [self.dataSource addObject:modelDic];
        }
        [self.tableView reloadData];
    } requestFailure:^(NSDictionary *dic) {
        [loadingView stopLoading];
        [self stopLoading];
        [YLUtil showAlertView:self title:@"" message:[dic stringWithKey:@"msg"] okAction:@"" cancelAction:@"我知道了" okHandler:nil
                cancelHandler:nil];
    } failure:^(NSError *error) {
        [loadingView stopLoading];
        [self stopLoading];
        [self requestError];

    }];
}

//下拉刷新
- (void)yl_reloadData {
    self.searchId = @"";
    [self loadData:NO];
}

#pragma mark - base method

- (Class)cellClassForObject:(id)object {
    return [YLLoadCell class];
}

//滑动的动画，上滑隐藏头部view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    self.headerView.top = -scrollView.contentOffset.y + self.navBar.height;

    if (scrollView.contentOffset.y >= self.headerView.height) {
        self.tableView.top = self.navBar.height;
        self.tableView.height = APPHeight - self.navBar.height;
        self.topIconView.hidden = YES;
    } else if (scrollView.contentOffset.y >= 0) {
        
        self.topIconView.hidden = YES;
        self.leftTitleLabel.top = self.navBar.height;
        self.headerView.top = self.navBar.bottom;
        self.topIconView.hidden = NO;
        self.tableView.top = self.headerView.bottom;
        self.tableView.height = APPHeight - self.headerView.height;
    } else {
        self.leftTitleLabel.top = self.navBar.height;
        self.headerView.top = self.navBar.bottom;
        self.topIconView.hidden = NO;
        
        self.tableView.top = self.headerView.bottom;
        self.tableView.height = APPHeight - self.headerView.height;
    }
}

- (void)thePBMissionWithCode:(NSString *)code withMessage:(NSString *)message
{
    //code = 0:表示成功，其他状态请参考文档
    NSLog(@"状态码：%@    对应信息：%@",code,message);
}
#pragma mark - delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YLLoadModel* loadModel = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"model"] objectAtIndex:indexPath.row];

    //数据磨合
//    PBBaseReq *br = [PBBaseReq new];
//    br.partnerCode=SJMH_CODE;//
//    br.partnerKey = SJMH_KEY;//合作方key
//    br.channel_code = @"005003";//客户端渠道码，例如京东是 005011
//    PBBaseSet *set = [PBBaseSet new];
//    //新增可选参数：
//    //    br.real_name = @"张三";//可选，真实姓名
//    //    br.identity_code = @"110103********3742";//可选，身份证号
//    //    br.user_mobile = @"13011283721";//可选，手机号
//    //    br.passback_params = @"654321";//可选，透传参数，不能超过512位。
////    //导航栏颜色
////    set.navBGColor = [UIColor colorWithRed:123/255.f green:12/255.f blue:12/255.f alpha:1];
////    //导航栏标题颜色
////    set.navTitleColor = [UIColor colorWithRed:12/255.f green:123/255.f blue:12/255.f alpha:1];
////    //导航栏标题字体
////    set.navTitleFont = [UIFont systemFontOfSize:10];
////    //导航栏按钮图片
////    set.backBtnImage = [UIImage imageNamed:@"icon_back_PB"];
//
//    //此方法需在主线程调用。
//    [shujumohePB openPBPluginAtViewController:self withDelegate:self withReq:br withBaseSet:set];
//    return;

//    //活体验证
//    YLLivenessStartController* vc = [[YLLivenessStartController alloc] init];
//    vc.productId = loadModel.productId;
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
    
    if (loadModel.submitCheckOwe) {
        [self alertErrorMsg:@"该公司账户余额不足，请选择其他产品或者联系公司工作人员充值。"];
        return;
    }
    if (loadModel.notApply && [loadModel.status isEqualToString:@"1"]) {
        [self alertErrorMsg:@"您有未还清的贷款不能申请新的贷款"];
        return;
    }
    if (loadModel.whetherApply) {
        [self alertErrorMsg:loadModel.message];
        return;
    }
    //app 审核
    if ([[YLUserDataManager getPhone] isEqualToString:@"18888888888"]) {
        [self yl_orderBtnAction];
    } else {
        if (![YLAuthUtil isGetContactAuth]) {
            //仅第一次没有获取过权限时执行
            [self yl_showReqestAuthView];
        } else {
            //检测需要的权限
            [self yl_checkContact:loadModel];
        }
    }
}

//搜索渠道
-(void)yl_searchWithId:(NSString *)searchId {
    self.searchId = searchId;
    [self loadData:NO];
}


#pragma mark - btn action

//我的账单按钮事件
- (void)yl_orderBtnAction {
    NSString* str = YL_URL_ORDER;
    NSString* cid = [YLCompanySettingUtil getCompanyCid];
    if (cid) {
        str = [YL_URL_ORDER stringByAppendingString:[NSString stringWithFormat:@"?cid=%@", cid]];
    }
    YMWebController* vc = [[YMWebController alloc] init];
    vc.url = str;
    [self.navigationController pushViewController:vc animated:YES];
}

//搜索按钮事件
- (void)yl_searchBtnAction {
    YLSearchController* searchVC = [[YLSearchController alloc] init];
    searchVC.delegate = self;
    [self.navigationController pushViewController:searchVC animated:YES];
}

//退出登录按钮事件
- (void)yl_logoutBtnAction {
    [YLUtil showAlertView:self title:@"" message:@"您确认要退出当前账户吗？" okAction:@"确认" cancelAction:@"取消" okHandler:^(UIAlertAction *action) {
        [YLUserDataManager removeUserInfo];
        [[YLHttpRequest sharedInstance] sendRequestBaseUrl:YL_BASE_API_WEIXIN apiName:YL_API_LOGOUT params:nil success:^(NSDictionary *dic) {
            
        } requestFailure:^(NSDictionary *dic) {
            
        } failure:^(NSError *error) {
            
        }];
        YLLoginController *loginAndRegVc = [[YLLoginController alloc] init];
        YLNavController *nav = [[YLNavController alloc] initWithRootViewController:loginAndRegVc];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    } cancelHandler:^(UIAlertAction * _Nullable action) {
        
    }];
}

//同意并继续按钮事件（关闭了提示获取权限页面，请求权限弹窗）
- (void)yl_agreeBtnAction {
    [self yl_closeBtnAction];
    if ([CLLocationManager locationServicesEnabled]) {
        self.systemLocationManager = [[CLLocationManager alloc] init];
        [self.systemLocationManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
    }
    [YLAuthUtil reqeustAuth:^(BOOL granted) {
        
    }];
}

//关闭获取权限页面
- (void)yl_closeBtnAction {
    [UIView animateWithDuration:0.38 animations:^{
        self.promptView.top = APPHeight;
    } completion:^(BOOL finished) {
        self.promptView.top = APPHeight;
        self.promptView = nil;
    }];
}

#pragma mark - table headview

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString* cid = [YLCompanySettingUtil getCompanyCid];
    if ([cid isEqualToString:@"1410"]) {
        return 0;
    } else {
        return 70.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSDictionary* dic = [self.dataSource objectAtIndex:section];
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, 70)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //need fix
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, (headerView.height - 25)/2, 200, 25)];
    label.font = kCOMMON_FONT_MEDIUM_22;
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor colorWithRed:71/255.0 green:85/255.0 blue:103/255.0 alpha:1/1.0];
    [headerView addSubview:label];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(APPWidth - 300 - 16, (headerView.height - 22)/2, 300, 22)];
    contentLabel.text = [dic stringWithKey:@"channeName"];
    contentLabel.font = kCOMMON_FONT_REGULAR_14;
    contentLabel.textAlignment = NSTextAlignmentRight;
    contentLabel.textColor = [UIColor colorWithRed:71/255.0 green:85/255.0 blue:103/255.0 alpha:1/1.0];
    [headerView addSubview:contentLabel];
    
    //app review
    if ([[YLUserDataManager getPhone] isEqualToString:@"18888888888"]) {
        label.text = @"账单管家";
        contentLabel.hidden = YES;
    } else {
        label.text = [dic stringWithKey:@"companyName"];
        contentLabel.hidden = NO;
    }
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* dic = [self.dataSource objectAtIndex:indexPath.section];
    id object = [[dic objectForKey:@"model"] objectAtIndex:indexPath.row];
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)[[self.dataSource objectAtIndex:section] objectForKey:@"model"]).count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id object = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:@"model"] objectAtIndex:indexPath.row];
    Class cls = [self cellClassForObject:object];
    return [cls tableView:tableView rowHeightForObject:object];
}
#pragma mark - create ui

- (void)yl_createUI {
    self.topIconView = [[UIImageView alloc] initWithFrame:CGRectMake(APPWidth-83, 0, 83, 95)];
    self.topIconView.image = [UIImage imageNamed:@"buy"];
    [self.view addSubview:self.topIconView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, APPWidth, 94)];
    self.headerView.backgroundColor = kCOMMON_COLOR;

    CGFloat width = APPWidth/3;
    CGFloat left = 0;
    NSString* cid = [YLCompanySettingUtil getCompanyCid];
    if ([cid isEqualToString:@"1410"]) {
        width = APPWidth / 2;
    }
    UIButton* orderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 26, width, 58)];
    [orderBtn setTitle:@"我的账单" forState:UIControlStateNormal];
    [orderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [orderBtn setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
    orderBtn.titleLabel.font = kCOMMON_FONT_MEDIUM_16;
    [orderBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [orderBtn addTarget:self action:@selector(yl_orderBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:orderBtn];
    left = orderBtn.right;
    
    if (![cid isEqualToString:@"1410"]) {
        UIButton* searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, 26, width, 58)];
        [searchBtn setTitle:@"搜索渠道" forState:UIControlStateNormal];
        [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [searchBtn setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        searchBtn.titleLabel.font = kCOMMON_FONT_MEDIUM_16;
        [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        [searchBtn addTarget:self action:@selector(yl_searchBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:searchBtn];
        left = searchBtn.right;
    }
    
    UIButton* logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(left, 26, width, 58)];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [logoutBtn setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = kCOMMON_FONT_MEDIUM_16;
    [logoutBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [logoutBtn addTarget:self action:@selector(yl_logoutBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:logoutBtn];
    [self.view insertSubview:self.headerView belowSubview:self.leftTitleLabel];
    self.tableView.top = self.headerView.bottom;
    self.tableView.height = APPHeight - self.headerView.bottom;
}

#pragma mark - private

//先检测通讯录权限是否必须且允许
- (void)yl_checkContact:(YLLoadModel*)model {
    if ([YLAuthUtil getContactStatus] == YLAuthUtilStatusAuthed) {
        [SVProgressHUD showWithStatus:@"数据加载中，请稍后..."];
        [YLAuthUtil sendContactSuccess:^{
            [SVProgressHUD dismiss];
            DLog(@"检测定位");
            [self yl_checkLocation:model];
        } failure:^{
            [SVProgressHUD dismiss];
            [self requestError];
        }];

    } else {
        if (model.needCantact) {
            [self yl_showSettingView];
        } else {
            [self yl_checkLocation:model];
        }
    }
}

- (void)yl_checkLocation:(YLLoadModel*)model {
    if ([YLAuthUtil getLocationStatus] == YLAuthLocationStatusAuthed) {
        [self yl_sendLocation];
        [self yl_jumpToInfoPage:model];
    } else {
        if (model.needLocation) {
            [self yl_showSettingView];
        } else {
            [self yl_jumpToInfoPage:model];
        }
    }
}

- (void)yl_showSettingView {
    self.settingView = [[UIView alloc] initWithFrame:CGRectMake((APPWidth - 280)/2, (self.view.height - 247)/2, 280, 247)];
    self.settingView.backgroundColor = RGBColor(249, 250, 252);
    self.settingView.layer.cornerRadius = 10;
    self.settingView.layer.masksToBounds = YES;
    [self.view addSubview:self.settingView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.settingView.width, 48)];
    titleLabel.text = @"请允许访问通讯录和定位";
    titleLabel.textColor = RGBColor(63, 63, 63);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = kCOMMON_FONT_MEDIUM_18;
    [self.settingView addSubview:titleLabel];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(16, titleLabel.bottom, 248, 144)];
    imgView.image = [UIImage imageNamed:@"tips"];
    [self.settingView addSubview:imgView];
    
    UIView* bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.settingView.height - 50, self.settingView.width, 1)];
    bottomLine.backgroundColor = RGBColor(226, 226, 226);
    [self.settingView addSubview:bottomLine];
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomLine.bottom , 140, 49)];
    [cancelBtn setTitle:@"放弃申请" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:RGBColor(155, 155, 155) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(yl_cancelBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.settingView addSubview:cancelBtn];
    
    UIView* centerLine = [[UIView alloc] initWithFrame:CGRectMake(cancelBtn.right, bottomLine.bottom, 1, 49)];
    centerLine.backgroundColor = RGBColor(226, 226, 226);
    [self.settingView addSubview:centerLine];
    
    UIButton* jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(cancelBtn.right, cancelBtn.top, cancelBtn.width, cancelBtn.height)];
    [jumpBtn setTitle:@"去设置" forState:UIControlStateNormal];
    [jumpBtn setTitleColor:RGBColor(80, 140, 238) forState:UIControlStateNormal];
    [jumpBtn addTarget:self action:@selector(yl_jumpToSettingPage) forControlEvents:UIControlEventTouchUpInside];
    [self.settingView addSubview:jumpBtn];
}

- (void)yl_cancelBtnAction {
    [self.settingView removeFromSuperview];
}

- (void)yl_jumpToSettingPage {
    [self.settingView removeFromSuperview];
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)yl_jumpToInfoPage:(YLLoadModel*)model {
    DLog(@"------发送请求-------%lf", [NSDate timeIntervalSinceReferenceDate]);

    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:[YLUserDataManager getCuid] forKey:@"cuid"];
    [params setObject:model.cid forKey:@"cid"];
    [params setObject:model.channelId forKey:@"channelId"];
    [params setObject:model.productId forKey:@"productId"];
    //请求地址
    [[YLHttpRequest sharedInstance] sendRequestBaseUrl:YL_BASE_API apiName:YL_API_PROJECT_DETAIL_URL params:params success:^(NSDictionary *dic) {
        DLog(@"------收到qing-------%lf", [NSDate timeIntervalSinceReferenceDate]);
        [SVProgressHUD dismiss];
        YMWebController* vc = [[YMWebController alloc] init];
        vc.url = [dic stringWithKey:@"submitUrl"];
        [self.navigationController pushViewController:vc animated:YES];
    } requestFailure:^(NSDictionary *dic) {

    } failure:^(NSError *error) {
        [self requestError];
    }];
}


#pragma mark - 定位
#pragma mark - CLLocationManagerDelegate
- (void)yl_sendLocation {
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:[YLCompanySettingUtil getBaiduMap] authDelegate:self];
    //初始化实例
    _locationManager = [[BMKLocationManager alloc] init];
    //设置delegate
    _locationManager.delegate = self;
    //设置返回位置的坐标系类型
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    //设置距离过滤参数
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //设置预期精度参数
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置应用位置类型
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    //设置是否自动停止位置更新
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    //设置是否允许后台定位
    _locationManager.allowsBackgroundLocationUpdates = NO;
    //设置位置获取超时时间
    _locationManager.locationTimeout = 10;
    //设置获取地址信息超时时间
    _locationManager.reGeocodeTimeout = 10;
    [_locationManager startUpdatingLocation];
    
}

- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error {
    if (error == nil) {
        DLog(@"----------SEND L");
        NSString* address = @"";
        if (location.rgcData.province) {
            address = location.rgcData.province;
        }
        if (![address isEqualToString:location.rgcData.city]) {
            address = [address stringAddStr:location.rgcData.city];
        }
        address = [[[address stringAddStr:location.rgcData.district] stringAddStr:location.rgcData.street] stringAddStr:location.rgcData.streetNumber];
        NSString* longitude = [NSString stringWithFormat:@"%lf",location.location.coordinate.longitude];
        NSString* latitude = [NSString stringWithFormat:@"%lf",location.location.coordinate.latitude];
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        [params setObject:address forKey:@"address"];
        [params setObject:longitude forKey:@"longitude"];
        [params setObject:latitude forKey:@"latitude"];
        [params setObject:[YLUserDataManager getCuid] forKey:@"cuid"];
        [[YLHttpRequest sharedInstance] sendRequest:YL_API_SEND_LOCATION params:params success:^(NSDictionary *dic) {
            
        } requestFailure:^(NSDictionary *dic) {
            
        } failure:^(NSError *error) {
            
        }];
    }
    [_locationManager stopUpdatingLocation];
}


//懒加载
- (UIView*)promptView {
    if (!_promptView) {
        _promptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, APPHeight)];
        _promptView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_promptView];
        
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(APPWidth - 21 - 26, 51, 21, 21)];
        [btn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(yl_closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_promptView addSubview:btn];
        
        UILabel*  titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 96, APPWidth - 60, 30)];
        titleLabel.textColor = kCOMMON_COLOR;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font = kCOMMON_FONT_MEDIUM_25;
        titleLabel.text = @"提交必须的资料";
        [_promptView addSubview:titleLabel];
        
        UIView* locationView = [self viewWithIcon:@"location" title:@"访问位置" desc:@"如实上报位置，增加授信额度。"];
        locationView.top = titleLabel.bottom + 40;
        [_promptView addSubview:locationView];
        
        UIView* contactView = [self viewWithIcon:@"contact" title:@"访问通讯录" desc:@"允许访问通讯录，增加授信额度。"];
        contactView.top = locationView.bottom + 40;
        [_promptView addSubview:contactView];
        
        UIImageView* promptImgView = [[UIImageView alloc] initWithFrame:CGRectMake(30, contactView.bottom + 54, 308, 55)];
        promptImgView.image = [UIImage imageNamed:@"prompt"];
        [_promptView addSubview:promptImgView];
        
        UIButton* agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(12.5, _promptView.height - 22 - 47, APPWidth - 25, 47)];
        [agreeBtn setImage:[UIImage imageNamed:@"btn_agree"] forState:UIControlStateNormal];
        [agreeBtn addTarget:self action:@selector(yl_agreeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_promptView addSubview:agreeBtn];
    }
    return _promptView;
}

- (UIView*)viewWithIcon:(NSString*)iconName title:(NSString*)title desc:(NSString*)desc {
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APPWidth, 56)];
    
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 56, 56)];
    iconView.image = [UIImage imageNamed:iconName];
    [view addSubview:iconView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.right + 23, 0, 200, 30)];
    titleLabel.text = title;
    titleLabel.font = kCOMMON_FONT_LIGHT_22;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = RGBColor(63, 63, 63);
    [view addSubview:titleLabel];
    
    UILabel* descLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.left, titleLabel.bottom + 5, 200, 19)];
    descLabel.text = desc;
    descLabel.textAlignment = NSTextAlignmentLeft;
    descLabel.font = kCOMMON_FONT_LIGHT_13;
    descLabel.textColor = RGBColor(74, 74, 74);
    [view addSubview:descLabel];
    return view;
}

- (void)yl_showReqestAuthView {
    self.promptView.top = APPHeight;
    [UIView animateWithDuration:0.38 animations:^{
        self.promptView.top = 0;
    } completion:^(BOOL finished) {
        self.promptView.top = 0;
    }];
   
}

#pragma mark - 防止定位弹窗一闪就消失
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.systemLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.systemLocationManager requestAlwaysAuthorization];
            }
            break;
        default:
            break;
            
    }
}
@end
