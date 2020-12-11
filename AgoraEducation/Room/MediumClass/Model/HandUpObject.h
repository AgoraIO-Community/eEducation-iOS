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

NS_ASSUME_NONNULL_END
