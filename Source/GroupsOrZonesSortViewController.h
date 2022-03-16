/*
 *    Copyright (c) 2022 Grant Erickson
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
 *    This file defines...
 *
 */

#ifndef GROUPSORZONESSORTVIEWCONTROLLER_H
#define GROUPSORZONESSORTVIEWCONTROLLER_H

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ClientController.hpp"
#import "SortCriteriaController.h"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class ApplicationControllerDelegate;

@interface GroupsOrZonesSortViewController : UITableViewController <ApplicationControllerDelegate>
{
}

// MARK: Properties

@property (weak, nonatomic) IBOutlet UIBarButtonItem * mAddCriteriaButtonItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem * mEditButtonItem;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onEditButtonItemAction: (id)aSender;

// MARK: Setters

- (void) setClientController: (ClientController &)aClientController; 
- (void) setSortCriteriaController: (SortCriteriaController *)aSortCriteriaController;

@end

#endif // GROUPSORZONESSORTVIEWCONTROLLER_H
