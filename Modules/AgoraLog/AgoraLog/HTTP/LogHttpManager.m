//
//  HttpManager.m
//  AgoraEdu
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 agora. All rights reserved.
//

#import "LogHttpManager.h"
#import <UIKit/UIKit.h>
#import "LogHttpClient.h"
#import "DeviceManager.h"
#import "StringMD5.h"

NSString *HTTP_LOG_SECRET = @"7AIsPeMJgQAppO0Z";
NSString *HTTP_LOG_BASE_URL = @"http://api-solutions-dev.bj2.agoralab.co";
NSString *HTTP_LOG_INFO = @"";

@implementation LogHttpManager
+ (void)setAppSecret:(NSString *)appSecret {
    HTTP_LOG_SECRET = appSecret;
}

+ (void)setBaseURL:(NSString *)baseURL {
    HTTP_LOG_BASE_URL = baseURL;
}

+ (void)getLogInfoWithAppId:(NSString *)appId ext:(NSDictionary *)ext apiVersion:(NSString *)apiVersion completeSuccessBlock:(void (^ _Nullable) (LogModel * model))successBlock completeFailBlock:(void (^ _Nullable) (NSError *error))failBlock {

    if (HTTP_LOG_INFO.length == 0) {
        NSString *hostString = [NSString stringWithFormat:@"/monitor/apps/%@/v1/log/oss/policy", appId];
        HTTP_LOG_INFO = [HTTP_LOG_BASE_URL stringByAppendingString:hostString];
    }
    
    HTTP_LOG_INFO = [HTTP_LOG_INFO stringByReplacingOccurrencesOfString:@"v1" withString:apiVersion];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appId"] = appId;
    if(ext != nil) {
        params[@"ext"] = ext;
    }
    
    params[@"platform"] = [UIDevice currentDevice].systemName;
    params[@"deviceName"] = [DeviceManager getDeviceIdentifier];
    params[@"deviceVersion"] = [UIDevice currentDevice].systemVersion;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    params[@"appVersion"] = app_Version;
    
    params[@"fileExt"] = @"zip";
    
    NSDictionary *headers = [LogHttpManager httpHeader:params];
    
    [LogHttpClient post:HTTP_LOG_INFO params:params headers:headers success:^(id _Nonnull responseObj) {
        
        LogModel *model = [LogModel initWithObject:responseObj];
        if(successBlock != nil){
            successBlock(model);
        }
        
    } failure:failBlock];
}

#pragma mark private
+ (NSDictionary *)httpHeader:(NSDictionary<NSString *, NSString *> *)params {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:0];
    NSString *paramsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDate *datenow = [NSDate date];
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970] * 1000)];
    
    NSString *signStr = @"";
    signStr = [signStr stringByAppendingString:HTTP_LOG_SECRET];
    signStr = [signStr stringByAppendingString:paramsStr];
    signStr = [signStr stringByAppendingString:timestamp];
    signStr = [StringMD5 MD5:signStr];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    headers[@"sign"] = signStr;
    headers[@"timestamp"] = timestamp;
    return headers;
}

@end
