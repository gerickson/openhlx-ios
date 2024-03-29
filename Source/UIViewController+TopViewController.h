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
 *    This file declares extension class and instance methods to
 *    UIViewController inspired by https://stackoverflow.com/
 *    questions/6131205/how-to-find-topmost-view-controller-on-ios
 *    which calculate and return the top-most view controller.
 *
 */

#ifndef UIVIEWCONTROLLER_EXTENDED_BY_TOPVIEWCONTROLLER_H
#define UIVIEWCONTROLLER_EXTENDED_BY_TOPVIEWCONTROLLER_H

#import <UIKit/UIViewController.h>

@interface UIViewController (TopViewController)

// MARK: Class Methods

+ (UIViewController *) topViewControllerFromRootViewController: (UIViewController *)aRootViewController;
+ (UIViewController *) topViewController;

// MARK: Instance Methods

- (UIViewController *) topViewController;

@end

#endif // UIVIEWCONTROLLER_EXTENDED_BY_TOPVIEWCONTROLLER_H
