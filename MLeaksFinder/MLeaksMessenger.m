/**
 * Tencent is pleased to support the open source community by making MLeaksFinder available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import "MLeaksMessenger.h"

@implementation MLeaksMessenger

+ (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    [self alertWithTitle:title message:message additionalButtonTitle:nil additionalButtonHandler:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
 additionalButtonTitle:(NSString *)additionalButtonTitle
additionalButtonHandler:(void(^)(void))additionalButtonHandler {
    UIWindow *window = [self getKeyWindow];
    if (!window) {
        return;
    }
    UIViewController *topVC = [self topViewControllerWithRootViewController:window.rootViewController];
    if (!topVC) {
        return;
    }
    UIAlertController *tempAlertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"dismiss" style:UIAlertActionStyleCancel handler:nil];
    [tempAlertVC addAction:cancelAction];
    if (additionalButtonTitle.length) {
        UIAlertAction *additionalAction = [UIAlertAction actionWithTitle:additionalButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !additionalButtonHandler ?: additionalButtonHandler();
        }];
        [tempAlertVC addAction:additionalAction];
    }
    [topVC presentViewController:tempAlertVC animated:NO completion:nil];
}

+ (UIWindow *)getKeyWindow {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        // 在 iOS 13 及更高版本使用
        NSSet *connectedScenes = [[UIApplication sharedApplication] connectedScenes];
        for (UIWindowScene *windowScene in connectedScenes) {
            if ([windowScene isKindOfClass:[UIWindowScene class]] && windowScene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
                if (keyWindow) {
                    break;
                }
            }
        }
    }
    if (keyWindow == nil) {
        // ios 13 以下或者没有实现SceneDelegate
        // 忽略警告
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        keyWindow = [UIApplication sharedApplication].keyWindow;
#pragma GCC diagnostic pop
    }
    return keyWindow;
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    UIViewController *topViewController = rootViewController;
    while (YES) {
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            topViewController = [(UITabBarController *)topViewController selectedViewController];
        } else if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

@end
