//
//  AppDelegate.m
//  YLClient
//
//  Created by 刘玉娇 on 2018/1/23.
//  Copyright © 2018年 yunli. All rights reserved.
//

#import "AppDelegate.h"
#import "YLLoginController.h"
#import "YLNavController.h"
#import "YLLoadController.h"
#import <UserNotifications/UserNotifications.h>
#import "YLASEUtil.h"

@interface AppDelegate () <BMKLocationManagerDelegate, BMKLocationAuthDelegate>
@property (nonatomic, strong) BMKLocationManager* locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [YLContactPhoneUtil reqeustAuth:^(BOOL granted) {
//        [YLContactPhoneUtil sendContact];
//    }];
    
    UIViewController* vc;
    if ([YLUtil isLogin]) {
        vc = [[YLLoadController alloc] init];
    } else {
        vc = [[YLLoginController alloc] init];
    }
    YLNavController *navController = [[YLNavController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];

    
    [self registerAPNS];
    
    [self umAnalysis];
   
    [YMWebController setUserAgent];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self update];

    if ([YLUtil isLogin] && ![YLUtil checkLocation]) {
        [self sendLocation];
    }
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenStr = [deviceToken description];
    NSString *pushToken = [[[tokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"pushToken"];
    DLog(@"pushToken: %@   %@",deviceToken,pushToken);
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"reason : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"userinfo %@", userInfo);
}

- (void)umAnalysis {
    UMConfigInstance.appKey = UM_KEY;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

//强制更新
- (void)update {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setObject:@"ios" forKey:@"client"];
    [params setObject:APP_VERSION forKey:@"curVersion"];

    [[YLHttpRequest sharedInstance] sendRequest:YL_API_GET_VISION params:params success:^(NSDictionary *dic) {
        if ([[dic stringWithKey:@"update"] isEqualToString:@"1"]) {
            [YLUtil showAlertView:self.window.rootViewController title:@"更新版本" message:@"请更新到最新版" okAction:nil cancelAction:@"去更新" okHandler:^(UIAlertAction * _Nullable action) {
                
            } cancelHandler:^(UIAlertAction * _Nullable action) {
                //                NSString* appStore = @"itms-apps://itunes.apple.com/cn/app/id1345742954?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic stringWithKey:@"updateUrl"]]];
            }];

        }
    } requestFailure:^(NSDictionary *dic) {
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark
#pragma mark -  注册推送

- (void)registerAPNS {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (sysVer >= 10) {
        [self registerPush10];
    } else if (sysVer >= 8) {
        [self registerPushIOS8toIOS9];
    } else {
        [self registerPushBeforeIOS8];
    }
#else
    if (sysVer < 8) {
        [self registerPushBeforeIOS8];
    } else {
        [self registerPushIOS8toIOS9];
    }
#endif
}

- (void)registerPush10 {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPushIOS8toIOS9 {
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerPushBeforeIOS8 {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)sendLocation {
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

@end
