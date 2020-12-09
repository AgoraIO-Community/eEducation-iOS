//
//  MCStudentListView.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/15.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "MCStudentListView.h"
#import "MCStudentViewCell.h"

@interface MCStudentListView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) UITableView *studentTableView;
@property (nonatomic, strong) NSArray<EduStream*> *studentArray;
@property (nonatomic, strong) NSArray<NSString*> *grantUserArray;

@end

@implementation MCStudentListView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITableView *studentTableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    studentTableView.delegate = self;
    studentTableView.dataSource =self;
    [self addSubview:studentTableView];
    self.studentTableView = studentTableView;
    studentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.studentArray = [NSMutableArray array];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.studentTableView.frame = self.bounds;
}

- (void)updateStudentArray:(NSArray<EduStream*> *)array {
    self.studentArray = [NSArray arrayWithArray:array];
    [self.studentTableView reloadData];
}

- (void)updateGrantStudentArray:(NSArray<NSString*> *)grantUsers {
    self.grantUserArray = [NSArray arrayWithArray:grantUsers];
    [self.studentTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.studentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCStudentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MCStudentViewCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.muteAudioButton addTarget:self action:@selector(muteAudio:) forControlEvents:(UIControlEventTouchUpInside)];
        [cell.muteVideoButton addTarget:self action:@selector(muteVideo:) forControlEvents:(UIControlEventTouchUpInside)];
    }

    EduStream *model = self.studentArray[indexPath.row];
    MCStreamInfo *infoModel = [[MCStreamInfo alloc] initWithUserUuid:model.userInfo.userUuid userName:model.userInfo.userName hasAudio:model.hasAudio hasVideo:model.hasVideo streamState:1 userState:1];

    cell.userUuid = self.userUuid;
    cell.stream = infoModel;
    [cell updateEnableButtons:infoModel.userUuid];
    cell.muteWhiteButton.selected = NO;
    if(self.grantUserArray != nil && [self.grantUserArray containsObject:infoModel.userUuid]) {
        cell.muteWhiteButton.selected = YES;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)muteAudio:(UIButton *)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(muteAudioStream:)]) {
        [self.delegate muteAudioStream:sender.selected];
    }
    sender.selected = !sender.selected;
    
    NSString *imageName = sender.selected ? @"icon-speaker":@"icon-speaker-off";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)muteVideo:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(muteVideoStream:)]) {
        [self.delegate muteVideoStream:sender.selected];
    }
    sender.selected = !sender.selected;
    NSString *imageName = sender.selected ? @"roomCameraOn":@"roomCameraOff";
    [sender setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
}

- (void)setUserUuid:(NSString *)userUuid {
    _userUuid = userUuid;
    [self.studentTableView reloadData];
}

@end
