//
//  HTTPManager.h
//  AgoraEducation
//
//  Created by SRS on 2020/8/2.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "HTTPConfiguration.h"
#import "BoardModel.h"
#import "RecordModel.h"
#import "AssignGroupModel.h"
#import "SchduleModel.h"

#define BASE_URL @"https://api.agora.io"

// /scene/apps/{appId}/v1/rooms/{roomUuid}/config
#define HTTP_SCHDULE_CLASS @"%@/scene/apps/%@/v1/rooms/%@/config"

// /grouping/apps/{appId}/v1/rooms/{roomUuid}/groups
#define HTTP_BREAKOUT_GROUP_ROOM @"%@/grouping/apps/%@/v1/rooms/%@/groups"

// /board/apps/{appId}/v1/rooms/{roomUuid}
#define HTTP_BOARD_INFO @"%@/board/apps/%@/v1/rooms/%@"

// /recording/apps/{appId}/v1/rooms/{roomId}/records
#define HTTP_RECORD_INFO @"%@/recording/apps/%@/v1/rooms/%@/records"

typedef void(^OnHttpFailureBlock)(NSError * _Nonnull error, NSInteger statusCode);
// BoardInfo
typedef void(^OnBoardInfoGetSuccessBlock)(BoardModel * _Nonnull boardModel);
// RecordInfo
typedef void(^OnRecordInfoGetSuccessBlock)(RecordModel * _Nonnull recordModel);
// AssignGroupInfo
typedef void(^OnAssignBreakOutGroupSuccessBlock)(AssignGroupModel * _Nonnull assignGroupModel);
// SchduleClassInfo
typedef void(^OnSchduleClassSuccessBlock)(SchduleModel * _Nonnull schduleModel);

NS_ASSUME_NONNULL_BEGIN

@interface HTTPManager : NSObject

+ (void)schduleClassWithConfig:(SchduleClassConfiguration *)config  success:(OnSchduleClassSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

+ (void)getBoardInfoWithConfig:(BoardInfoConfiguration *)config  success:(OnBoardInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

+ (void)getRecordInfoWithConfig:(RecordInfoConfiguration *)config  success:(OnRecordInfoGetSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

+ (void)assignBreakOutGroupWithConfig:(AssignGroupInfoConfiguration *)config  success:(OnAssignBreakOutGroupSuccessBlock)successBlock failure:(OnHttpFailureBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
