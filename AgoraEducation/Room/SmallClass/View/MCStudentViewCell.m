//
//  MCStudentViewCell.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentViewCell.h"

@interface MCStudentViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *micButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftCon;

@end

@implementation MCStudentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization cod
    self.muteVideoButton.selected = YES;
    self.muteAudioButton.selected = YES;
    self.muteWhiteButton.selected = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)muteAction:(UIButton *)sender {
}

- (void)updateEnableButtons:(NSString *)userUuid {
    self.muteVideoButton.enabled = NO;
    self.muteAudioButton.enabled = NO;
    self.muteWhiteButton.enabled = NO;
    if ([userUuid isEqualToString:self.userUuid]) {
        self.muteVideoButton.enabled = YES;
        self.muteAudioButton.enabled = YES;
        self.muteWhiteButton.enabled = YES;
    }
}

- (void)setStream:(MCStreamInfo *)stream {
    _stream = stream;
    
    self.nameLeftCon.constant = 10;

    NSString *string = stream.userName;
    if (stream.userState == 0) {
        string = [string stringByAppendingString:NSLocalizedString(@"OffLineText", nil)];
        [self.nameLabel setText:string];
        self.nameLeftCon.constant = -20;
    } else {
        [self.nameLabel setText:string];
    }
    
    NSString *videoImageName;
    // offline
//    if (stream.userState == 0) {
//        videoImageName = stream.hasVideo ? @"roomCameraOn" : @"roomCameraOff";
//    } else {
        videoImageName = stream.hasVideo ? @"icon-video-blue" : @"icon-videooff-blue";
//    }
    [self.muteVideoButton setImage:[UIImage imageNamed:videoImageName] forState:(UIControlStateNormal)];
    self.muteVideoButton.selected = stream.hasVideo ? YES : NO;
    
    NSString *audioImageName;
    // offline
//    if (stream.userState == 0) {
//        audioImageName = stream.hasAudio ? @"icon-speaker" : @"icon-speaker-off";
//    } else {
        audioImageName = stream.hasAudio ? @"icon-speaker-blue" : @"icon-speakeroff-blue";
//    }
    
    [self.muteAudioButton setImage:[UIImage imageNamed:audioImageName] forState:(UIControlStateNormal)];
    self.muteAudioButton.selected = stream.hasAudio ? YES : NO;
}

@end
