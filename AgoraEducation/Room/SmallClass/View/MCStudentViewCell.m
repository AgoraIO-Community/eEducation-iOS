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
    
    [self.muteAudioButton addTarget:self action:@selector(muteAudio:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.muteVideoButton addTarget:self action:@selector(muteVideo:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)muteAudio:(UIButton *)sender {
    
    if (self.stream.streamState == 1 && [self.stream.userUuid isEqualToString:self.userUuid]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
            [self.delegate muteAudioStream:sender.selected];
        }
        
        sender.selected = !sender.selected;
    }
}

- (void)muteVideo:(UIButton *)sender {
    
    if (self.stream.streamState == 1 && [self.stream.userUuid isEqualToString:self.userUuid]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
            [self.delegate muteVideoStream:sender.selected];
        }
        
        sender.selected = !sender.selected;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
    
    NSString *offVideoImageName;
    NSString *onVideoImageName;
    // self covideo
    if (stream.streamState == 1 && [stream.userUuid isEqualToString:self.userUuid]) {
        onVideoImageName = @"icon-video-blue";
        offVideoImageName = @"icon-videooff-blue";
    } else {
        onVideoImageName = @"roomCameraOn";
        offVideoImageName = @"roomCameraOff";
    }
    
    [self.muteVideoButton setImage:[UIImage imageNamed:offVideoImageName] forState:(UIControlStateNormal)];
    [self.muteVideoButton setImage:[UIImage imageNamed:onVideoImageName] forState:(UIControlStateSelected)];
    self.muteVideoButton.selected = stream.hasVideo ? YES : NO;
    
    NSString *onAudioImageName;
    NSString *offAudioImageName;
    // self covideo
    if (stream.streamState == 1 && [stream.userUuid isEqualToString:self.userUuid]) {
        
        onAudioImageName = @"icon-speaker-blue";
        offAudioImageName = @"icon-speakeroff-blue";
        
    } else {
        onAudioImageName = @"icon-speaker";
        offAudioImageName = @"icon-speaker-off";
    }
    
    [self.muteAudioButton setImage:[UIImage imageNamed:offAudioImageName] forState:(UIControlStateNormal)];
    [self.muteAudioButton setImage:[UIImage imageNamed:onAudioImageName] forState:(UIControlStateSelected)];
    self.muteAudioButton.selected = stream.hasAudio ? YES : NO;
}

@end
