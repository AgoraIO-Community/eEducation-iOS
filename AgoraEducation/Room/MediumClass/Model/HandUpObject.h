//
//  HandUpObject.h
//  AgoraEducation
//
//  Created by SRS on 2020/11/30.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AgoraActionProcess;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HandUpCommonState) {
    HandUpCommonStateOff          = 0,
    HandUpCommonStateOn           = 1,
};

@interface HandUpStates : NSObject
// open/close handUp
@property (nonatomic, assign) HandUpCommonState state;
// whether auto publish;
// autoCoVideo = YES:auto publish
// autoCoVideo = NO:will be publish after agreed
@property (nonatomic, assign) HandUpCommonState autoCoVideo;
@end

@interface HandsUpProperty : NSObject
@property (nonatomic, assign) AgoraActionTypeOC type;

// Maximum waiting number
// 最大等待人数
@property (nonatomic, assign) NSInteger maxWait;

// Unresponsive timeout
// 未响应超时时间
@property (nonatomic, assign) NSInteger timeout;
@end

NS_ASSUME_NONNULL_END
