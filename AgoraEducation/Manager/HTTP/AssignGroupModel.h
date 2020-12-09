//
//  AssignGroupModel.h
//  AgoraEducation
//
//  Created by SRS on 2020/9/9.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssignGroupDataModel : NSObject
@property (nonatomic, strong) NSString *roomUuid;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, assign) NSInteger memberLimit;
@end

@interface AssignGroupModel : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) AssignGroupDataModel *data;
@end

NS_ASSUME_NONNULL_END
