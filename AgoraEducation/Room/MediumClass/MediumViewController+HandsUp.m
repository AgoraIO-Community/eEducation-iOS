//
//  MediumViewController+HandsUp.m
//  AgoraEducation
//
//  Created by SRS on 2020/11/18.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "MediumViewController+HandsUp.h"
#import "GroupObject.h"
#import "KeyCenter.h"
#import <YYModel/YYModel.h>

@implementation MediumViewController (HandsUp)

- (void)setupHandsUp {
    if (!self.handsUpManager) {
        self.handsUpManager = [[AgoraHandsUpManagerOC alloc] init];
        self.handsUpManager.delegate = self;
        UIView *handsUp = [self.handsUpManager getHandsUpView];
        [self.handsUpBgView addSubview:handsUp];
        [handsUp equalTo:self.handsUpBgView];
        self.handsUpBgView.hidden = YES;
    }
}

- (void)initProcessManager {

    if (!self.processManager) {
        AgoraActionConfigOC *config = [[AgoraActionConfigOC alloc] init];
        config.appId = KeyCenter.agoraAppid;
        config.roomUuid = self.roomUuid;
        config.userToken = self.localUser.userToken;
        config.customerId = KeyCenter.customerId;
        config.customerCertificate = KeyCenter.customerCertificate;
        config.baseURL = BASE_URL;

        self.processManager = [[AgoraActionProcessManagerOC alloc] init:config];
    }
}

- (void)updateHandsUp {
    
    self.handsUpBgView.hidden = YES;
    
    [self initProcessManager];
    
    // how to do with group
//    if (self.localUser.streams && self.localUser.streams.count > 0) {
//        [self.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateHandsUp];
//    }
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {

        if(room.roomProperties == nil || ![room.roomProperties isKindOfClass:NSDictionary.class]) {
            return;
        }
        NSDictionary *handUpStatesDic = room.roomProperties[@"handUpStates"];
        HandUpStates *handUpStates = [HandUpStates yy_modelWithDictionary:handUpStatesDic];
        weakself.handUpStates = handUpStates;
        if(handUpStates && handUpStates.state == GroupCommonStateOn) {
            weakself.handsUpBgView.hidden = NO;
        }
        AgoraHandsUpOCType type = AgoraHandsUpOCTypeAutoPublish;
        if(handUpStates && handUpStates.autoCoVideo == GroupCommonStateOff) {
            type = AgoraHandsUpOCTypeApplyPublish;
        }
        
        AgoraActionConfigInfoResponseOC *configInfo = [self.processManager analyzeConfigInfoMessageWithRoomProperties:room.roomProperties].firstObject;
        NSInteger timeOut = 0;
        if(configInfo != nil){
            timeOut = configInfo.timeout;
        }
        
        [weakself.handsUpManager setHandsUpTypeWithType:type handsUpTimeOut:timeOut];
        
        weakself.processUuid = weakself.roomUuid;

    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

#pragma mark AgoraHandsUpManagerOCDelegate
- (void)onHandsClickedWithCurrentState:(AgoraHandsUpOCState)currentState {

    if (self.handUpStates == nil || self.handUpStates.state == GroupCommonStateOff) {
        return;
    }
    WEAK(self);
    [self actionProcessWithState:currentState success:^{
        if (weakself.handUpStates.autoCoVideo == GroupCommonStateOn && currentState != AgoraHandsUpOCStateHandsUp && weakself.localUser.streams.count == 0) {
            [weakself publishLocalStream];
        }
    }];
}
- (void)onHandsUpTimeOut {
    [BaseViewController showToast:NSLocalizedString(@"HandsUpTimeOutText", nil)];
}
- (void)publishLocalStream {
    
    EduStream *stream = [[EduStream alloc] initWithStreamUuid:self.localUser.streamUuid userInfo:self.localUser];
    stream.hasAudio = YES;
    stream.hasVideo = YES;
    stream.sourceType = EduVideoSourceTypeCamera;
    
    [AgoraEduManager.shareManager.studentService publishStream:stream success:^{
  
    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}
    
- (void)actionProcessWithState:(AgoraHandsUpOCState)currentState success:(void (^) (void))successBlock {
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {

        EduUser *teacher;
        for(EduUser *user in users) {
            if(user.role == EduRoleTypeTeacher){
                teacher = user;
                break;
            }
        }
        // teacher not in classroom
        if (teacher == nil) {
            return;
        }

        if (currentState != AgoraHandsUpOCStateHandsUp) {
            
            AgoraActionStartOptionsOC *options = [[AgoraActionStartOptionsOC alloc] init];
            options.toUserUuid = teacher.userUuid;
            options.processUuid = self.processUuid;
            options.fromUserUuid = self.localUser.userUuid;
            options.payload = @{
                @"action":@(AgoraActionTypeOCApply),
                @"fromUser":@{
                    @"uuid":self.localUser.userUuid,
                    @"name":self.localUser.userName,
                    @"role":@(self.localUser.role)
                }
            };
            [weakself.processManager startAgoraActionProcessWithOptions:options success:^(AgoraActionResponseOC * _Nonnull result) {

                if (result.code != 0) {
                    [BaseViewController showToast:result.msg];
                } else {
                    [weakself.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateHandsUp];
                    [BaseViewController showToast:NSLocalizedString(@"HandsUpSuccessText", nil)];
                    if (successBlock != nil) {
                        successBlock();
                    }
                }

            } failure:^(NSError * _Nonnull error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
            
        } else {
            
            AgoraActionStopOptionsOC *options = [[AgoraActionStopOptionsOC alloc] init];
            options.toUserUuid = teacher.userUuid;
            options.processUuid = self.processUuid;
            options.fromUserUuid = self.localUser.userUuid;
            options.action = AgoraActionTypeOCCancel;
            options.payload = @{
                @"action":@(AgoraActionTypeOCCancel),
                @"fromUser":@{
                    @"uuid":self.localUser.userUuid,
                    @"name":self.localUser.userName,
                    @"role":@(self.localUser.role)
                }
            };
            
            [weakself.processManager stopAgoraActionProcessWithOptions:options success:^(AgoraActionResponseOC * _Nonnull result) {
                
                if (result.code != 0) {
                    [BaseViewController showToast:result.msg];
                } else {
                    [weakself.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateHandsDown];
                    [BaseViewController showToast:NSLocalizedString(@"HandsDownSuccessText", nil)];
                    if (successBlock != nil) {
                        successBlock();
                    }
                }
                
            } failure:^(NSError * _Nonnull error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
        }

    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}
@end
