//
//  AlertViewUtil.m
//  AgoraEducation
//
//  Created by yangmoumou on 2019/11/20.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AlertViewUtil.h"
#import "AlertTimerVC.h"

@implementation AlertViewUtil
+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title cancelHandler:(KAlertHandler)cancelHandler sureHandler:(KAlertHandler)sureHandler {
    
    return [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:NSLocalizedString(@"OKText", nil) cancelHandler:cancelHandler sureHandler:sureHandler];
}

+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title timerCount:(NSInteger)timerCount cancelHandler:(KAlertHandler)cancelHandler sureHandler:(KAlertHandler)sureHandler {
    
    return [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:NSLocalizedString(@"OKText", nil) timerCount:timerCount cancelHandler:cancelHandler sureHandler:sureHandler];
}

+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title sureHandler:(KAlertHandler)sureHandler {
    
    return [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:NSLocalizedString(@"OKText", nil) cancelHandler:nil sureHandler:sureHandler];
}

+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title {
    
    return [AlertViewUtil showAlertWithController:viewController title:title message:nil cancelText:NSLocalizedString(@"CancelText", nil) sureText:nil cancelHandler:nil sureHandler:nil];
}

+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString * _Nullable)message cancelText:(NSString * _Nullable)cancelText sureText:(NSString * _Nullable)sureText cancelHandler:(KAlertHandler _Nullable)cancelHandler sureHandler:(KAlertHandler _Nullable)sureHandler {
    return [AlertViewUtil showAlertWithController:viewController title:title message:message cancelText:cancelText sureText:sureText timerCount:0 cancelHandler:cancelHandler sureHandler:sureHandler];
}
+ (UIAlertController *)showAlertWithController:(UIViewController *)viewController title:(NSString *)title message:(NSString * _Nullable)message cancelText:(NSString * _Nullable)cancelText sureText:(NSString * _Nullable)sureText timerCount:(NSInteger)timerCount cancelHandler:(KAlertHandler _Nullable)cancelHandler sureHandler:(KAlertHandler _Nullable)sureHandler {
    
    UIAlertController *alertVc;
    if (timerCount <= 0) {
        alertVc = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alertVc = [AlertTimerVC alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    }
    
    if (sureText != nil && sureText.length > 0) {
        UIAlertAction *actionDone = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !sureHandler ? : sureHandler(action);
        }];
        [alertVc addAction:actionDone];
    }
    
    if (cancelText != nil && cancelText.length > 0) {
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            !cancelHandler ? : cancelHandler(action);
        }];
        [alertVc addAction:actionCancel];
    }
    
    if (timerCount > 0) {
        [(AlertTimerVC *)alertVc startCountDown:timerCount];
    }
    
    [viewController presentViewController:alertVc animated:YES completion:nil];
    
    return alertVc;
}

@end
