//
//  MediumViewController.h
//  AgoraEducation
//
//  Created by SRS on 2020/11/17.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "GroupObject.h"
#import "HandUpObject.h"
@import AgoraActionProcess;
@import AgoraHandsUp;

NS_ASSUME_NONNULL_BEGIN

@interface MediumViewController : BaseViewController

// handsup
@property (weak, nonatomic) IBOutlet UIView *handsUpBgView;
@property (strong, nonatomic) AgoraHandsUpManagerOC *handsUpManager;
@property (strong, nonatomic) NSString *processUuid;
@property (strong, nonatomic) HandUpStates *handUpStates;
// action
@property (strong, nonatomic) AgoraActionProcessManagerOC *processManager;

@end

NS_ASSUME_NONNULL_END

