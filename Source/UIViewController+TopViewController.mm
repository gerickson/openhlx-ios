/*
 *    Copyright (c) 2020-2021 Grant Erickson
 *    All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing,
 *    software distributed under the License is distributed on an "AS
 *    IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 *    express or implied.  See the License for the specific language
 *    governing permissions and limitations under the License.
 *
 */

/**
 *  @file
 *    This file implements extension class and instance methods to
 *    UIViewController inspired by https://stackoverflow.com/
 *    questions/6131205/how-to-find-topmost-view-controller-on-ios
 *    which calculate and return the top-most view controller.
 *
 */

#import "UIViewController+TopViewController.h"

#import <Foundation/NSArray.h>

#import <UIKit/UIApplication.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UITabBarController.h>
#import <UIKit/UIWindow.h>


@implementation UIViewController (TopViewController)

// MARK: Class Methods

/**
 *  @brief
 *    Return the top-most view controller from the specified root view
 *    controller.
 *
 *  @param[in]  aRootViewController  A pointer to the root view controller
 *                                   from which to find or derive the
 *                                   top-most view controller.
 *
 *  @returns
 *    A pointer to the top-most view controller which may, in fact, be
 *    @a aRootViewController.
 *
 */
+ (UIViewController *) topViewControllerFromRootViewController: (UIViewController *)aRootViewController
{
    UIViewController *lRetval = aRootViewController;
    
    while (true)
    {
        if (lRetval.presentedViewController && !lRetval.presentedViewController.isBeingDismissed)
        {
            lRetval = lRetval.presentedViewController;
        }
        else if ([lRetval isKindOfClass: [UINavigationController class]])
        {
            UINavigationController *lNavigationController = static_cast<UINavigationController *>(lRetval);
            
            lRetval = lNavigationController.topViewController;
        }
        else if ([lRetval isKindOfClass: [UITabBarController class]])
        {
            UITabBarController *lTabBarController = static_cast<UITabBarController *>(lRetval);
            
            lRetval = lTabBarController.selectedViewController;
        }
        else if (lRetval.childViewControllers.count > 0)
        {
            lRetval = [lRetval.childViewControllers lastObject];
        }
        else
        {
            break;
        }
    }
    
    return (lRetval);
}

/**
 *  @brief
 *    Return the top-most view controller from the shared application
 *    instance key window root view controller.
 *
 *  @returns
 *    A pointer to the top-most view controller which may, in fact, be
 *    the shared application instance key window root view controller.
 *
 */
+ (UIViewController *) topViewController
{
    UIViewController *lRootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;

    return ([UIViewController topViewControllerFromRootViewController: lRootViewController]);
}

// MARK: Instance Methods

/**
 *  @brief
 *    Return the top-most view controller from the current window view
 *    root view controller.
 *
 *  @returns
 *    A pointer to the top-most view controller which may, in fact, be
 *    the current window view root view controller.
 *
 */
- (UIViewController *) topViewController
{
    UIViewController *lRootViewController = self.view.window.rootViewController;

    return ([UIViewController topViewControllerFromRootViewController: lRootViewController]);
}

@end
