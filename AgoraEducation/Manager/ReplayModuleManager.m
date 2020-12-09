//
//  ReplayModuleManager.m
//  AgoraEducation
//
//  Created by SRS on 2020/5/3.
//  Copyright © 2020 yangmoumou. All rights reserved.
//

#import "ReplayModuleManager.h"
#import "UIView+Toast.h"
#import <AgoraReplayUI/AgoraReplayUI.h>
#import "HTTPManager.h"
#import "KeyCenter.h"

#define RECORD_BASE_URL @"https://agora-adc-artifacts.oss-accelerate.aliyuncs.com/"

@implementation ReplayModuleManager

+ (void)enterReplayViewControllerWithRoomId:(NSString *)roomId {
    
    RecordInfoConfiguration *config = [RecordInfoConfiguration new];
    config.appId = KeyCenter.agoraAppid;
    config.roomUuid = roomId;
    config.customerId = KeyCenter.customerId;
    config.customerCertificate = KeyCenter.customerCertificate;
    [HTTPManager getRecordInfoWithConfig:config success:^(RecordModel * _Nonnull recordModel) {
        
        if (recordModel.code != 0) {
            [UIApplication.sharedApplication.keyWindow makeToast:recordModel.msg];
            return;
        }
        
        if(recordModel.data.list.count == 0){
            [UIApplication.sharedApplication.keyWindow makeToast:NSLocalizedString(@"ReplayListFailedText", nil)];
            return;
        }
        
        NSArray *resultArray = [recordModel.data.list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                RecordInfoModel *model1 = (RecordInfoModel*)obj1;
                RecordInfoModel *model2 = (RecordInfoModel*)obj2;
                NSComparisonResult result = [@(model1.startTime) compare:@(model2.startTime)];
                return result == NSOrderedAscending;  // 降序
        }];
        
        RecordInfoModel *recordInfoModel = resultArray.firstObject;
        NSInteger status = recordInfoModel.status;
        if(status == RecordStateRecording
           || status == RecordStateFinished
           || status == RecordStateWaitDownload
           || status == RecordStateWaitConvert
           || status == RecordStateWaitUpload) {
            
            if(status != RecordStateFinished) {
                [UIApplication.sharedApplication.keyWindow makeToast:NSLocalizedString(@"QuaryReplayFailedText", nil)];
                return;
            }
        }
        
        /// ReplayConfiguration
        BoardConfiguration *boardConfig = [BoardConfiguration new];
        boardConfig.boardId = recordInfoModel.boardId;
        boardConfig.boardToken = recordInfoModel.boardToken;
        boardConfig.boardAppid = KeyCenter.boardAppid;
   
        VideoConfiguration *videoConfig = [VideoConfiguration new];
        videoConfig.urlString = [RECORD_BASE_URL stringByAppendingString: recordInfoModel.url];
        
        ReplayConfiguration *config = [ReplayConfiguration new];
        config.boardConfig = boardConfig;
        config.videoConfig = videoConfig;
        config.startTime = @(recordInfoModel.startTime).stringValue;
        config.endTime = @(recordInfoModel.endTime).stringValue;
        
        NSBundle *replayBundle = [NSBundle bundleForClass:ReplayViewController.class];
        ReplayViewController *vc = [[ReplayViewController alloc] initWithNibName:@"ReplayViewController" bundle:replayBundle];
        vc.config = config;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        UINavigationController *nvc = (UINavigationController*)window.rootViewController;
        if(nvc != nil){
            [nvc.visibleViewController presentViewController:vc animated:YES completion:nil];
        }
        
    } failure:^(NSError * _Nonnull error, NSInteger statusCode) {
        [UIApplication.sharedApplication.keyWindow makeToast:error.localizedDescription];
    }];
}

@end
