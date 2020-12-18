//
//  HTTPConfiguration.h
//  AgoraEducation
//
//  Created by SRS on 2020/10/5.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// BoardInfo
@interface BoardInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;
@end

// RecordInfo
@interface RecordInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;
@end

// AssignGroupInfo
@interface RoleConfiguration : NSObject
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger verifyType;//default:0
@property (nonatomic, assign) NSInteger subscribe;//default:1
@end
@interface AssignGroupInfoConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;
@property (nonatomic, copy) NSString *userToken;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;

@property (nonatomic, assign) NSInteger memberLimit;
@property (nonatomic, strong) RoleConfiguration *host;
@property (nonatomic, strong) RoleConfiguration *assistant;
@property (nonatomic, strong) RoleConfiguration *broadcaster;
@end


// SchduleClassInfo
@interface SchduleClassConfiguration : NSObject
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *roomUuid;

@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *customerCertificate;

@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy) NSDictionary *roleConfig;
@property (nonatomic, copy) NSDictionary *roomProperties;

@end

NS_ASSUME_NONNULL_END
