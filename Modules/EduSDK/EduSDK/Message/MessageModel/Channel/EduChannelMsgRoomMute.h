//
//  EduChannelMsgRoomMute.h
//  EduSDK
//
//  Created by SRS on 2020/7/23.
//  Copyright © 2020 agora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoomModel.h"
#import "EduUser.h"
#import "SyncRoomSessionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EduChannelMsgRoomMute : NSObject
@property (nonatomic, strong) RoomMuteStateModel *muteChat;
@property (nonatomic, strong) RoomMuteStateModel *muteVideo;
@property (nonatomic, strong) RoomMuteStateModel *muteAudio;
@property (nonatomic, strong) BaseSnapshotUserModel *opr;
@end

NS_ASSUME_NONNULL_END
