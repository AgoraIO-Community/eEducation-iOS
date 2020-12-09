//
//  HTTPManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "HTTPManager.h"
#import <YYModel/YYModel.h>

typedef NS_ENUM(NSInteger, HttpType) {
    HttpTypeGet            = 0,
    HttpTypePost,
    HttpTypePut,
    HttpTypeDelete,
};
#define HttpTypeStrings  (@[@"GET",@"POST",@"PUT",@"DELETE"])

@implementation HTTPManager

+ (void)schduleClassWithConfig:(SchduleClassConfiguration *)config  success:(OnSchduleClassSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    AFHTTPSessionManager *sessionManager = [HTTPManager sessionManager];
    
    NSString *url = [NSString stringWithFormat:HTTP_SCHDULE_CLASS, BASE_URL, config.appId, config.roomUuid];

    NSString *authString = [NSString stringWithFormat:@"%@:%@", config.customerId, config.customerCertificate];
    NSData *data =[authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"authorization": authorization};
    
    NSDictionary *parameters = @{
        @"roomName":config.roomName,
        @"roleConfig":config.roleConfig,
    };
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [HTTPManager httpStartLogWithType:HttpTypePost url:encodeUrl headers:headers params:parameters];

    [sessionManager POST:encodeUrl parameters:parameters headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [HTTPManager httpSuccessLogWithType:HttpTypePost url:encodeUrl responseObject:responseObject];
        
        SchduleModel *model = [SchduleModel yy_modelWithDictionary:responseObject];
        if(successBlock){
            successBlock(model);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [HTTPManager checkHttpError:error task:task success:^(id responseObj) {
            
            [HTTPManager httpSuccessLogWithType:HttpTypePost url:encodeUrl responseObject:responseObj];
            SchduleModel *model = [SchduleModel yy_modelWithDictionary:responseObj];
            if(successBlock){
                successBlock(model);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [HTTPManager httpErrorLogWithType:HttpTypePost url:encodeUrl error:error];
            
            if (failureBlock) {
                failureBlock(error, statusCode);
            }
        }];
    }];
}

+ (void)getBoardInfoWithConfig:(BoardInfoConfiguration *)config  success:(OnBoardInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    AFHTTPSessionManager *sessionManager = [HTTPManager sessionManager];

    NSString *url = [NSString stringWithFormat:HTTP_BOARD_INFO, BASE_URL, config.appId, config.roomUuid];

    NSString *authString = [NSString stringWithFormat:@"%@:%@", config.customerId, config.customerCertificate];
    NSData *data =[authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"token": config.userToken,
        @"authorization": authorization};
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [HTTPManager httpStartLogWithType:HttpTypeGet url:encodeUrl headers:headers params:@{}];
    
    [sessionManager GET:encodeUrl parameters:nil headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        [HTTPManager httpSuccessLogWithType:HttpTypeGet url:encodeUrl responseObject:responseObject];
        
        BoardModel *model = [BoardModel yy_modelWithDictionary:responseObject];
        if(successBlock){
            successBlock(model);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [HTTPManager checkHttpError:error task:task success:^(id responseObj) {
            
            [HTTPManager httpSuccessLogWithType:HttpTypeGet url:encodeUrl responseObject:responseObj];
            BoardModel *model = [BoardModel yy_modelWithDictionary:responseObj];
            if(successBlock){
                successBlock(model);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [HTTPManager httpErrorLogWithType:HttpTypeGet url:encodeUrl error:error];
            
            if (failureBlock) {
                failureBlock(error, statusCode);
            }
        }];
    }];
}

+ (void)getRecordInfoWithConfig:(RecordInfoConfiguration *)config  success:(OnRecordInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {

    AFHTTPSessionManager *sessionManager = [HTTPManager sessionManager];

    NSString *url = [NSString stringWithFormat:HTTP_RECORD_INFO, BASE_URL, config.appId, config.roomUuid];

    NSString *authString = [NSString stringWithFormat:@"%@:%@", config.customerId, config.customerCertificate];
    NSData *data =[authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"authorization": authorization};
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [HTTPManager httpStartLogWithType:HttpTypeGet url:encodeUrl headers:headers params:@{}];
    
    [sessionManager GET:encodeUrl parameters:nil headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [HTTPManager httpSuccessLogWithType:HttpTypeGet url:encodeUrl responseObject:responseObject];
        
        RecordModel *model = [RecordModel yy_modelWithDictionary:responseObject];
        if(successBlock){
            successBlock(model);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [HTTPManager checkHttpError:error task:task success:^(id responseObj) {
            
            [HTTPManager httpSuccessLogWithType:HttpTypeGet url:encodeUrl responseObject:responseObj];
            RecordModel *model = [RecordModel yy_modelWithDictionary:responseObj];
            if(successBlock){
                successBlock(model);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [HTTPManager httpErrorLogWithType:HttpTypeGet url:encodeUrl error:error];
            
            if (failureBlock) {
                failureBlock(error, statusCode);
            }
        }];
    }];
}

+ (void)assignBreakOutGroupWithConfig:(AssignGroupInfoConfiguration *)config  success:(OnAssignBreakOutGroupSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock {
    
    AFHTTPSessionManager *sessionManager = [HTTPManager sessionManager];

    NSString *url = [NSString stringWithFormat:HTTP_BREAKOUT_GROUP_ROOM, BASE_URL, config.appId, config.roomUuid];

    NSString *authString = [NSString stringWithFormat:@"%@:%@", config.customerId, config.customerCertificate];
    NSData *data =[authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authorization = [NSString stringWithFormat:@"Basic %@", [data base64EncodedStringWithOptions:0]];
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/json",
        @"token": config.userToken,
        @"authorization": authorization};

    NSDictionary *roleConfig = @{
        @"host" : @{
                @"limit":@(config.host.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            },
        @"assistant" : @{
                @"limit":@(config.assistant.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            },
        @"broadcaster" : @{
                @"limit":@(config.broadcaster.limit),
                @"verifyType":@(0),
                @"subscribe":@(1),
            }
    };
    NSDictionary *parameters = @{
        @"memberLimit":@(config.memberLimit),
        @"roleConfig":roleConfig,
    };
    
    NSString *encodeUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [HTTPManager httpStartLogWithType:HttpTypePost url:encodeUrl headers:headers params:parameters];
    
    [sessionManager POST:encodeUrl parameters:parameters headers:headers progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        [HTTPManager httpSuccessLogWithType:HttpTypePost url:encodeUrl responseObject:responseObject];
        
        AssignGroupModel *model = [AssignGroupModel yy_modelWithDictionary:responseObject];
        if(successBlock){
            successBlock(model);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [HTTPManager checkHttpError:error task:task success:^(id responseObj) {
            
            [HTTPManager httpSuccessLogWithType:HttpTypePost url:encodeUrl responseObject:responseObj];
            AssignGroupModel *model = [AssignGroupModel yy_modelWithDictionary:responseObj];
            if(successBlock){
                successBlock(model);
            }
            
        } failure:^(NSError *error, NSInteger statusCode) {
            [HTTPManager httpErrorLogWithType:HttpTypePost url:encodeUrl error:error];
            
            if (failureBlock) {
                failureBlock(error, statusCode);
            }
        }];
    }];
}

#pragma mark SessionManager
+ (AFHTTPSessionManager *)sessionManager {
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10;
    return sessionManager;
}

#pragma mark LOG
+ (void)httpStartLogWithType:(HttpType)type url:(NSString *)url
                     headers:(NSDictionary *)headers params:(NSDictionary *)params {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Start<============\n\
                     \nurl==>\n%@\n\
                     \nheaders==>\n%@\n\
                     \nparams==>\n%@\n\
                     ",HttpTypeStrings[type], url, headers, params];
    
    [AgoraEduManager.shareManager logMessage:msg level:AgoraLogLevelInfo];
}
+ (void)httpSuccessLogWithType:(HttpType)type url:(NSString *)url
                     responseObject:(id)responseObject {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Success<============\n\
                     \nurl==>\n%@\n\
                     \nResult==>\n%@\n\
                     ",HttpTypeStrings[type], url, responseObject];
    [AgoraEduManager.shareManager logMessage:msg level:AgoraLogLevelInfo];
}

+ (void)httpErrorLogWithType:(HttpType)type url:(NSString *)url
                     error:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:
                     @"\n============>%@ HTTP Error<============\n\
                     \nurl==>\n%@\n\
                     \nError==>\n%@\n\
                     ",HttpTypeStrings[type], url, error.description];
    [AgoraEduManager.shareManager logMessage:msg level:AgoraLogLevelError];
}

#pragma mark Check
+ (void)checkHttpError:(NSError *)error task:(NSURLSessionDataTask *)task success:(void (^)(id responseObj))success failure:(void (^)(NSError *error, NSInteger statusCode))failure {
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)task.response;
    
    NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
    if (errorData == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }
    
    NSDictionary *errorDataDict = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableLeaves error:nil];
    if (errorDataDict == nil) {
        failure(error, urlResponse.statusCode);
        return;
    }

    success(errorDataDict);
}

@end
