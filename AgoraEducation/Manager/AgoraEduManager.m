//
//  AgoraEduManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/7/27.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AgoraEduManager.h"
#import "KeyCenter.h"
#import "HTTPManager.h"
#import <YYModel/YYModel.h>
#import <EduSDK/EduConstants.h>

#define USER_PROPERTY_KEY_GROUP @"group"
#define ROOM_PROPERTY_KEY_BOARD @"board"

#define BREAKOUT_GROUP_MEMBER_LIMIT 4
#define MEDIUM_MEMBER_LIMIT 100

NSString * const kTeacherLimit = @"TeacherLimit";
NSString * const kAssistantLimit = @"AssistantLimit";
NSString * const kStudentLimit = @"StudentLimit";

@implementation SchduleClassConfig
@end

static AgoraEduManager *manager = nil;

@interface AgoraEduManager()
@property (nonatomic, assign) AgoraLogLevel logLevel;
@property (nonatomic, strong) NSString *logDirectoryPath;
@property (nonatomic, strong) AgoraLogManager *logManager;
@end

@implementation AgoraEduManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AgoraEduManager alloc] init];
        manager.logLevel = AgoraLogLevelInfo;
        
        NSString *logFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"/AgoraEducation"];
        manager.logDirectoryPath = logFilePath;
    });
    
    return manager;
}

- (void)initWithUserUuid:(NSString *)userUuid userName:(NSString *)userName tag:(NSInteger)tag success:(void (^) (void))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    EduConfiguration *config = [[EduConfiguration alloc] initWithAppId:KeyCenter.agoraAppid customerId:KeyCenter.customerId customerCertificate:KeyCenter.customerCertificate userUuid:userUuid userName:userName];
    config.logLevel = self.logLevel;
    config.logDirectoryPath = self.logDirectoryPath;
    config.tag = tag;
    self.eduManager = [[EduManager alloc] initWithConfig:config success:successBlock failure:^(NSError * _Nonnull error) {
        failureBlock(error.localizedDescription);
    }];
    
    self.whiteBoardManager = [WhiteBoardManager new];
}

// schedule class
- (void)scheduleClassWithConfig:(SchduleClassConfig *)config success:(OnSchduleClassSuccessBlock)successBlock failure:(OnHttpFailureBlock _Nullable)failureBlock {
    
    NSMutableDictionary *roomProperty = [NSMutableDictionary dictionary];
    [roomProperty setObject:@1 forKey:kTeacherLimit];
    switch (config.sceneType) {
        case EduSceneType1V1:
            [roomProperty setObject:@0 forKey:kAssistantLimit];
            [roomProperty setObject:@1 forKey:kStudentLimit];
            break;
        case EduSceneTypeSmall:
            [roomProperty setObject:@0 forKey:kAssistantLimit];
            [roomProperty setObject:@16 forKey:kStudentLimit];
            break;
        case EduSceneTypeBig:
            [roomProperty setObject:@0 forKey:kAssistantLimit];
            [roomProperty setObject:@(-1) forKey:kStudentLimit];
            break;
        case EduSceneTypeBreakout:
            [roomProperty setObject:@1 forKey:kAssistantLimit];
            [roomProperty setObject:@(-1) forKey:kStudentLimit];
            break;
        case EduSceneTypeMedium:
            [roomProperty setObject:@0 forKey:kAssistantLimit];
            [roomProperty setObject:@(MEDIUM_MEMBER_LIMIT) forKey:kStudentLimit];
            break;
        default:
            break;
    }
    
    NSMutableDictionary *roleConfigDic = [NSMutableDictionary dictionary];
    for(NSString *key in roomProperty.allKeys) {
        if([key isEqualToString:kTeacherLimit]) {
            
            NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:roomProperty[key], @"limit", nil];
            roleConfigDic[kServiceRoleHost] = dic1;
            
        } else if([key isEqualToString:kAssistantLimit]) {
            
            NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:roomProperty[key], @"limit", nil];
             roleConfigDic[kServiceRoleAssistant] = dic1;
            
        } else if([key isEqualToString:kStudentLimit]) {
            
            NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:roomProperty[key], @"limit", nil];
            
            if(config.sceneType == EduSceneTypeBig || config.sceneType == EduSceneTypeMedium || config.sceneType == EduSceneTypeBreakout) {
                roleConfigDic[kServiceRoleAudience] = dic1;
            } else {
                roleConfigDic[kServiceRoleBroadcaster] = dic1;
            }
        }
    }
    
    SchduleClassConfiguration *httpConfig = [SchduleClassConfiguration new];
    httpConfig.appId = KeyCenter.agoraAppid;
    httpConfig.roomUuid = config.roomUuid;
    httpConfig.customerId = KeyCenter.customerId;
    httpConfig.customerCertificate = KeyCenter.customerCertificate;
    httpConfig.roomName = config.roomName;
    httpConfig.roleConfig = roleConfigDic;
    
    httpConfig.roomProperties = @{};
    if (config.roomProperty != nil) {
        httpConfig.roomProperties = config.roomProperty;
    }
    [HTTPManager schduleClassWithConfig:httpConfig success:^(SchduleModel * _Nonnull schduleModel) {
        
            if (successBlock != nil) {
                successBlock(schduleModel);
            }
        } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
            if (failureBlock != nil) {
                failureBlock(error, statusCode);
            }
        }
     ];
}

- (void)schduleClassroomWithConfig:(SchduleClassConfig *)config success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock {
    
    WEAK(self);
    [self scheduleClassWithConfig:config success:^(SchduleModel * _Nonnull schduleModel) {
        
        // At present, the classroom already exists online. It is recommended that you put the interface for creating a room into your own server.
        // 当前线上已经有该教室了，建议你把创建房间的接口放到你自己的服务端。
        if (schduleModel.code == 20409100 || schduleModel.code == 0) {
            EduClassroomConfig *classroomConfig = [EduClassroomConfig new];
            classroomConfig.roomUuid = config.roomUuid;
            classroomConfig.sceneType = config.sceneType;
            // 超小学生会加入2个房间： 老师的房间(大班课)和小组的房间（小班课）
            if (config.sceneType == EduSceneTypeBreakout) {
                classroomConfig.sceneType = EduSceneTypeBig;
            }
            weakself.roomManager = [weakself.eduManager createClassroomWithConfig:classroomConfig];
            successBlock();
        } else {
            failureBlock(schduleModel.msg);
        }

    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        failureBlock(error.localizedDescription);
    }];
}

- (void)joinClassroomWithSceneType:(EduSceneType)sceneType userName:(NSString*)userName success:(void (^) (void))successBlock failure:(void (^) (NSString * _Nonnull errorMsg))failureBlock {
    
    WEAK(self);
    EduClassroomJoinOptions *options = [[EduClassroomJoinOptions alloc] initWithUserName:userName role:EduRoleTypeStudent];
    // 大班课不自动发流
    if (sceneType == EduSceneTypeBig || sceneType == EduSceneTypeBreakout || sceneType == EduSceneTypeMedium) {
        options.mediaOption.autoPublish = NO;
    } else {
        options.mediaOption.autoPublish = YES;
    }
    [self.roomManager joinClassroom:options success:^(EduUserService * _Nonnull studentService) {
        
        weakself.studentService = (EduStudentService*)studentService;
        if(sceneType != EduSceneTypeBreakout) {
            successBlock();
            return;
        }

        // 超小学生会加入2个房间： 老师的房间(大班课)和小组的房间（小班课）
        [weakself getGroupClassInfoWithSuccess:^(NSString *roomUuid, NSString *roomName) {

            EduClassroomConfig *classroomConfig = [EduClassroomConfig new];
            classroomConfig.roomUuid = roomUuid;
            classroomConfig.sceneType = EduSceneTypeSmall;
            weakself.groupRoomManager = [weakself.eduManager createClassroomWithConfig:classroomConfig];
            
            EduClassroomJoinOptions *options = [[EduClassroomJoinOptions alloc] initWithUserName:userName role:EduRoleTypeStudent];
            [weakself.groupRoomManager joinClassroom:options success:^(EduUserService * _Nonnull userService) {
                weakself.groupStudentService = (EduStudentService*)userService;
                successBlock();
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
            
        } failure:failureBlock];
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

- (void)getWhiteBoardInfoWithSuccess:(void (^) (NSString *boardId, NSString *boardToken))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    WEAK(self);
    [self.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
        
        if(room.roomProperties && room.roomProperties[ROOM_PROPERTY_KEY_BOARD]) {
            
            BoardDataModel *boardDataModel =
            [BoardDataModel yy_modelWithDictionary:room.roomProperties[ROOM_PROPERTY_KEY_BOARD]];
            
            successBlock(boardDataModel.info.boardId, boardDataModel.info.boardToken);
            return;
            
        } else {
            [weakself.roomManager getLocalUserWithSuccess:^(EduLocalUser * _Nonnull user) {
                
                BoardInfoConfiguration *config = [BoardInfoConfiguration new];
                config.appId = KeyCenter.agoraAppid;
                config.roomUuid = room.roomInfo.roomUuid;
                config.userToken = user.userToken;
                config.customerId = KeyCenter.customerId;
                config.customerCertificate = KeyCenter.customerCertificate;
                
                [HTTPManager getBoardInfoWithConfig:config success:^(BoardModel * _Nonnull boardModel) {
                    
                    if(boardModel.code != 0){
                        failureBlock(boardModel.msg);
                        return;
                    }
                    
                    BoardInfoModel *boardInfoModel = boardModel.data.info;
                    successBlock(boardInfoModel.boardId, boardInfoModel.boardToken);
                    
                } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                    failureBlock(error.localizedDescription);
                }];
                
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
        }
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

- (void)logMessage:(NSString *)message level:(AgoraLogLevel)level {
    
    if (self.eduManager != nil) {
        [self.eduManager logMessage:message level:level];
    } else {
        [self.logManager logMessage:message level:level];
    }
}

- (void)uploadDebugItemSuccess:(OnDebugItemUploadSuccessBlock) successBlock failure:(EduFailureBlock _Nullable)failureBlock {
    
    if (self.eduManager != nil) {
        EduDebugItem item = EduDebugItemLog;
        [self.eduManager uploadDebugItem:item success:successBlock failure:failureBlock];
    } else {
        AgoraLogUploadOptions *options = [AgoraLogUploadOptions new];
        options.appId = KeyCenter.agoraAppid;
        [self.logManager uploadLogWithOptions:options progress:nil success:successBlock failure:failureBlock];
    }
}

- (AgoraLogManager *)logManager {
    if(_logManager == nil) {
        AgoraLogManager *manager = [AgoraLogManager new];

        AgoraLogConfiguration *config = [AgoraLogConfiguration new];
        config.consoleState = AgoraLogConsoleStateClose;
        config.logLevel = AgoraLogLevelInfo;
        config.directoryPath = self.logDirectoryPath;
        [manager setupLog:config];
        
        _logManager = manager;
    }
    return _logManager;
}

#pragma mark PRIVATE
- (void)getGroupClassInfoWithSuccess:(void (^) (NSString *groupRoomUuid, NSString *groupRoomName))successBlock failure:(void (^) (NSString *errorMsg))failureBlock {
    
    WEAK(self);
    [self.roomManager getLocalUserWithSuccess:^(EduLocalUser * _Nonnull user) {
        
        if(user.userProperties && user.userProperties[USER_PROPERTY_KEY_GROUP]) {
            AssignGroupDataModel *model =
            [AssignGroupDataModel yy_modelWithDictionary:user.userProperties[USER_PROPERTY_KEY_GROUP]];
            successBlock(model.roomUuid, model.roomName);
            
        } else {
            
            [weakself.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
                
                AssignGroupInfoConfiguration *assignConfig = [AssignGroupInfoConfiguration new];
                assignConfig.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                assignConfig.appId = KeyCenter.agoraAppid;
                assignConfig.userToken = user.userToken;
                assignConfig.customerId = KeyCenter.customerId;
                assignConfig.customerCertificate = KeyCenter.customerCertificate;
                assignConfig.roomUuid = room.roomInfo.roomUuid;
                
                // role config
                {
                    RoleConfiguration *host = [RoleConfiguration new];
                    host.limit = 1;
                    assignConfig.host = host;
                    
                    RoleConfiguration *assistant = [RoleConfiguration new];
                    assistant.limit = 1;
                    assignConfig.assistant = assistant;
                    
                    RoleConfiguration *broadcaster = [RoleConfiguration new];
                    broadcaster.limit = 4;
                    assignConfig.broadcaster = broadcaster;
                }
                
                [HTTPManager assignBreakOutGroupWithConfig:assignConfig success:^(AssignGroupModel * _Nonnull assignGroupModel) {
                    
                    if (assignGroupModel.code != 0) {
                        failureBlock(assignGroupModel.msg);
                        return;
                    }
                    
                    AssignGroupDataModel *model = assignGroupModel.data;
                    model.memberLimit = BREAKOUT_GROUP_MEMBER_LIMIT;
                    successBlock(model.roomUuid, model.roomName);
                    
                } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
                    failureBlock(error.localizedDescription);
                }];
                
            } failure:^(NSError * error) {
                failureBlock(error.localizedDescription);
            }];
        }
        
    } failure:^(NSError * error) {
        failureBlock(error.localizedDescription);
    }];
}

+ (void)releaseResource {
    
    [AgoraEduManager.shareManager.eduManager destory];
    AgoraEduManager.shareManager.roomManager = nil;
    AgoraEduManager.shareManager.groupRoomManager = nil;

    AgoraEduManager.shareManager.studentService = nil;
    AgoraEduManager.shareManager.groupStudentService = nil;
    
    [AgoraEduManager.shareManager.whiteBoardManager leaveBoardWithSuccess:nil failure:nil];
}

@end
