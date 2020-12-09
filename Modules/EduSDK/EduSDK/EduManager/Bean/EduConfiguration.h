//
//  EduConfiguration.h
//  EduSDK
//
//  Created by SRS on 2020/7/6.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraLog/AgoraLog.h>

NS_ASSUME_NONNULL_BEGIN

@interface EduConfiguration : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;

@property (nonatomic, copy) NSString *userUuid;
@property (nonatomic, copy, nullable) NSString *userName;
@property (nonatomic, assign) NSInteger tag;

// default AgoraLogLevelInfo
@property (nonatomic, assign) AgoraLogLevel logLevel;
// default /AgoraEducation/
@property (nonatomic, copy, nullable) NSString *logDirectoryPath;

- (instancetype)initWithAppId:(NSString *)appId customerId:(NSString *)customerId customerCertificate:(NSString *)certificate userUuid:(NSString *)userUuid;

- (instancetype)initWithAppId:(NSString *)appId customerId:(NSString *)customerId customerCertificate:(NSString *)certificate userUuid:(NSString *)userUuid userName:(NSString *)userName;

@end

NS_ASSUME_NONNULL_END
