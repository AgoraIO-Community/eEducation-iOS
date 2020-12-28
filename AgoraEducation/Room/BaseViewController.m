//
//  BaseViewController.m
//  AgoraEducation
//
//  Created by SRS on 2020/8/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+Toast.h"
#import "KeyCenter.h"
#import <YYModel/YYModel.h>
#import "RecordPropertyModel.h"
#import "TextMessageModel.h"

#define ROOM_PROPERTY_KEY_RECORD @"record"

@interface BaseViewController ()<EduClassroomDelegate, EduStudentDelegate, WhiteManagerDelegate>

@property (nonatomic, assign) BOOL hasSignalReconnect;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (@available(iOS 11, *)) {
        
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    [self initActivityIndicator];
    [self setLoadingVisible:YES];
    AgoraEduManager.shareManager.roomManager.delegate = self;
    AgoraEduManager.shareManager.studentService.delegate = self;
    if (self.sceneType == EduSceneTypeBreakout) {
        AgoraEduManager.shareManager.groupRoomManager.delegate = self;
        AgoraEduManager.shareManager.groupStudentService.delegate = self;
    }
    
    self.hasSignalReconnect = NO;
    [self initLocalUser];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)initActivityIndicator {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    activityIndicator.frame = CGRectMake(0, 0, 100, 100);
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.backgroundColor = [UIColor clearColor];
    activityIndicator.hidesWhenStopped = YES;
    [UIApplication.sharedApplication.keyWindow  addSubview:activityIndicator];
    [activityIndicator centerTo:UIApplication.sharedApplication.keyWindow];
    
    self.activityIndicator = activityIndicator;
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

- (void)setLocalStreamVideo:(BOOL)hasVideo audio:(BOOL)hasAudio streamState:(LocalStreamState)state {

    EduStreamConfig *config = [EduStreamConfig new];
    config.streamUuid = self.localUser.streamUuid;
    config.streamName = @"";
    config.enableCamera = hasVideo;
    config.enableMicrophone = hasAudio;
    
    WEAK(self);
    EduStudentService *studentService = AgoraEduManager.shareManager.studentService;
    if(self.sceneType == EduSceneTypeBreakout) {
        studentService = AgoraEduManager.shareManager.groupStudentService;
    }
    [studentService startOrUpdateLocalStream:config success:^(EduStream * _Nonnull stream) {
        
        if (state == LocalStreamStateRemove) {
            [studentService unpublishStream:stream success:^{
                
            } failure:^(NSError * error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
        } else if(state == LocalStreamStateUpdate) {
            [studentService muteStream:stream success:^{
                
            } failure:^(NSError * error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
        } else if(state == LocalStreamStateCreate) {
            [studentService publishStream:stream success:^{
                
            } failure:^(NSError * error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
        }
    } failure:^(NSError * error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

- (void)initLocalUser {
    
    EduClassroomManager *roomManager = AgoraEduManager.shareManager.roomManager;
    if(self.sceneType == EduSceneTypeBreakout) {
        roomManager = AgoraEduManager.shareManager.groupRoomManager;
    }
    
    WEAK(self);
    [roomManager getLocalUserWithSuccess:^(EduLocalUser * _Nonnull user) {
        weakself.localUser = user;
    } failure:^(NSError * error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

- (void)setupWhiteBoard:(void (^) (void))success {
    WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
    whiteBoardManager.delegate = self;
    WhiteBoardConfiguration *config = [WhiteBoardConfiguration new];
    config.appId = KeyCenter.boardAppid;
    [whiteBoardManager initBoardWithView:self.boardView config:config];
    
    [self setLoadingVisible:YES];
    
    WEAK(self);
    [AgoraEduManager.shareManager getWhiteBoardInfoWithSuccess:^(NSString * _Nonnull boardId, NSString * _Nonnull boardToken) {
        
        WhiteBoardJoinOptions *options = [WhiteBoardJoinOptions new];
        options.boardId = boardId;
        options.boardToken = boardToken;
        [whiteBoardManager joinBoardWithOptions:options success:^{
            
            WhiteBoardManager *whiteBoardManager = AgoraEduManager.shareManager.whiteBoardManager;
            weakself.boardState = [whiteBoardManager getWhiteBoardStateModel];
            
            [weakself setLoadingVisible:NO];
            if (success) {
                success();
            }
            
        } failure:^(NSError * error) {
            [weakself setLoadingVisible:NO];
            [BaseViewController showToast:error.localizedDescription];
        }];
        
    } failure:^(NSString * errorMsg) {
        [weakself setLoadingVisible:NO];
        [BaseViewController showToast:errorMsg];
    }];
}

- (void)updateTimeState:(EENavigationView *)navigationView {
    
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
        
        if(room.roomState.courseState == EduCourseStateStart) {
            NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval currenTimeInterval = [currentDate timeIntervalSince1970];
            [navigationView initTimerCount:(NSInteger)((currenTimeInterval * 1000 - room.roomState.startTime) * 0.001)];
            [navigationView startTimer];
        } else  {
            [navigationView stopTimer];
        }
        
    } failure:^(NSError * error) {
        [navigationView stopTimer];
        [BaseViewController showToast:error.localizedDescription];
    }];
}

- (void)updateChatViews:(EEChatTextFiled *)chatTextFiled {
    WEAK(self);
    [AgoraEduManager.shareManager.roomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
        
        [AgoraEduManager.shareManager.roomManager getLocalUserWithSuccess:^(EduLocalUser * _Nonnull user) {
            weakself.localUser = user;
            
            BOOL muteChat = !room.roomState.isStudentChatAllowed;
            if(!muteChat) {
                BOOL muteChat = !weakself.localUser.isChatAllowed;
                chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
                chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
            } else {
                chatTextFiled.contentTextFiled.enabled = muteChat ? NO : YES;
                chatTextFiled.contentTextFiled.placeholder = muteChat ? NSLocalizedString(@"ProhibitedPostText", nil) : NSLocalizedString(@"InputMessageText", nil);
            }

        } failure:^(NSError * error) {
            [BaseViewController showToast:error.localizedDescription];
        }];
        
    } failure:^(NSError * error) {
        [BaseViewController showToast:error.localizedDescription];
    }];
}

+ (void)showToast:(NSString *)title {
    
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UINavigationController *nvc = (UINavigationController*)window.rootViewController;
    if ([nvc isKindOfClass:UINavigationController.class]){
        UIViewController *vc = nvc.visibleViewController;
        if (vc != nil && title != nil && title.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc.view makeToast:title];
            });
        }
    } else {
        if (nvc != nil && title != nil && title.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [nvc.view makeToast:title];
            });
        }
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    [self setLoadingVisible:NO];
}


#pragma mark ConnectionState
- (void)classroom:(EduClassroom *)classroom connectionStateChanged:(ConnectionState)state {
    
    if(state == ConnectionStateAborted) {
        [AgoraEduManager releaseResource];
        [self dismissViewControllerAnimated:YES completion:^{
            [BaseViewController showToast:NSLocalizedString(@"LoginOnAnotherDeviceText", nil)];
        }];
        return;
    }
    
    if(state == ConnectionStateConnected) {
        if(self.hasSignalReconnect) {
            self.hasSignalReconnect = NO;
            [self onReconnected];
        }
    } else if(state == ConnectionStateReconnecting) {
        self.hasSignalReconnect = YES;
    }
}

#pragma mark onClassroomPropertyUpdated
- (void)classroom:(EduClassroom *)classroom stateUpdated:(EduClassroomChangeType)changeType operatorUser:(EduBaseUser *)user {

    if (changeType == EduClassroomChangeTypeAllStudentsChat) {
        [self onUpdateChatViews];
    } else if (changeType == EduClassroomChangeTypeCourseState) {
        [self onUpdateCourseState];
    }
}

- (void)classroomPropertyUpdated:(EduClassroom *)classroom cause:(EduObject *)cause {
     
    if(classroom.roomProperties == nil) {
        return;
    }
    
    // record
    if(classroom.roomProperties[ROOM_PROPERTY_KEY_RECORD] != nil) {
        RecordPropertyModel *model = [RecordPropertyModel yy_modelWithDictionary:classroom.roomProperties[ROOM_PROPERTY_KEY_RECORD]];
        
        // record over
        if(model.recordId == nil) {
            [self onEndRecord];
        }
    }
       
    [self onUnknownPropertyUpdated:classroom cause:cause];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard = YES;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.isChatTextFieldKeyboard =  NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *content = textField.text;
    if (content.length > 0) {
        WEAK(self);

        if (self.sceneType == EduSceneTypeBreakout) {
            // send big class room
            [AgoraEduManager.shareManager.groupRoomManager getClassroomInfoWithSuccess:^(EduClassroom * _Nonnull room) {
                
                TextMessageModel *model = [TextMessageModel new];
                model.content = content;
                model.fromRoomUuid = room.roomInfo.roomUuid;
                model.fromRoomName = room.roomInfo.roomName;
                model.role = EduRoleTypeStudent;
                [AgoraEduManager.shareManager.groupStudentService sendRoomChatMessageWithText:[model yy_modelToJSONString] success:^{
                    
                } failure:^(NSError * error) {
                    [BaseViewController showToast:error.localizedDescription];
                }];
                
                [AgoraEduManager.shareManager.studentService sendRoomChatMessageWithText:[model yy_modelToJSONString] success:^{
                    
                    EETextMessage *message = [EETextMessage new];
                    message.fromUser = weakself.localUser;
                    message.message = content;
                    message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
                    [weakself onSendMessage:message];

                } failure:^(NSError * error) {
                    [BaseViewController showToast:error.localizedDescription];
                }];
                
            } failure:^(NSError * error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
            
        } else {
            [AgoraEduManager.shareManager.studentService sendRoomChatMessageWithText:content success:^{
                
                EETextMessage *message = [EETextMessage new];
                message.fromUser = weakself.localUser;
                message.message = content;
                message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
                [weakself onSendMessage:message];

            } failure:^(NSError * error) {
                [BaseViewController showToast:error.localizedDescription];
            }];
        }
    }
    textField.text = nil;
    [textField resignFirstResponder];
    return NO;
}

#pragma mark WhiteManagerDelegate
- (void)onWhiteBoardStateChanged:(WhiteBoardStateModel * _Nonnull)state {
    
    BOOL follow = state.follow;
    if (self.boardState.follow != follow) {
        [self onBoardFollowMode:follow];
    }
    
    NSArray<NSString *> *grantUsers = state.grantUsers;
    if([grantUsers containsObject:self.localUser.userUuid] && ![self.boardState.grantUsers containsObject:self.localUser.userUuid]) {
        
        [self onBoardPermissionGranted:grantUsers];

    } else if(![grantUsers containsObject:self.localUser.userUuid] && [self.boardState.grantUsers containsObject:self.localUser.userUuid]) {
      [self onBoardPermissionRevoked:grantUsers];
        
    } else {
      [self onBoardPermissionUpdated:grantUsers];
    }
    self.boardState = state;
}

#pragma mark Subclass implementation
- (void)onSendMessage:(EETextMessage *)message {
}
- (void)onReconnected {
}

- (void)onUpdateChatViews {
}
- (void)onUpdateCourseState {
}

// white board
- (void)onBoardFollowMode:(BOOL)enable {
}
- (void)onBoardPermissionGranted:(NSArray<NSString *> *)grantUsers {
}
- (void)onBoardPermissionRevoked:(NSArray<NSString *> *)grantUsers {
}
- (void)onBoardPermissionUpdated:(NSArray<NSString *> *)grantUsers {
}

//record
- (void)onEndRecord {
}
- (void)onUnknownPropertyUpdated:(EduClassroom *)classroom cause:(EduObject *)cause {
}

@end
