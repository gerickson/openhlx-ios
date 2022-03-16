/*
 *    Copyright (c) 2019-2022 Grant Erickson
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
 *    This file implements a view controller for observing and mutating a
 *    HLX group or zone, limited to their name, source (input), and
 *    volume (including level and mute state) properties.
 *
 */

#import "GroupsAndZonesTableViewController.h"

#import <algorithm>
#import <array>
#import <vector>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/VolumeModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "GroupsAndZonesTableViewCell.h"
#import "GroupDetailViewController.h"
#import "SortCriteriaController.h"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"
#import "ZoneDetailViewController.h"


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace HLX
{

namespace Client
{

class Controller;

};

};

typedef std::vector<IdentifierModel::IdentifierType> ObjectIdentifiers;

@interface GroupsAndZonesTableViewController ()
{
    SortCriteriaController * mGroupSortCriteriaController;
    SortCriteriaController * mZoneSortCriteriaController;
}

@end

@implementation GroupsAndZonesTableViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status  lStatus;


    [super viewWillAppear: aAnimated];

    mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

    lStatus = mClientController->GetApplicationController()->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    [self.tableView reloadData];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a group or zone list view controller
 *    from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone list view controller,
 *    if successful; otherwise, null.
 *
 */
- (id) initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [self initCommon];
    }

    return (self);
}

/**
 *  @brief
 *    Creates and initializes a group or zone list view controller
 *    with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone list view controller,
 *    if successful; otherwise, null.
 *
 */
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle
{
    if (self = [super initWithNibName: aNibName
                               bundle: aNibBundle])
    {
        [self initCommon];
    }

    return (self);
}

/**
 *  @brief
 *    This performs common initialization.
 *
 */
- (void) initCommon
{
    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

    mGroupSortCriteriaController = [[SortCriteriaController alloc] initAsGroup: true];
    nlREQUIRE(mGroupSortCriteriaController != nullptr, done);

    mZoneSortCriteriaController = [[SortCriteriaController alloc] initAsGroup: false];
    nlREQUIRE(mZoneSortCriteriaController != nullptr, done);

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    Status  lStatus;

    if ([aSender isKindOfClass: [GroupsAndZonesTableViewCell class]])
    {
        GroupsAndZonesTableViewCell *  lGroupsAndZonesCell = aSender;
        const bool                     lIsGroup = [lGroupsAndZonesCell isGroup];

        if (lIsGroup)
        {
            GroupDetailViewController *  lGroupDetailViewController = [aSegue destinationViewController];

            [lGroupDetailViewController setClientController: *mClientController
                                                   forGroup: [lGroupsAndZonesCell group]];
        }
        else
        {
            ZoneDetailViewController *   lZoneDetailViewController = [aSegue destinationViewController];

            [lZoneDetailViewController setClientController: *mClientController
                                                   forZone: [lGroupsAndZonesCell zone]];
        }

        lStatus = mClientController->GetApplicationController()->SetDelegate(nullptr);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else if (aSender == self.mSortButtonItem)
    {
        lStatus = mClientController->GetApplicationController()->SetDelegate(nullptr);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the group or zone segmented
 *    control.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onGroupZoneSegmentedControlAction: (id)aSender
{
    if (aSender == self.mGroupZoneSegmentedControl)
    {
        mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

        [self.tableView reloadData];
    }

    return;
}

- (IBAction) onFilterButtonAction: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
}

- (IBAction) onSortButtonAction: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
}

// MARK: Setters

/**
 *  @brief
 *    Set the client controller for the view.
 *
 *  @param[in]  aClientController  A reference to an app client
 *                                 controller instance to use for
 *                                 this view controller.
 *
 */
- (void) setClientController: (ClientController &)aClientController
{
    [mGroupSortCriteriaController setClientController: aClientController];
    [mZoneSortCriteriaController  setClientController: aClientController];

    mClientController = &aClientController;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    static const NSInteger kNumberOfSections = 1;

    return (kNumberOfSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    IdentifierModel::IdentifierType  lValue = 0;
    NSInteger                        lRetval = 0;
    Status                           lStatus;


    nlREQUIRE(aSection == 0, done);

    if (mShowStyle == kShowStyleGroups)
    {
        lStatus = mClientController->GetApplicationController()->GroupsGetMax(lValue);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else if (mShowStyle == kShowStyleZones)
    {
        lStatus = mClientController->GetApplicationController()->ZonesGetMax(lValue);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

    lRetval = lValue;

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const bool                     lAsGroup = (mShowStyle == kShowStyleGroups);
    GroupsAndZonesTableViewCell *  lRetval = nullptr;
    NSString *                     lCellIdentifier = nullptr;

    if (lAsGroup)
    {
        lCellIdentifier = @"Group Table View Cell";
    }
    else
    {
        lCellIdentifier = @"Zone Table View Cell";

    }

    lRetval = [aTableView dequeueReusableCellWithIdentifier: lCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableCell: lRetval
                   forIndexPath: aIndexPath];

 done:
    return (lRetval);
}

// MARK: Workers

- (IdentifierModel::IdentifierType) mapRowToIdentifier: (const NSUInteger &)aRow
           asGroup: (const bool &)aAsGroup
{
    const IdentifierModel::IdentifierType lRetval = ((aAsGroup) ?
                                                     [mGroupSortCriteriaController mapIndexToIdentifier: aRow] :
                                                     [mZoneSortCriteriaController  mapIndexToIdentifier: aRow]);

    return (lRetval);
}

- (void) configureReusableCell: (GroupsAndZonesTableViewCell *)aCell
                  forIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger  lSection = aIndexPath.section;
    const NSUInteger  lRow = aIndexPath.row;


    nlREQUIRE(lSection == 0, done);

    if ((mShowStyle == kShowStyleGroups) || (mShowStyle == kShowStyleZones))
    {
        const bool  lAsGroup = (mShowStyle == kShowStyleGroups);
        Status      lStatus;

        // HLX identifiers are one rather than zero based; however,
        // UIKit table rows are zero based. Consequently, increment
        // the row by one to account for this.

        lStatus = [aCell configureCellForIdentifier: [self mapRowToIdentifier: lRow
                                                                      asGroup: lAsGroup]
                                     withController: *mClientController
                                            asGroup: lAsGroup];
        nlVERIFY_SUCCESS(lStatus);
    }

 done:
    return;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

- (void) controllerStateDidChange: (HLX::Client::Application::ControllerBasis &)aController withNotification: (const StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();
    NSIndexPath *            lIndexPath;

    switch (lType)
    {

    case StateChange::kStateChangeType_GroupMute:
    case StateChange::kStateChangeType_GroupName:
    case StateChange::kStateChangeType_GroupSource:
    case StateChange::kStateChangeType_GroupVolume:
        {
            if (mShowStyle == kShowStyleGroups)
            {
                const StateChange::GroupsNotificationBasis &lSCN = static_cast<const StateChange::GroupsNotificationBasis &>(aStateChangeNotification);
                const NSUInteger lRow = (lSCN.GetIdentifier() - 1);

                lIndexPath = [NSIndexPath indexPathForRow: lRow
                                          inSection: 0];

                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                                withRowAnimation: UITableViewRowAnimationNone];
            }
        }
        break;

    case StateChange::kStateChangeType_SourceName:
        [self.tableView reloadData];
        break;

    case StateChange::kStateChangeType_ZoneMute:
    case StateChange::kStateChangeType_ZoneName:
    case StateChange::kStateChangeType_ZoneSource:
    case StateChange::kStateChangeType_ZoneVolume:
        {
            if (mShowStyle == kShowStyleZones)
            {
                const StateChange::ZonesNotificationBasis &lSCN = static_cast<const StateChange::ZonesNotificationBasis &>(aStateChangeNotification);
                const NSUInteger lRow = (lSCN.GetIdentifier() - 1);

                lIndexPath = [NSIndexPath indexPathForRow: lRow
                                          inSection: 0];

                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                                withRowAnimation: UITableViewRowAnimationNone];
            }
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
