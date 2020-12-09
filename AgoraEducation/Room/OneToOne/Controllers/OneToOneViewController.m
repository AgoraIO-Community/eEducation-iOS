//
//  OneToOneViewController.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/10/30.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "OneToOneViewController.h"
#import "EENavigationView.h"
#import "EEChatTextFiled.h"
#import "EEMessageView.h"
#import "OTOTeacherView.h"
#import "OTOStudentView.h"
#import "UIView+Toast.h"
#import "WhiteBoardTouchView.h"
#import "HTTPManager.h"
#import <YYModel/YYModel.h>

@interface OneToOneViewController ()<UITextFieldDelegate, RoomProtocol, EduClassroomDelegate, EduStudentDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatRoomViewRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledRightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFiledBottomCon;

@property (weak, nonatomic) IBOutlet EENavigationView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *chatRoomView;
@property (weak, nonatomic) IBOutlet OTOTeacherView *teacherView;
@property (weak, nonatomic) IBOutlet OTOStudentView *studentView;
@property (weak, nonatomic) IBOutlet EEChatTextFiled *chatTextFiled;
@property (weak, nonatomic) IBOutlet EEMessageView *messageListView;
@property (weak, nonatomic) IBOutlet UIView *shareScreenView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *whiteboardBaseView;

@property (nonatomic, weak) WhiteBoardTouchView *whiteBoardTouchView;

@end

@implementation OneToOneViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self initData];
    [self addNotification];
}

- (void)initData {
    
    self.studentView.delegate = self;
    self.navigationView.delegate = self;
    self.chatTextFiled.contentTextFiled.delegate = self;
    
    [self.navigationView updateClassName:self.className];
}

- (void)lockViewTransform:(BOOL)lock {
    
    [AgoraEduManager.shareManager.whiteBoardManager  lockViewTransform:lock];
    
    self.whiteBoardTouchView.hidden = !lock;
}

- (void)setupView {
    
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    UIView *boardView = [whiteBoardManager getBoardView];
    [self.whiteboardBaseView addSubview:boardView];
    self.boardView = boardView;
    [boardView equalTo:self.whiteboardBaseView];

    self.tipLabel.layer.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7].CGColor;
    self.tipLabel.layer.cornerRadius = 6;

    WEAK(self);
    WhiteBoardTouchView *whiteBoardTouchView = [WhiteBoardTouchView new];
    [whiteBoardTouchView setupInView:boardView onTouchBlock:^{
        NSString *toastMessage = NSLocalizedString(@"LockBoardTouchText", nil);
        [BaseViewController showToast:toastMessage];
    }];
    self.whiteBoardTouchView = whiteBoardTouchView;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isChatTextFieldKeyboard) {
        CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        float bottom = frame.size.height;
        if(IsPad){
            self.textFiledWidthCon.constant = kScreenWidth;
        } else {
            BOOL isIphoneX = (MAX(kScreenHeight, kScreenWidth) / MIN(kScreenHeight, kScreenWidth) > 1.78) ? YES : NO;
            self.textFiledWidthCon.constant = isIphoneX ? kScreenWidth - 44 : kScreenWidth;
        }
        self.textFiledBottomCon.constant = bottom;
    }
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    if(IsPad){
        self.textFiledWidthCon.constant = 292;
    } else {
        self.textFiledWidthCon.constant = 222;
    }
    self.textFiledBottomCon.constant = 0;
}

- (void)setupWhiteBoard {
    
    WEAK(self);
    [self setupWhiteBoard:^{
        [AgoraEduManager.shareManager.whiteBoardManager allowTeachingaids:YES success:^{
            
            BOOL lock = weakself.boardState.follow;
            [weakself lockViewTransform:lock];
             
        } failure:^(NSError * error) {
            [BaseViewController showToast:error.localizedDescription];
        }];
    }];
}

- (void)updateTimeState  {
    [self updateTimeState:self.navigationView];
}

- (void)updateChatViews {
    [self updateChatViews:self.chatTextFiled];
}

- (IBAction)chatRoomViewShowAndHide:(UIButton *)sender {
    self.chatRoomViewRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.textFiledRightCon.constant = sender.isSelected ? 0.f : 222.f;
    self.chatRoomView.hidden = sender.isSelected ? NO : YES;
    self.chatTextFiled.hidden = sender.isSelected ? NO : YES;
    NSString *imageName = sender.isSelected ? @"view-close" : @"view-open";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    sender.selected = !sender.selected;
    
    [self.boardView layoutIfNeeded];
    [AgoraEduManager.shareManager.whiteBoardManager refreshViewSize];
}

- (void)updateRoleViews:(EduUser *) user {
    if(user.role == EduRoleTypeTeacher){
        [self.teacherView updateUserName:user.userName];
        
    } else if(user.role == EduRoleTypeStudent){
        [self.studentView updateUserName:user.userName];
    }
}
- (void)removeRoleViews:(EduUser *) user {
    if (user.role == EduRoleTypeTeacher) {
        [self.teacherView updateUserName:@""];
        
    } else if(user.role == EduRoleTypeStudent) {
        [self.studentView updateUserName:@""];
    }
}
- (void)updateRoleCanvas:(EduStream *)stream {
        
    if(stream.userInfo.role == EduRoleTypeTeacher) {
        if(stream.sourceType == EduVideoSourceTypeCamera) {
            
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.teacherView.videoRenderView : nil) stream:stream];
            
            self.teacherView.defaultImageView.hidden = stream.hasVideo ? YES : NO;
            [self.teacherView updateSpeakerEnabled:stream.hasAudio];
            
        } else if(stream.sourceType == EduVideoSourceTypeScreen) {
            EduRenderConfig *config = [EduRenderConfig new];
            config.renderMode = EduRenderModeFit;
            [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.shareScreenView : nil) stream:stream renderConfig:config];
            self.shareScreenView.hidden = NO;
        }
    } else if(stream.userInfo.role == EduRoleTypeStudent) {
        
        [AgoraEduManager.shareManager.studentService setStreamView:(stream.hasVideo ? self.studentView.videoRenderView : nil) stream:stream];
        [self.studentView updateVideoImageWithMuted:!stream.hasVideo];
        [self.studentView updateAudioImageWithMuted:!stream.hasAudio];
    }
}
- (void)removeRoleCanvas:(EduStream *)stream {
    [AgoraEduManager.shareManager.studentService setStreamView:nil stream:stream];
    
    if (stream.userInfo.role == EduRoleTypeTeacher) {
        if (stream.sourceType == EduVideoSourceTypeScreen) {
            self.shareScreenView.hidden = YES;
        } else if (stream.sourceType == EduVideoSourceTypeCamera) {
            self.teacherView.defaultImageView.hidden = NO;
            [self.teacherView updateSpeakerEnabled:NO];
        }
    } else {
        [self.studentView updateVideoImageWithMuted:YES];
        [self.studentView updateAudioImageWithMuted:YES];
    }
}

#pragma mark RoomProtocol
- (void)closeRoom {

    WEAK(self);
    [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"QuitClassroomText", nil) sureHandler:^(UIAlertAction * _Nullable action) {

        [weakself.navigationView stopTimer];
        [AgoraEduManager releaseResource];
        [weakself dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)muteVideoStream:(BOOL)mute {
    [self setLocalStreamVideo:!mute audio:self.studentView.hasAudio streamState:LocalStreamStateUpdate];
}

- (void)muteAudioStream:(BOOL)mute {
    [self setLocalStreamVideo:self.studentView.hasVideo audio:!mute streamState:LocalStreamStateUpdate];
}

#pragma mark EduClassroomDelegate
// User in or out
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersInit:(NSArray<EduUser*> *)users {
    for (EduUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersJoined:(NSArray<EduUser*> *)users {
    for (EduUser *user in users) {
        [self updateRoleViews:user];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteUsersLeft:(NSArray<EduUserEvent*> *)events leftType:(EduUserLeftType)type {
    for (EduUserEvent *event in events) {
        [self removeRoleViews:event.modifiedUser];
    }
}

// message
- (void)classroom:(EduClassroom * _Nonnull)classroom roomChatMessageReceived:(EduTextMessage *)textMessage {
    EETextMessage *message = [EETextMessage new];
    message.fromUser = textMessage.fromUser;
    message.message = textMessage.message;
    message.timestamp = textMessage.timestamp;

    [self.messageListView addMessageModel:message];
}

// stream
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsInit:(NSArray<EduStream*> *)streams {
    for (EduStream *stream in streams) {
        [self updateRoleCanvas:stream];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsAdded:(NSArray<EduStreamEvent*> *)events {
    for (EduStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(EduClassroom *)classroom remoteStreamUpdated:(NSArray<EduStreamEvent*> *)events {
    for (EduStreamEvent *event in events) {
        [self updateRoleCanvas:event.modifiedStream];
    }
}
- (void)classroom:(EduClassroom * _Nonnull)classroom remoteStreamsRemoved:(NSArray<EduStreamEvent*> *)events  {
    for (EduStreamEvent *event in events) {
        [self removeRoleCanvas:event.modifiedStream];
    }
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
- (void)localStreamAdded:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamUpdated:(EduStreamEvent*)event {
    self.localUser.streams = @[event.modifiedStream];
    [self updateRoleCanvas:event.modifiedStream];
}
- (void)localStreamRemoved:(EduStreamEvent*)event {
    self.localUser.streams = @[];
    [self removeRoleCanvas:event.modifiedStream];
}
- (void)localUserStateUpdated:(EduUserEvent*)event changeType:(EduUserStateChangeType)changeType {
    [self updateChatViews];
}

#pragma mark UITextFieldDelegate
- (void)onSendMessage:(EETextMessage *)message {
    [self.messageListView addMessageModel:message];
}

#pragma mark onSyncSuccess
- (void)onSyncSuccess {
    [self setupWhiteBoard];
    [self updateTimeState];
    [self updateChatViews];
    [self updateRoleViews: self.localUser];
}

#pragma mark onReconnected
- (void)onReconnected {
    [self updateTimeState];
    [self updateChatViews];
    
    BOOL lock = self.boardState.follow;
    [self lockViewTransform:lock];
    
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getFullUserListWithSuccess:^(NSArray<EduUser *> * _Nonnull users) {
        for(EduUser *user in users){
            [weakself updateRoleViews:user];
        }
    } failure:^(NSError * error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
    
    [AgoraEduManager.shareManager.roomManager getFullStreamListWithSuccess:^(NSArray<EduStream *> * _Nonnull streams) {
        for(EduStream *stream in streams){
            [weakself updateRoleCanvas:stream];
        }
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
    [self.messageListView addMessageModel:textMsg];
}

@end
