//
//  AlertTimerVC.m
//  AgoraEducation
//
//  Created by SRS on 2020/12/16.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "AlertTimerVC.h"

@interface AlertTimerVC ()

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger currentCount;

@end

@implementation AlertTimerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    if (self.timer != nil && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startCountDown:(NSInteger)maxCount {
    
    if (self.timer != nil && [self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }

    self.currentCount = maxCount;
    
    WEAK(self);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    
        UIAlertAction *action = weakself.actions.firstObject;
        NSString *replaceString = [NSString stringWithFormat:@"(%ld)", (long)weakself.currentCount];
        NSString *sourceString = [action.title stringByReplacingOccurrencesOfString:replaceString withString:@""];
        weakself.currentCount -= 1;
        if (weakself.currentCount <= 0) {
//            weakself.view.hidden = YES;
            [weakself dismissViewControllerAnimated:YES completion:^{

            }];
            if (weakself.timer != nil && [weakself.timer isValid]) {
                [weakself.timer invalidate];
                weakself.timer = nil;
            }
            return;
        } else {
            NSString *title = [NSString stringWithFormat:@"%@(%ld)", sourceString, (long)weakself.currentCount];
            [action setValue:title forKey:@"title"];
        }
    }];
    
    UIAlertAction *action = self.actions.firstObject;
    NSString *title = [NSString stringWithFormat:@"%@(%ld)", action.title, (long)self.currentCount];
    [action setValue:title forKey:@"title"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
