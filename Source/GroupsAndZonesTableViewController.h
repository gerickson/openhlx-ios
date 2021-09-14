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
 *    This file defines a view controller for observing and mutating a
 *    HLX group or zone, limited to their name, source (input), and
 *    volume (including level and mute state) properties.
 *
 */

#ifndef GROUPSANDZONESTABLEVIEWCONTROLLER_H
#define GROUPSANDZONESTABLEVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ApplicationControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class ApplicationControllerDelegate;

/**
 *  Enumeration for indicating whether to render the table view as
 *  groups or zones.
 *
 */
enum
{
    kShowStyleGroups = 0, //!< Render the table as groups
    kShowStyleZones       //!< Render the table as zones
};

/**
 *  A type for indicating whether to render the table view as
 *  groups or zones.
 *
 */
typedef NSInteger ShowStyle NS_TYPED_ENUM;

@interface GroupsAndZonesTableViewController : UITableViewController <ApplicationControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer             mApplicationController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;

    /**
     *  An indicator for whether to render the table view as groups or
     *  zones.
     *
     */
    ShowStyle                                     mShowStyle;
}

// MARK: Properties

/**
 *  A pointer to a segmented control indicating whether to render the
 *  table view as groups or zones.
 *
 */
@property (weak, nonatomic) IBOutlet UISegmentedControl * mGroupZoneSegmentedControl;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onGroupZoneSegmentedControlAction: (id)aSender;

// MARK: Setters

- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController; 

@end

#endif // GROUPSANDZONESTABLEVIEWCONTROLLER_H
