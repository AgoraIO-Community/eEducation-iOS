//
//  InvitationModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/12/15.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INVITATION_CMD 10

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, InvitationActionType) {
    InvitationActionTypeAudio           = 0,
    InvitationActionTypeVideo           = 1,
};

@interface InvitationInfoModel : NSObject
@property (nonatomic, assign) InvitationActionType action;
@property (nonatomic, strong) EduUser *fromUser;
@property (nonatomic, strong) EduClassroomInfo *fromRoom;
@end

@interface InvitationModel : NSObject
@property (nonatomic, assign) NSInteger cmd; // 10
@property (nonatomic, strong) InvitationInfoModel *payload;
@end

NS_ASSUME_NONNULL_END
