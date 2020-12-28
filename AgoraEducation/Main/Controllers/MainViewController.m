//
//  MainViewController.m
//  AgoraSmallClass
//
//  Created by yangmoumou on 2019/5/9.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "EEClassRoomTypeView.h"
#import "SettingViewController.h"
#import "EyeCareModeUtil.h"
#import "NSString+MD5.h"
#import "UIView+Toast.h"

#import "OneToOneViewController.h"
#import "SmallViewController.h"
#import "BigViewController.h"

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

@interface MainViewController ()<EEClassRoomTypeDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UITextField *classNameTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFiled;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomCon;
@property (weak, nonatomic) IBOutlet UIButton *roomType;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (nonatomic, weak) EEClassRoomTypeView *classRoomTypeView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *userUuid;
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, assign) EduSceneType sceneType;
@end

@implementation MainViewController

#pragma mark LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self addTouchedRecognizer];
    [self addNotification];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([[EyeCareModeUtil sharedUtil] queryEyeCareModeStatus]) {
        [[EyeCareModeUtil sharedUtil] switchEyeCareMode:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Private Function
- (void)setupView {
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.frame= CGRectMake((kScreenWidth -100)/2, (kScreenHeight - 100)/2, 100, 100);
    self.activityIndicator.color = [UIColor grayColor];
    self.activityIndicator.backgroundColor = [UIColor whiteColor];
    self.activityIndicator.hidesWhenStopped = YES;
    
    EEClassRoomTypeView *classRoomTypeView = [EEClassRoomTypeView initWithXib:CGRectMake(30, kScreenHeight - 300, kScreenWidth - 60, 190)];
    [self.view addSubview:classRoomTypeView];
    self.classRoomTypeView = classRoomTypeView;
    classRoomTypeView.hidden = YES;
    classRoomTypeView.delegate = self;
    
    self.classNameTextFiled.delegate = self;
    self.userNameTextFiled.delegate = self;
    
    self.classNameTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
    self.userNameTextFiled.keyboardType = UIKeyboardTypeASCIICapable;
}

- (void)addTouchedRecognizer {
    UITapGestureRecognizer *touchedControl = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedBegan:)];
    [self.baseView addGestureRecognizer:touchedControl];
}
- (void)touchedBegan:(UIGestureRecognizer *)recognizer {
    [self.classNameTextFiled resignFirstResponder];
    [self.userNameTextFiled resignFirstResponder];
    self.classRoomTypeView.hidden  = YES;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float bottom = frame.size.height;
    self.textViewBottomCon.constant = bottom;
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    self.textViewBottomCon.constant = 261;
}

- (BOOL)checkFieldTextLen:(NSString *)text {
    int strlength = 0;
    char *p = (char *)[text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    if(strlength <= 20){
        return YES;
    } else {
       return NO;
    }
}

- (BOOL)checkFieldTextFormat:(NSString *)text {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [text isEqualToString:filtered];
}

#pragma mark Click Event
- (IBAction)popupRoomType:(UIButton *)sender {
    self.classRoomTypeView.hidden = NO;
}

- (IBAction)joinRoom:(UIButton *)sender {

    NSString *userName = self.userNameTextFiled.text;
    NSString *roomName = self.classNameTextFiled.text;
    
    if (userName.length == 0
        || roomName.length == 0
        || ![self checkFieldTextLen:userName]
        || ![self checkFieldTextLen:roomName]) {
        
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"UserNameVerifyText", nil)];
        return;
    }
    
    if (![self checkFieldTextFormat:userName]
        || ![self checkFieldTextFormat:roomName]) {
        
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"UserNameFormatVerifyText", nil)];
        return;
    }
    
    if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"OneToOneText", nil)]) {
        self.sceneType = EduSceneType1V1;
    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"SmallClassText", nil)]) {
        self.sceneType = EduSceneTypeSmall;
    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"BigClassText", nil)]) {
        self.sceneType = EduSceneTypeBig;
    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"BreakOutClassText", nil)]) {
        self.sceneType = EduSceneTypeBreakout;
    } else if ([self.roomType.titleLabel.text isEqualToString:NSLocalizedString(@"MediumClassText", nil)]) {
        self.sceneType = EduSceneTypeMedium;
    } else {
        [AlertViewUtil showAlertWithController:self title:NSLocalizedString(@"RoomTypeVerifyText", nil)];
        return;
    }
    
    // userName + role
    self.userUuid = [NSString stringWithFormat:@"%@%ld", userName, (long)EduRoleTypeStudent];
    // userName + roomtype
    self.roomUuid = [NSString stringWithFormat:@"%@%ld", roomName, (long)self.sceneType];

    SchduleClassConfig *config = [SchduleClassConfig new];
    config.roomName = roomName;
    config.roomUuid = self.roomUuid;
    config.sceneType = self.sceneType;
    
    WEAK(self);
    [self setLoadingVisible:YES];
    
    [AgoraEduManager.shareManager initWithUserUuid:self.userUuid userName:userName tag:self.sceneType success:^{
            
        [AgoraEduManager.shareManager schduleClassroomWithConfig:config success:^{
            
            [AgoraEduManager.shareManager joinClassroomWithSceneType:self.sceneType userName:self.userNameTextFiled.text success:^{

                [weakself setLoadingVisible:NO];
                
                if(weakself.sceneType == EduSceneType1V1) {
                    if(IsPad){
                        [weakself joinRoomWithIdentifier:@"oneToOneRoom-iPad"];
                    } else {
                        [weakself joinRoomWithIdentifier:@"oneToOneRoom"];
                    }
                } else if(weakself.sceneType == EduSceneTypeSmall) {
                    if(IsPad){
                        [weakself joinRoomWithIdentifier:@"smallRoom-iPad"];
                    } else {
                        [weakself joinRoomWithIdentifier:@"smallRoom"];
                    }
                } else if(weakself.sceneType == EduSceneTypeBig) {
                    if(IsPad){
                        [weakself joinRoomWithIdentifier:@"bigRoom-iPad"];
                    } else {
                        [weakself joinRoomWithIdentifier:@"bigRoom"];
                    }
                } else if(weakself.sceneType == EduSceneTypeBreakout) {
                    if(IsPad){
                       [weakself joinRoomWithIdentifier:@"boRoom-iPad"];
                    } else {
                       [weakself joinRoomWithIdentifier:@"boRoom"];
                    }
                } else if(weakself.sceneType == EduSceneTypeMedium) {
                    [weakself joinRoomWithIdentifier:@"groupRoom"];
                }
                
            } failure:^(NSString * _Nonnull errorMsg) {
                [weakself setLoadingVisible:NO];
                [weakself.view makeToast:errorMsg];
            }];

        } failure:^(NSString * _Nonnull errorMsg) {
            [weakself setLoadingVisible:NO];
            [weakself.view makeToast:errorMsg];
        }];
        
    } failure:^(NSString * _Nonnull errorMsg) {
        [weakself setLoadingVisible:NO];
        [weakself.view makeToast:errorMsg];
    }];
}

- (void)setLoadingVisible:(BOOL)show {
    if(show) {
        [self.activityIndicator startAnimating];
        [self.joinButton setEnabled:NO];
    } else {
        [self.activityIndicator stopAnimating];
        [self.joinButton setEnabled:YES];
    }
}

- (IBAction)settingAction:(UIButton *)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)joinRoomWithIdentifier:(NSString*)identifier {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Room" bundle:[NSBundle mainBundle]];
    BaseViewController *vc = [story instantiateViewControllerWithIdentifier:identifier];
    vc.sceneType = self.sceneType;
    vc.className = self.classNameTextFiled.text;
    vc.roomUuid = self.roomUuid;
    vc.userUuid = self.userUuid;
    vc.userName = self.userNameTextFiled.text;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark EEClassRoomTypeDelegate
- (void)selectRoomTypeName:(NSString *)name {
    [self.roomType setTitleColor:[UIColor colorWithHex:0x333333]  forState:(UIControlStateNormal)];
    [self.roomType setTitle:name forState:(UIControlStateNormal)];
    self.classRoomTypeView.hidden = YES;
}

@end
