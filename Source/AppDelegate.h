/*
 *    Copyright (c) 2019-2021 Grant Erickson
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
 *    This file defines an app-global getter method and instance
 *    data member.
 *
 */

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>

#import "ApplicationControllerPointer.hpp"


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MutableApplicationControllerPointer  mApplicationController;
}

// MARK: Properties

@property (strong, nonatomic) UIWindow *window;

// MARK: Instance Methods

// MARK: Getters

- (MutableApplicationControllerPointer) hlxClientController;

@end
