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
 *    UIViewController for handling and presenting HLX client
 *    controller disconnect alerts in a consistent and common way.
 *
 */

#ifndef UIVIEWCONTROLLER_EXTENDED_BY_HLXCLIENTDIDDISCONNECTDELEGATEDEFAULTIMPLEMENTATIONS_H
#define UIVIEWCONTROLLER_EXTENDED_BY_HLXCLIENTDIDDISCONNECTDELEGATEDEFAULTIMPLEMENTATIONS_H

#import <Foundation/NSString.h>
#import <Foundation/NSURL.h>

#import <UIKit/UIAlertController.h>
#import <UIKit/UIViewController.h>

#include <OpenHLX/Common/Errors.hpp>


@interface UIViewController (HLXClientDidDisconnectDelegateDefaultImplementations)

// MARK: Class Methods

+ (void) viewPresentDidDisconnectAlert: (UIViewController * _Nonnull)aViewController withURL: (NSURL * _Nonnull)aURLRef andError: (const HLX::Common::Error &)aError andHandler: (void (^ _Nullable)(UIAlertAction * _Nonnull aAction))aHandler;
+ (void) viewPresentDidDisconnectAlert: (UIViewController *_Nonnull)aViewController withURL: (NSURL *_Nonnull)aURLRef andError: (const HLX::Common::Error &)aError andNamedSegue: (NSString *_Nonnull)aNamedSegue;

// MARK: Instance Methods

- (void) presentDidDisconnectAlert: (NSURL * _Nonnull)aURLRef withError: (const HLX::Common::Error &)aError andHandler: (void (^ _Nullable)(UIAlertAction * _Nonnull aAction))aHandler;
- (void) presentDidDisconnectAlert: (NSURL * _Nonnull)aURLRef withError: (const HLX::Common::Error &)aError andNamedSegue: (NSString * _Nonnull)aNamedSegue;

@end

#endif // UIVIEWCONTROLLER_EXTENDED_BY_HLXCLIENTDIDDISCONNECTDELEGATEDEFAULTIMPLEMENTATIONS_H
