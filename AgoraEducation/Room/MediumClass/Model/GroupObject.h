//
//  GroupObject.h
//  AgoraEducation
//
//  Created by SRS on 2020/11/20.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCStreamInfo.h"

typedef NS_ENUM(NSInteger, PropertyCauseType) {
    
    // unKnown
    PropertyCauseTypeUnKnown            = 0,
    
    // open/close group
    PropertyCauseTypeGroup              = 101,
    
    // reset group
    PropertyCauseTypeGroupReset         = 102,
    
    // open/close group discuss
    PropertyCauseTypeGroupDiscuss       = 103,
    
    // open/close group pk
    PropertyCauseTypeGroupPK            = 104,

    // open/close group audio
    PropertyCauseTypeGroupAudio         = 201,
    
    // group reward
    PropertyCauseTypeGroupReward        = 202,
    
    // handsUp state changed
    PropertyCauseTypeHandsUp            = 301,
    
    // student list changed
    PropertyCauseTypeStudentList        = 401,
    
    // student reward changed
    PropertyCauseTypeStudentReward      = 402,
};

typedef NS_ENUM(NSInteger, GroupCommonState) {
    GroupCommonStateOff          = 0,
    GroupCommonStateOn           = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface PropertyCause : NSObject

@property (nonatomic, assign) PropertyCauseType cmd;
@property (nonatomic, strong) NSString *groupUuid;
@property (nonatomic, strong) NSString *userUuid;

@end

@interface GroupStates : NSObject
// open/reset/close group 
@property (nonatomic, assign) GroupCommonState state;
// GroupDiscuse
@property (nonatomic, assign) GroupCommonState interactInGroup;
// GroupPK
@property (nonatomic, assign) GroupCommonState interactOutGroup;
@end

@interface GroupsInfo : NSObject
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSArray<NSString *> *members;
@property (nonatomic, strong) NSDictionary *groupProperties;
@end

@interface InteractOutGroups : NSObject
@property (nonatomic, strong) NSString *g1; // PK group1
@property (nonatomic, strong) NSString *g2; // PK group2
@end

@interface StudentInfo : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) NSInteger reward;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *streamUuid;
@property (nonatomic, assign) NSInteger timeStamap;
@end

//
@interface NoGroupStudentList : StudentInfo
@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, assign) NSInteger state;// 0=offline  1= online
@property (nonatomic, strong, nullable) MCStreamInfo *stream;
@end

//
@interface GroupStudentList : NSObject
@property (nonatomic, assign) BOOL isPK;
@property (nonatomic, strong) NSString *groupUuid;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSArray<NoGroupStudentList *> *students;
@end
NS_ASSUME_NONNULL_END


