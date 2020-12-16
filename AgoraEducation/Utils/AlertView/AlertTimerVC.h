//
//  AlertTimerVC.h
//  AgoraEducation
//
//  Created by SRS on 2020/12/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertTimerVC : UIAlertController
- (void)startCountDown:(NSInteger)maxCount;
@end

NS_ASSUME_NONNULL_END
