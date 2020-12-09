//
//  EduConfiguration.m
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import "EduConfiguration.h"

@implementation EduConfiguration

- (instancetype)initWithAppId:(NSString *)appId customerId:(NSString *)customerId customerCertificate:(NSString *)certificate userUuid:(NSString *)userUuid userName:(NSString *)userName {
    
    if (self = [super init]) {
        self.appId = appId;
        self.customerId = customerId;
        self.customerCertificate = certificate;
        
        self.userUuid = userUuid;
        self.userName = userName;
        
        self.logLevel = AgoraLogLevelInfo;
        
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
        self.logDirectoryPath = logFilePath;
    }

    return self;
}
@end
