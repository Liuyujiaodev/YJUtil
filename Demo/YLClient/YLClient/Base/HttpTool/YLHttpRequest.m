//
//  YLHttpRequest.m
//  YLXD
//
//  Created by 刘玉娇 on 2017/10/10.
//  Copyright © 2017年 yj. All rights reserved.
//

#import "YLHttpRequest.h"
#import "YLASEUtil.h"
#import "YLRSAUtil.h"
#define LOGINENCODE    @"RSA"

//#define kENCODE    @"RSA"
#define kENCODE    @"AES"

@interface YLHttpRequest ()
@property (nonatomic, copy) NSString* baseUrl;
@end

@implementation YLHttpRequest

+ (instancetype)sharedInstance {
    static YLHttpRequest *_sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (YLHttpRequest *)init {
    if (self = [super init]) {

        self.afnReqManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:YL_BASE_API]];
        self.afnReqManager.requestSerializer.timeoutInterval = 10.f;
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = NO;
        self.afnReqManager.securityPolicy = securityPolicy;
        self.afnReqManager.securityPolicy.validatesDomainName = YES;
        self.afnReqManager.requestSerializer.timeoutInterval = 35.0f;
        
        NSMutableSet *acceptableSet = [NSMutableSet setWithSet:self.afnReqManager.responseSerializer.acceptableContentTypes];
        [acceptableSet addObject:@"text/html"];
        [acceptableSet addObject:@"text/plain"];
        [acceptableSet addObject:@"application/json"];
        
        self.afnReqManager.responseSerializer.acceptableContentTypes = acceptableSet;

    }
    return self;
}

- (void)sendRequestBaseUrl:(NSString*)baseUrl
        apiName:(NSString*)apiName
             params:(NSDictionary*)params
            success:(Success)success
     requestFailure:(RequestFailure)requestFailure
            failure:(Failure)failure {
    self.afnReqManager.baseURL = [NSURL URLWithString:baseUrl];
    if (apiName == nil || apiName.length == 0) {
        //        NSLog(@"ERROR:MsClient.sendRequest:apiName Empty");
        return;
    }
    NSDictionary* rsaDicParams;
    if ([LOGINENCODE isEqualToString:@"RSA"]) {
        rsaDicParams = [YLRSAUtil encodeDic:[self addFixedArgumentsWithDictionary:params]];
    } else if ([LOGINENCODE isEqualToString:@"AES"]) {
        rsaDicParams = [YLASEUtil encodeDic:[self addFixedArgumentsWithDictionary:params]];
    }
    
    [self.afnReqManager POST:apiName parameters:rsaDicParams progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDictionary* dic = [NSDictionary dictionary];
        if (responseObject != nil) {
            dic = (NSDictionary *)responseObject;
        }
        NSString *status = [dic stringWithKey:@"status"];
        if ([status isEqualToString:@"0"]) {
            DLog(@"-baseAPI-%@---%@----%@",baseUrl,params, apiName, dic);
            requestFailure(dic);
        } else {
            NSDictionary* decodeDic;
            if (![[dic stringWithKey:@"data"] isEqualToString:@""]) {
                if ([LOGINENCODE isEqualToString:@"RSA"]) {
                    decodeDic = [YLRSAUtil decodeWithStr:[dic objectForKey:@"data"]];
                } else if ([LOGINENCODE isEqualToString:@"AES"]) {
                    decodeDic = [YLASEUtil decodeWithStr:[dic objectForKey:@"data"]];
                }
            }
            DLog(@"--%@---%@----%@",params, apiName, decodeDic);
            success(decodeDic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failure(error);
    }];
}

- (void)sendRequest:(NSString*)apiName
             params:(NSDictionary*)params
             success:(Success)success
             requestFailure:(RequestFailure)requestFailure
             failure:(Failure)failure {
    self.afnReqManager.baseURL = [NSURL URLWithString:YL_BASE_API];

    if (apiName == nil || apiName.length == 0) {
        //        NSLog(@"ERROR:MsClient.sendRequest:apiName Empty");
        return;
    }
    NSDictionary* rsaDicParams;
    if ([kENCODE isEqualToString:@"RSA"]) {
        rsaDicParams = [YLRSAUtil encodeDic:[self addFixedArgumentsWithDictionary:params]];
    } else if ([kENCODE isEqualToString:@"AES"]) {
        rsaDicParams = [YLASEUtil encodeDic:[self addFixedArgumentsWithDictionary:params]];
    }    DLog(@"-baseAPI -%@---%@",YL_BASE_API,[self addFixedArgumentsWithDictionary:params]);

    [self.afnReqManager POST:apiName parameters:rsaDicParams progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSDictionary* dic = [NSDictionary dictionary];
        if (responseObject != nil) {
            dic = (NSDictionary *)responseObject;
        }
        NSString *status = [dic stringWithKey:@"status"];
        if ([status isEqualToString:@"0"]) {
            DLog(@"--%@---%@----%@",params, apiName, dic);
            requestFailure(dic);
        } else {
            NSDictionary* decodeDic;
            if (![[dic stringWithKey:@"data"] isEqualToString:@""]) {
                if ([kENCODE isEqualToString:@"RSA"]) {
                    decodeDic = [YLRSAUtil decodeWithStr:[dic objectForKey:@"data"]];
                } else if ([kENCODE isEqualToString:@"AES"]) {
                    decodeDic = [YLASEUtil decodeWithStr:[dic objectForKey:@"data"]];
                }
            }
            DLog(@"--%@---%@----%@",params, apiName, decodeDic);
            success(decodeDic);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        failure(error);
    }];
}

-(BOOL) hasWifi {
    YLReachability* reach = [YLReachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status == ReachableViaWiFi;
}

-(BOOL) hasNetwork {
    YLReachability* reach = [YLReachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status != NotReachable;
}


- (NSDictionary *)addFixedArgumentsWithDictionary:(NSDictionary *)parameters
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameters];
    if ([YLCompanySettingUtil getCompanyCid]) {
        [dic setObject:[YLCompanySettingUtil getCompanyCid] forKey:@"cid"];
        [dic setObject:[NSNumber numberWithBool:YES] forKey:@"customization"];
    } else {
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"customization"];
    }
    [dic setObject:YMBCURRENT_DEVICE_ID forKey:@"device_id"];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"os_type"];
    [dic setObject:[NSNumber numberWithFloat:CURRENT_SYSTEM_VERSION] forKey:@"os_version"];
    [dic setObject:[Util getDeviceType] forKey:@"device_type"];
    [dic setObject:APP_VERSION forKey:@"version"];

//    if ([kENCODE isEqualToString:@"RSA"]) {
//        [dic setObject:@"1" forKey:@"isTest"];
//    } else if ([kENCODE isEqualToString:@"AES"]) {
//        [dic setObject:@"1" forKey:@"isAes"];
//    }

    return dic;
}

- (AFSecurityPolicy *)customSecurityPolicy {
    
    // 先导入证书 证书由服务端生成，具体由服务端人员操作
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"];//证书的路径
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES;
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    
    return securityPolicy;
}
@end
