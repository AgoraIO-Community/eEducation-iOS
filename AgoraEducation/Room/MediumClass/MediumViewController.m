//
//  SmallViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MediumViewController.h"
#import "EENavigationView.h"
#import "MCStudentVideoListView.h"
#import "MCTeacherVideoView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "MCStudentListView.h"
#import "MCSegmentedView.h"
#import "MCStudentVideoCell.h"
#import "UIView+Toast.h"
#import "HTTPManager.h"
#import <YYModel/YYModel.h>
#import "AgoraCloudClass-Swift.h"
#import "InvitationModel.h"
#import "CustomAlertView.h"

#define NoNullDictionary(x) ([x isKindOfClass:NSDictionary.class] ? x : @{})
#define NoNullString(x) ([x isKindOfClass:NSString.class] ? x : @"")
#define VideoConstraint (IsPad ? 140 : 80)

#define AlertMaxCount 10

@interface MediumViewController ()<UITextFieldDelegate, RoomProtocol, EduClassroomDelegate, EduStudentDelegate, EduManagerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoManagerViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topStudentListTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btmStudentListBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topStudentListHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btmStudentListHeightCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *topStudentVideoListView;
@property (strong, nonatomic) NSMutableArray<StudentVideoStream *> *topStudentVideoList;
@property (weak, nonatomic) IBOutlet MCStudentVideoListView *btmStudentVideoListView;
@property (strong, nonatomic) NSMutableArray<StudentVideoStream *> *btmStudentVideoList;
@property (weak, nonatomic) IBOutlet MCTeacherVideoView *teacherVideoView;
@property (weak, nonatomic) IBOutlet UIView *roomManagerView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageView;
@property (weak, nonatomic) IBOutlet GroupListView *studentListView;
@property (weak, nonatomic) IBOutlet MCSegmentedView *segmentedView;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (assign, nonatomic) BOOL hasVideo;
@property (assign, nonatomic) BOOL hasAudio;

@property (weak, nonatomic) CustomAlertView *invitationAudioView;
@property (weak, nonatomic) CustomAlertView *invitationVideoView;

@end

@implementation MediumViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self initData];
    [self addNotification];
    
    [self onSyncSuccess];
}

- (void)initData {
    self.hasVideo = YES;
    self.hasAudio = YES;
    
    self.chatTextFiled.contentTextFiled.delegate = self;
    self.navigationView.delegate = self;
    AgoraEduManager.shareManager.eduManager.delegate = self;
    
    [self initSelectSegmentBlock];
    [self initStudentRenderBlock];

    [self.navigationView updateClassName:self.className];
    
    self.topStudentVideoList = [NSMutableArray array];
    self.btmStudentVideoList = [NSMutableArray array];
}

- (void)lockViewTransform:(BOOL)lock {
    [AgoraEduManager.shareManager.whiteBoardManager lockViewTransform:lock];
}

- (void)setupHandsUp {
    NSAssert(1, @"category realization");
}
- (void)updateHandsUp {
    NSAssert(1, @"category realization");
}
- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        BOOL lock = weakself.boardState.follow;
        [weakself lockViewTransform:lock];
    }];
}

- (void)updateTimeState {
    [self updateTimeState:self.navigationView];
}

- (void)updateChatViews {
    [self updateChatViews:self.chatTextFiled];
}

- (void)setupView {
    
    self.segmentedView.segmentType = SegmentTypeList;
    [self.studentListView setupTableView];
    self.studentListView.muteDelegate = self;
    
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    UIView *boardView = [whiteBoardManager getBoardView];
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    [boardView equalTo:self.whiteboardBaseView];

    self.roomManagerView.layer.borderWidth = 1.f;
    self.roomManagerView.layer.borderColor = [UIColor colorWithHexString:@"DBE2E5"].CGColor;

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;
    
    self.topStudentListHeightCon.constant = VideoConstraint;
    self.btmStudentListHeightCon.constant = VideoConstraint;
    self.topStudentListTopCon.constant = -VideoConstraint;
    self.btmStudentListBottomCon.constant = -VideoConstraint;
    self.topStudentVideoListView.hidden = YES;
    self.btmStudentVideoListView.hidden = YES;
    
    self.topStudentVideoListView.itemSize = CGSizeMake(VideoConstraint, VideoConstraint);
    self.btmStudentVideoListView.itemSize = CGSizeMake(VideoConstraint, VideoConstraint);
    [self setupHandsUp];
}

- (void)initStudentRenderBlock {
    WEAK(self);
    [self.topStudentVideoListView setStudentVideoList:^(MCStudentVideoCell * _Nonnull cell, EduStream *stream) {

        [AgoraEduManager.shareManager.studentService setStreamView:cell.videoCanvasView stream:stream];
        if([stream.userInfo.userUuid isEqualToString:weakself.localUser.userUuid]) {
            weakself.hasVideo = stream.hasVideo;
            weakself.hasAudio = stream.hasAudio;
        }
    }];
    [self.btmStudentVideoListView setStudentVideoList:^(MCStudentVideoCell * _Nonnull cell, EduStream *stream) {

        [AgoraEduManager.shareManager.studentService setStreamView:cell.videoCanvasView stream:stream];
        if([stream.userInfo.userUuid isEqualToString:weakself.localUser.userUuid]) {
            weakself.hasVideo = stream.hasVideo;
            weakself.hasAudio = stream.hasAudio;
        }
    }];
}

- (void)initSelectSegmentBlock {
    WEAK(self);
    [self.segmentedView setSelectIndex:^(NSInteger index) {
        if (index == 1) {
            weakself.messageView.hidden = NO;
            weakself.chatTextFiled.hidden = NO;
            weakself.studentListView.hidden = YES;
        }else {
            weakself.messageView.hidden = YES;
            weakself.chatTextFiled.hidden = YES;
            weakself.studentListView.hidden = NO;
        }
    }];
}

#pragma mark ---------------------------- Notification ---------------------
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        self.chatTextFiledBottomCon.constant = bottom;
        BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
        self.chatTextFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.chatTextFiledBottomCon.constant = 0;
    self.chatTextFiledWidthCon.constant = 222;
}

#pragma mark UPDATE
- (void)updateRoleViews:(NSArray<id> *)objModels {
    if (objModels.count == 0){
        return;
    }
    
    BOOL refreshStudentList = NO;
    if([objModels.firstObject isKindOfClass:EduUserEvent.class]) {
        for (EduUserEvent *event in objModels) {
            if(event.modifiedUser.role == EduRoleTypeTeacher){
                [self updateTeacherViews:event.modifiedUser];
            } else if(event.modifiedUser.role == EduRoleTypeStudent) {
                refreshStudentList = YES;
            }
        }
    } else if([objModels.firstObject isKindOfClass:EduUser.class]) {
        for (EduUser *user in objModels) {
            if(user.role == EduRoleTypeTeacher){
                [self updateTeacherViews:user];
            } else if(user.role == EduRoleTypeStudent) {
                refreshStudentList = YES;
            }
        }
    }
    
    // refresh student list by roomProperty
    if(refreshStudentList) {
        [self updateStudentList];
    }
}
- (void)updateTeacherViews:(EduUser *)user {
    [self.teacherVideoView updateUserName:user.userName];
}
- (void)removeTeacherViews:(EduUser *)user {
    [self.teacherVideoView updateUserName:@""];
}
- (void)updateRoleCanvas:(NSArray<id> *)objModels {
    if (objModels.count == 0){
        return;
    }
    
    BOOL hasStudent = NO;
    if([objModels.firstObject isKindOfClass:EduStreamEvent.class]) {
        for (EduStreamEvent *event in objModels) {
            if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher){
                [self updateTeacherCanvas:event.modifiedStream];
                
            } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
                hasStudent = YES;
            }
        }
    } else if([objModels.firstObject isKindOfClass:EduStream.class]) {
        for (EduStream *stream in objModels) {
            if(stream.userInfo.role == EduRoleTypeTeacher){
                [self updateTeacherCanvas:stream];
                
            } else if(stream.userInfo.role == EduRoleTypeStudent) {
                hasStudent = YES;
            }
        }
    }
    
    if(hasStudent) {
        [self reloadStudentViews];
        [self updateStudentList];
    }
}
- (void)updateTeacherCanvas:(EduStream *)stream {
    if(stream.sourceType == EduVideoSourceTypeCamera) {
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teacherVideoView.videoRenderView : nil) stream:stream];
        
        self.teacherVideoView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
        
        NSString *imageName = stream.hasAudio ? @"icon-speaker" : @"icon-speakeroff-white";
        [self.teacherVideoView updateSpeakerImageName: imageName];
        
    } else if(stream.sourceType == EduVideoSourceTypeScreen) {
        EduRenderConfig *config = [EduRenderConfig new];
        config.renderMode = EduRenderModeFit;
        [AgoraEduManager.shareManager.studentService setStreamView:self.shareScreenView stream:stream renderConfig:config];
        self.shareScreenView.hidden = NO;
    }
}
- (void)removeTeacherCanvas:(EduStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    if (stream.sourceType == EduVideoSourceTypeScreen) {
        self.shareScreenView.hidden = YES;
    } else if (stream.sourceType == EduVideoSourceTypeCamera) {
        self.teacherVideoView.defaultImageView.hidden = NO;
        [self.teacherVideoView updateSpeakerImageName: @"icon-speakeroff-white"];
    }
}
- (void)removeStudentCanvas:(NSArray<EduStream*> *)streams {
    if(streams.count == 0){
        return;
    }
    for(EduStream *stream in streams){
        [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    }
    
    [self reloadStudentViews];
    [self updateStudentList];
}

#pragma mark RoomProtocol
- (void)muteVideoStream:(BOOL)mute {
    [self setLocalStreamVideo:!mute audio:self.hasAudio streamState:LocalStreamStateUpdate];
}

- (void)muteAudioStream:(BOOL)mute {
    [self setLocalStreamVideo:self.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
}

- (void)closeRoom {
    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [AgoraEduManager releaseResource];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark  --------  Mandatory landscape -------
- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (void)reloadStudentViews {
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
        
        NSDictionary *interactOutGroupsDic = NoNullDictionary(room.roomProperties[@"interactOutGroups"]);
        InteractOutGroups *interactOutGroups = [InteractOutGroups yy_modelWithDictionary:interactOutGroupsDic];
        NSDictionary *groups = NoNullDictionary(room.roomProperties[@"groups"]);
        NSDictionary *g2 = NoNullDictionary(groups[NoNullString(interactOutGroups.g2)]);
        GroupsInfo *group2Info = [GroupsInfo yy_modelWithDictionary:g2];
        
        NSDictionary *students = NoNullDictionary(room.roomProperties[@"students"]);

        [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
                    
            [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
                
                [weakself.topStudentVideoList removeAllObjects];
                [weakself.btmStudentVideoList removeAllObjects];
                for (EduStream *stream in streams) {
                    
                    if (stream.userInfo.role == EduRoleTypeTeacher){
                        continue;
                    }
                    
                    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", stream.userInfo.userUuid];
                    NSArray *userFilters = [users filteredArrayUsingPredicate:userPredicate];
                    if (userFilters == nil || userFilters.count == 0) {
                        continue;
                    }
                
                    // display
                    StudentVideoStream *videoStream = [[StudentVideoStream alloc] initWithStreamUuid:stream.streamUuid userInfo:stream.userInfo];
                    videoStream.streamName = stream.streamName;
                    videoStream.sourceType = stream.sourceType;
                    videoStream.hasVideo = stream.hasVideo;
                    videoStream.hasAudio = stream.hasAudio;
        
                    if (group2Info != nil && [group2Info.members containsObject:stream.userInfo.userUuid]) {
                        [weakself.btmStudentVideoList addObject:videoStream];
                    } else {
                        [weakself.topStudentVideoList addObject:videoStream];
                    }
                    
                    // find user
                    NSDictionary *studentDic = NoNullDictionary(students[stream.userInfo.userUuid]);
                    StudentInfo *studentInfo = [StudentInfo yy_modelWithDictionary:studentDic];
                    if(studentInfo != nil) {
                        videoStream.totalReward = studentInfo.reward;
                    }
                }
                
                weakself.topStudentListTopCon.constant = -VideoConstraint;
                weakself.btmStudentListBottomCon.constant = -VideoConstraint;
                weakself.topStudentVideoListView.hidden = YES;
                weakself.btmStudentVideoListView.hidden = YES;
                if (weakself.topStudentVideoList.count > 0) {
                    weakself.topStudentListTopCon.constant = 0;
                    weakself.topStudentVideoListView.hidden = NO;
                }
                if (weakself.btmStudentVideoList.count > 0) {
                    weakself.btmStudentListBottomCon.constant = 0;
                    weakself.btmStudentVideoListView.hidden = NO;
                }
                
                [weakself.topStudentVideoListView updateStudentArray:weakself.topStudentVideoList];
                [weakself.btmStudentVideoListView updateStudentArray:weakself.btmStudentVideoList];
                        
            } failure:^(NSError * _Nonnull error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
            
        } failure:^(NSError * _Nonnull error) {
            [weakself showTipWithMessage:error.localizedDescription];
        }];

    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

- (void)showTipWithMessage:(NSString *)toastMessage {

    self.tipLabel.hidden = NO;
    [self.tipLabel setText: toastMessage];

    WEAK(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       weakself.tipLabel.hidden = YES;
    });
}

#pragma mark EduManagerDelegate
- (void)userMessageReceived:(EduTextMessage*)textMessage {
    
    InvitationModel *model = [InvitationModel yy_modelWithJSON:textMessage.message];
    if(model == nil || model.cmd != INVITATION_CMD) {
        // action
        AgoraActionInfoResponseOC *action = [self.processManager analyzeActionMessageWithMessage:textMessage.message];
        if(action != nil && action.action == AgoraActionTypeOCReject) {
//            self showTipWithMessage:<#(NSString *)#>
            [self.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateNone];
        }
    } else {
        // the teacher invited the students to open the audio and video
        // [self invitationProcessWithModel: model];
    }
}

#pragma mark EduClassroomDelegate
// User in or out
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<EduUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<EduUser*> *)users {
    [self updateRoleViews:users];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<EduUserEvent*> *)events leftType:(EduUserLeftType)type {

    for (EduUserEvent *event in events) {
        if(event.modifiedUser.role == EduRoleTypeTeacher){
            [self removeTeacherViews:event.modifiedUser];
        } else if(event.modifiedUser.role == EduRoleTypeStudent) {
            // refresh student list by roomProperty
            [self updateStudentList];
        }
    }
}

// message
- (void)classroom:(EduClassroom * _Nonnull)classroom roomChatMessageReceived:(EduTextMessage *)textMessage {

    EETextMessage *message = [EETextMessage new];
    message.fromUser = textMessage.fromUser;
    message.message = textMessage.message;
    message.timestamp = textMessage.timestamp;

    [self.messageView addMessageModel:message];
}
// stream
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<EduStream*> *)streams {
    [self updateRoleCanvas:streams];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<EduStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(EduClassroom *)classroom remoteStreamUpdated:(NSArray<EduStreamEvent*> *)events {
    [self updateRoleCanvas:events];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events {
    
    NSMutableArray<EduStream *> *streams = [NSMutableArray array];
    for (EduStreamEvent *event in events) {
        if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher) {
            [self removeTeacherCanvas:event.modifiedStream];
        } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
            [streams addObject:event.modifiedStream];
        }
    }
    [self removeStudentCanvas:streams];
}
- (void)classroom:(EduClassroom * _Nonnull)classroom networkQualityChanged:(NetworkQuality)quality user:(EduBaseUser *)user {
    
    if([self.localUser.userUuid isEqualToString:user.userUuid]) {
        switch (quality) {
            case NetworkQualityHigh:
                [self.navigationView updateSignalImageName:@"icon-signal3"];
                break;
            case NetworkQualityMiddle:
                [self.navigationView updateSignalImageName:@"icon-signal2"];
                break;
            case NetworkQualityLow:
                [self.navigationView updateSignalImageName:@"icon-signal1"];
                break;
            default:
                break;
        }
    }
}

#pragma mark EduStudentDelegate
- (void)localUserLeft:(EduUserEvent*)event leftType:(EduUserLeftType)type {
    
    if (type == EduUserLeftTypeKickOff) {
        [AgoraEduManager releaseResource];
        [self dismissViewControllerAnimated:YES completion:^{
            [BaseViewController showToast:NSLocalizedString(@"KickOffClassroomText", nil)];
        }];
    }
}

- (void)localUserStateUpdated:(EduUserEvent*)event changeType:(EduUserStateChangeType)changeType {
    [self updateChatViews];
}
- (void)localStreamAdded:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:@[event.modifiedStream]];
    [self.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateDisabled];
}
- (void)localStreamUpdated:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:@[event.modifiedStream]];
    [self.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateDisabled];
}
- (void)localStreamRemoved:(EduStreamEvent*)event {
    self.localUser.streams = @[];
    
    if(event.modifiedStream.userInfo.role == EduRoleTypeTeacher) {
        [self removeTeacherCanvas:event.modifiedStream];
    } else if(event.modifiedStream.userInfo.role == EduRoleTypeStudent) {
        [self removeStudentCanvas:@[event.modifiedStream]];
    }
    
    [self.handsUpManager updateHandsUpWithState:AgoraHandsUpOCStateNone];
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(EETextMessage *)message {
     [self.messageView addMessageModel:message];
}


#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self updateStudentList];
    [self setupWhiteBoard];
    [self updateHandsUp];
    [self updateTimeState];
    [self updateChatViews];
}

- (void)updateStudentList {

    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
        
        [weakself updateStudentList:room.roomProperties];
        
        NSDictionary *students = NoNullDictionary(room.roomProperties[@"students"]);
        NSDictionary *student = students[weakself.localUser.userUuid];
        if([student isKindOfClass:NSDictionary.class]) {
            return;
        }
        
        NSString *key = [NSString stringWithFormat:@"students.%@", weakself.localUser.userUuid];
        
        StudentInfo *info = [[StudentInfo alloc] init];
        info.userName = weakself.localUser.userName;
        info.reward = 0;
        info.avatar = @"";
        info.streamUuid = weakself.localUser.streamUuid;
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval time = [date timeIntervalSince1970]*1000;
        info.timeStamap = time;
        
        NSString *value = [info yy_modelToJSONObject];
        NSDictionary *cause = @{@"cmd": @(PropertyCauseTypeStudentList).stringValue};
        
        [AgoraEduManager.shareManager.studentService setRoomProperties:@{key:value} cause:cause success:^{

        } failure:^(NSError * _Nonnull error) {
            [BaseViewController showToast:error.localizedDescription];
        }];
        
    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

#pragma mark onReconnected
- (void)onReconnected {
    [self updateStudentList];
    [self updateHandsUp];
    [self updateTimeState];
    [self updateChatViews];

    BOOL lock = self.boardState.follow;
    [self lockViewTransform:lock];
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
        for(EduUser *user in users){
            if(user.role == EduRoleTypeTeacher){
                [weakself updateTeacherViews:user];
                break;
            }
        }
        [weakself reloadStudentViews];
    } failure:^(NSError * error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

#pragma mark ClassRoom Update
- (void)onUpdateChatViews {
    [self updateChatViews];
}
- (void)onUpdateCourseState {
    [self updateTimeState];
}
- (void)onBoardFollowMode:(BOOL)enable {
    NSString *toastMessage;
    if(enable) {
        toastMessage = NSLocalizedString(@"LockBoardText", nil);
    } else {
        toastMessage = NSLocalizedString(@"UnlockBoardText", nil);
    }
    [BaseViewController showToast:toastMessage];
    [self lockViewTransform:enable];
}
- (void)onEndRecord {
    EETextMessage *textMsg = [EETextMessage new];
    EduUser *fromUser = [EduUser new];
    [fromUser setValue:@"system" forKey:@"userName"];
    textMsg.fromUser = fromUser;
    textMsg.message = NSLocalizedString(@"ReplayRecordingText", nil);
    textMsg.recordRoomUuid = self.roomUuid;
    [self.messageView addMessageModel:textMsg];
}
- (void)onUnknownPropertyUpdated:(EduClassroom *)classroom cause:(EduObject *)cause {
    
    NSDictionary *groupStatesDic =  NoNullDictionary(classroom.roomProperties[@"groupStates"]);
    GroupStates *groupStates = [GroupStates yy_modelWithDictionary:groupStatesDic];
    
    PropertyCause *propertyCause = [PropertyCause yy_modelWithDictionary:cause];
    switch (propertyCause.cmd) {
        case PropertyCauseTypeGroup:
        case PropertyCauseTypeGroupReset:
            [self updateStudentList: classroom.roomProperties];
            break;
        case PropertyCauseTypeGroupDiscuss:
            // none
            break;
        case PropertyCauseTypeGroupPK:
            // showPK
            [self updateStudentList: classroom.roomProperties];
            [self reloadStudentViews];
            break;
        case PropertyCauseTypeGroupAudio:
            // none
            break;
        case PropertyCauseTypeGroupReward:
        case PropertyCauseTypeStudentReward:
            
            if (propertyCause.cmd == PropertyCauseTypeGroupReward) {
                NSDictionary *groups = NoNullDictionary(NoNullDictionary(classroom.roomProperties)[@"groups"]);
                GroupsInfo *info = [GroupsInfo yy_modelWithDictionary:groups[propertyCause.groupUuid]];
                for(NSString *member in info.members) {
                    [NSNotificationCenter.defaultCenter postNotificationName:Notice_Reward_Effect object:member];
                }
            } else {
                [NSNotificationCenter.defaultCenter postNotificationName:Notice_Reward_Effect object:propertyCause.userUuid];
            }
            [self reloadStudentViews];
            if (groupStates.state == GroupCommonStateOn) {
                [self updateStudentList: classroom.roomProperties];
            }
            break;
        case PropertyCauseTypeHandsUp:
            [self updateHandsUp];
            break;
        case PropertyCauseTypeStudentList:
            [self updateStudentList: classroom.roomProperties];
            break;
        default:
            break;
    }
}

- (void)updateStudentList:(NSDictionary *)roomProperties {

    self.studentListView.localUserUuid = self.localUser.userUuid;
    
    NSDictionary *groupStatesDic =  NoNullDictionary(roomProperties[@"groupStates"]);
    NSDictionary *interactOutGroupsDic = roomProperties[@"interactOutGroups"];

    GroupStates *groupStates = [GroupStates yy_modelWithDictionary:groupStatesDic];
    InteractOutGroups *interactOutGroups = [InteractOutGroups yy_modelWithDictionary:interactOutGroupsDic];
    NSDictionary *groups = NoNullDictionary(roomProperties[@"groups"]);
    NSArray *keysArray = [groups allKeys];
    NSArray *groupKeyArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];

    self.studentListView.groupState = groupStates.state;
    
    // close group
    if (groupStates.state == GroupCommonStateOff) {
        
        WEAK(self);
        [self getGroupStudentList:roomProperties complete:^(NSArray<NoGroupStudentList *> *studentList) {
            
            // only show online students
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %d", 1];
            NSArray<NoGroupStudentList*> *filtes = [studentList filteredArrayUsingPredicate:predicate];
            
            weakself.studentListView.noGroups = filtes;
            [weakself.studentListView reloadData];
        }];
        
    } else {
        
        WEAK(self);
        [self getGroupStudentList:roomProperties complete:^(NSArray<NoGroupStudentList *> *studentList) {
                    
            // group list
            NSMutableArray<GroupStudentList *> *groupList = [NSMutableArray array];
                    
            for (NSString *key in groupKeyArray) {
                GroupsInfo *info = [GroupsInfo yy_modelWithDictionary:groups[key]];
                
                GroupStudentList *group = [GroupStudentList new];
                group.groupName = info.groupName;
                group.groupUuid = key;
                group.isPK = NO;
                if ([interactOutGroups.g1 isEqual:group.groupUuid] || [interactOutGroups.g2 isEqual:group.groupUuid]) {
                    group.isPK = YES;
                }
                
                NSMutableArray<NSPredicate *> *predicates = [NSMutableArray array];
                for (NSString *member in info.members) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userUuid = %@", member];
                    [predicates addObject:predicate];
                }

                NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:predicates];
                NSArray *userFilters = [studentList filteredArrayUsingPredicate:compoundPredicate];
                group.students = userFilters;
                
                [groupList addObject:group];
            }
            
            weakself.studentListView.groups = groupList;
            [weakself.studentListView reloadData];
        }];
    }
}

- (void)getGroupStudentList:(NSDictionary *)roomProperties complete:(void (^) (NSArray<NoGroupStudentList *> *))block {
    
    NSDictionary *students = NoNullDictionary(roomProperties[@"students"]);

    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
        
        [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
            
            // get student list
            NSMutableArray<NoGroupStudentList *> *studentList = [NSMutableArray array];
            for (NSString *key in students.allKeys) {
                NoGroupStudentList *info = [NoGroupStudentList yy_modelWithJSON:students[key]];
                info.userUuid = key;
                
                NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"userUuid = %@", info.userUuid];
                NSArray *userFilters = [users filteredArrayUsingPredicate:userPredicate];
                info.state = userFilters.count > 0 ? 1 : 0;
                
                NSPredicate *streamPredicate = [NSPredicate predicateWithFormat:@"userInfo.userUuid = %@", info.userUuid];
                NSArray *streamFilters = [streams filteredArrayUsingPredicate:streamPredicate];
                EduStream *stream = streamFilters.firstObject;
                if(stream != nil) {
                    MCStreamInfo *infoModel = [[MCStreamInfo alloc] initWithUserUuid:stream.userInfo.userUuid userName:stream.userInfo.userName hasAudio:stream.hasAudio hasVideo:stream.hasVideo streamState:1 userState:info.state];
                    info.stream = infoModel;
                }
                [studentList addObject:info];
            }
             
            block(studentList);
           
        } failure:^(NSError * _Nonnull error) {
            [BaseViewController showToast:error.localizedDescription];
        }];

    } failure:^(NSError * _Nonnull error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

#pragma mark invitation
- (void)invitationProcessWithModel: (InvitationModel *)model {
    
    NSString *tipMessage;
    if (model.payload.action == InvitationActionTypeAudio) {
        if(self.invitationAudioView != nil){
            return;
        }
        tipMessage = NSLocalizedString(@"TeaInvitationAudioText", nil);
    } else {
        if(self.invitationVideoView != nil){
            return;
        }
        tipMessage = NSLocalizedString(@"TeaInvitationVideoText", nil);
    }
    
    CustomAlertView *invitationView = [[CustomAlertView alloc] init];
    [invitationView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"CancelText", nil), NSLocalizedString(@"OKText", nil), nil]];
    
    WEAK(self);
    invitationView.onButtonTouchUpInside = ^(CustomAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        
        [alertView close];
        
        if (buttonIndex == 1) {
            
            EduStream *stream = [[EduStream alloc] initWithStreamUuid:weakself.localUser.streamUuid userInfo:weakself.localUser];
            stream.hasAudio = NO;
            stream.hasVideo = NO;
            if (weakself.localUser.streams != nil && weakself.localUser.streams.count > 0) {
                EduStream *localStream = weakself.localUser.streams.firstObject;
                stream.hasAudio = localStream.hasAudio;
                stream.hasVideo = localStream.hasVideo;
            }
            if (model.payload.action == InvitationActionTypeAudio) {
                stream.hasAudio = 1;
            } else {
                stream.hasVideo = 1;
            }
            
            if (weakself.localUser.streams != nil && weakself.localUser.streams.count > 0) {
                
                [AgoraEduManager.shareManager.studentService muteStream:stream success:^{
                            
                } failure:^(NSError * _Nonnull error) {
                    [BaseViewController showToast:error.localizedDescription];
                }];
                
            } else {
                [AgoraEduManager.shareManager.studentService publishStream:stream success:^{
                            
                } failure:^(NSError * _Nonnull error) {
                    [BaseViewController showToast:error.localizedDescription];
                }];
            }
        }
    };
    [invitationView setUseMotionEffects:true];
    
    UILabel *contentView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 90)];
    contentView.text = tipMessage;
    contentView.numberOfLines = 0;
    contentView.textColor = UIColor.blackColor;
    contentView.textAlignment = NSTextAlignmentCenter;
    [invitationView showWithContainerView:contentView];
    [invitationView startCountDown:AlertMaxCount];

    if (model.payload.action == InvitationActionTypeAudio) {
        self.invitationAudioView = invitationView;
    } else {
        self.invitationVideoView = invitationView;
    }
}
@end
