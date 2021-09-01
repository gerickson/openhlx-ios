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
 *    This file implements a view controller for observing and mutating a
 *    HLX group or zone source(s) (input(s)).
 *
 */

#import "SourceChooserViewController.h"

#include <iomanip>
#include <sstream>
#include <vector>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Client/SourcesStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/SourceModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "SourceChooserTableViewCell.h"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"


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

namespace Detail
{
    typedef std::vector<SourceModel::IdentifierType> SourceIdentifiers;
};

template <typename Iterator>
static NSArray *
indexPathsForIdentifiers(Iterator aBegin, Iterator aEnd)
{
    const size_t      lIdentifierCount = (aEnd - aBegin);
    NSMutableArray *  lIndexPaths = nullptr;


    lIndexPaths = [[NSMutableArray arrayWithCapacity: lIdentifierCount] init];
    nlREQUIRE(lIndexPaths != nullptr, done);

    while (aBegin != aEnd)
    {
        const NSUInteger  lRow = (*aBegin - 1);
        const NSUInteger  lSection = 0;
        NSIndexPath *     lIndexPath;

        lIndexPath = [NSIndexPath indexPathForRow: lRow
                                        inSection: lSection];
        nlREQUIRE(lIndexPath != nullptr, done);

        [lIndexPaths addObject: lIndexPath];

        aBegin++;
    }

 done:
    return (lIndexPaths);
}

static NSArray *
indexPathsForIdentifier(const IdentifiersCollection::IdentifierType &aIdentifier)
{
    const IdentifiersCollection::IdentifierType *lBegin = &aIdentifier;
    const IdentifiersCollection::IdentifierType *lEnd = lBegin + 1;


    return (indexPathsForIdentifiers(lBegin, lEnd));
}

static NSArray *
indexPathsForIdentifiers(const IdentifiersCollection &aIdentifiers)
{
    Status                                     lStatus;
    size_t                                     lIdentifierCount;
    Detail::SourceIdentifiers                  lIdentifiers;
    Detail::SourceIdentifiers::const_iterator  lIdentifierCurrent;
    Detail::SourceIdentifiers::const_iterator  lIdentifierEnd;
    NSArray *                                  lIndexPaths = nullptr;


    lStatus = aIdentifiers.GetCount(lIdentifierCount);
    nlREQUIRE_SUCCESS(lStatus, done);

    lIdentifiers.resize(lIdentifierCount);

    lStatus = aIdentifiers.GetIdentifiers(&lIdentifiers[0], lIdentifierCount);
    nlREQUIRE_SUCCESS(lStatus, done);

    lIdentifierCurrent = lIdentifiers.begin();
    lIdentifierEnd = lIdentifiers.end();

    lIndexPaths = indexPathsForIdentifiers(lIdentifierCurrent, lIdentifierEnd);
    nlREQUIRE(lIndexPaths != nullptr, done);

 done:
    return (lIndexPaths);
}

@interface SourceChooserViewController ()
{

}

@end

@implementation SourceChooserViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status  lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mApplicationController->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone equalizer sound mode chooser view
 *    controller from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone equalizer sound mode chooser
 *    view controller, if successful; otherwise, null.
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
 *    Creates and initializes a zone equalizer sound mode chooser view
 *    controller with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone equalizer sound mode chooser
 *    view controller, if successful; otherwise, null.
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
    Status  lStatus;


    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    lStatus = mCurrentSourceIdentifiers.Init();
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    return;
}

// MARK: Actions

// MARK: Setters

/**
 *  @brief
 *    Set the client controller and group for the view.
 *
 *  @param[in]  aApplicationController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aGroup                An immutable pointer to the
 *                                    group for which its group
 *                                    source(s) is/are to be observed
 *                                    or mutated.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                       forGroup: (const HLX::Model::GroupModel *)aGroup
{
    Status  lStatus;


    mApplicationController = aApplicationController;
    mUnion.mGroup        = aGroup;
    mIsGroup             = true;

    lStatus = mUnion.mGroup->GetSources(mCurrentSourceIdentifiers);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

/**
 *  @brief
 *    Set the client controller and zone for the view.
 *
 *  @param[in]  aApplicationController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aZone                 An immutable pointer to the
 *                                    zone for which its zone source
 *                                    is to be observed or mutated.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    SourceModel::IdentifierType  lSourceIdentifier;
    Status                       lStatus;


    mApplicationController = aApplicationController;
    mUnion.mZone         = aZone;
    mIsGroup             = false;

    lStatus = mUnion.mZone->GetSource(lSourceIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mCurrentSourceIdentifiers.SetIdentifiers(&lSourceIdentifier, 1);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    static const NSInteger kNumberOfSections = 1;

    return (kNumberOfSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    SourcesModel::IdentifierType  lValue = 0;
    NSInteger                     lRetval = 0;
    Status                        lStatus;

    nlREQUIRE(aSection == 0, done);

    lStatus = mApplicationController->SourcesGetMax(lValue);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = lValue;

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                   lSection = aIndexPath.section;
    const NSUInteger                   lRow = aIndexPath.row;

    // HLX identifiers are one rather than zero based; however, UIKit
    // table rows are zero based. Consequently, increment the row by
    // one to account for this to arrive at the source identifier.

    const SourceModel::IdentifierType  lSourceIdentifier = (lRow + 1);
    SourceChooserTableViewCell *       lRetval = nullptr;
    Status                             lStatus;
    bool                               lIsSelected;


    nlREQUIRE(lSection == 0, done);

    lRetval = [aTableView dequeueReusableCellWithIdentifier: @"Source Chooser View Cell"];
    nlREQUIRE(lRetval != nullptr, done);

    if (mIsGroup)
    {
        size_t                                     lGroupSourceCount;
        Detail::SourceIdentifiers                  lGroupSources;
        Detail::SourceIdentifiers::const_iterator  lGroupSourceCurrent;
        Detail::SourceIdentifiers::const_iterator  lGroupSourceEnd;
        Detail::SourceIdentifiers::const_iterator  lResult;

        lStatus = mUnion.mGroup->GetSources(lGroupSourceCount);
        nlREQUIRE_SUCCESS(lStatus, done);

        lGroupSources.resize(lGroupSourceCount);

        lStatus = mUnion.mGroup->GetSources(&lGroupSources[0], lGroupSourceCount);
        nlREQUIRE_SUCCESS(lStatus, done);

        // If the source identifier corresponding to this row is in
        // the source set for this group, then this row should be
        // selected.

        lGroupSourceCurrent = lGroupSources.begin();
        lGroupSourceEnd = lGroupSources.end();

        lResult = std::find(lGroupSourceCurrent, lGroupSourceEnd, lSourceIdentifier);

        lIsSelected = (lResult != lGroupSourceEnd);
    }
    else
    {
        SourceModel::IdentifierType  lCurrentSourceIdentifier;

        lStatus = mUnion.mZone->GetSource(lCurrentSourceIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lIsSelected = (lCurrentSourceIdentifier == lSourceIdentifier);

        if (lIsSelected)
        {
            lStatus = mCurrentSourceIdentifiers.SetIdentifiers(&lCurrentSourceIdentifier, 1);
            nlREQUIRE(lStatus > kStatus_Success, done);
        }
    }

    [self configureReusableCell: lRetval
            forSourceIdentifier: lSourceIdentifier
                     isSelected: lIsSelected];

 done:
    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView didSelectRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                   lSection = aIndexPath.section;
    const NSUInteger                   lRow = aIndexPath.row;
    const SourceModel::IdentifierType  lSelectedSourceIdentifier = (lRow + 1);
    Status                             lStatus;


    // Sanity check to ensure we are not in an out-of-bounds section.

    nlREQUIRE(lSection == 0, done);

    // The only thing that needs to be done here is to send a set
    // source request. Any UI changes will be handled on the state
    // change notification, if successful.

    if (mIsGroup)
    {
        GroupModel::IdentifierType  lGroupIdentifier;

        lStatus = mUnion.mGroup->GetIdentifier(lGroupIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->GroupSetSource(lGroupIdentifier, lSelectedSourceIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        ZoneModel::IdentifierType  lZoneIdentifier;

        lStatus = mUnion.mZone->GetIdentifier(lZoneIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneSetSource(lZoneIdentifier, lSelectedSourceIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

 done:
    return;
}

// MARK: Workers

- (void) configureReusableCell: (SourceChooserTableViewCell *)aCell
           forSourceIdentifier: (const SourceModel::IdentifierType &)aSourceIdentifier
	            isSelected: (const bool &)aIsSelected
{
    Status           lStatus;


    lStatus = [aCell configureCellForIdentifier: aSourceIdentifier
                                 withController: mApplicationController
                                     isSelected: aIsSelected];
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: State Change Notification Handlers

- (void) handleGroupSourceChanged: (const StateChange::GroupsSourceNotification &)aSCN
{
    const GroupModel::IdentifierType  lGroupIdentifier = aSCN.GetIdentifier();
    const GroupModel::Sources &       lGroupSourceIdentifiers = aSCN.GetSources();
    GroupModel::IdentifierType        lCurrentGroupIdentifier;
    NSArray *                         lPreviousIndexPaths;
    NSArray *                         lNewIndexPaths;
    NSMutableSet *                    lReloadIndexPaths;
    Status                            lStatus;


    // If this controller is handling a zone, then there is nothing to
    // do with respect to a source change for a group.

    nlEXPECT(mIsGroup, done);

    lStatus = mUnion.mGroup->GetIdentifier(lCurrentGroupIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different group than
    // the one this controller is handling source selection for,
    // ignore it.

    nlEXPECT(lCurrentGroupIdentifier == lGroupIdentifier, done);

    // Determine the previous-selected sources, identifiers, and rows.

    lPreviousIndexPaths = indexPathsForIdentifiers(mCurrentSourceIdentifiers);
    nlREQUIRE(lPreviousIndexPaths != nullptr, done);

    // Determine and set the newly-selected sources, identifiers, and
    // rows.

    lNewIndexPaths = indexPathsForIdentifiers(lGroupSourceIdentifiers);
    nlREQUIRE(lNewIndexPaths != nullptr, done);

    // Combine the previous and new index paths

    lReloadIndexPaths = [[NSMutableSet setWithCapacity: [lPreviousIndexPaths count] + [lNewIndexPaths count]] init];
    nlREQUIRE(lReloadIndexPaths != nullptr, done);

    [lReloadIndexPaths addObjectsFromArray: lPreviousIndexPaths];

    [lReloadIndexPaths addObjectsFromArray: lNewIndexPaths];

    // Establish the current, cached state

    lStatus = mCurrentSourceIdentifiers.SetIdentifiers(lGroupSourceIdentifiers);
    nlREQUIRE_SUCCESS(lStatus, done);

    // Refresh the cells for the previously- and newly-selected rows.

    [self.tableView reloadRowsAtIndexPaths: [lReloadIndexPaths allObjects]
                          withRowAnimation: UITableViewRowAnimationNone];

 done:
    return;
}

- (void) handleSourceNameChanged: (const StateChange::SourcesNameNotification &)aSCN
{
    const NSUInteger  lRow = (aSCN.GetIdentifier() - 1);
    const NSUInteger  lSection = 0;
    NSIndexPath *     lIndexPath;


    lIndexPath = [NSIndexPath indexPathForRow: lRow
                                    inSection: lSection];

    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                          withRowAnimation: UITableViewRowAnimationNone];
}

- (void) handleZoneSourceChanged: (const StateChange::ZonesSourceNotification &)aSCN
{
    const ZoneModel::IdentifierType    lZoneIdentifier = aSCN.GetIdentifier();
    const SourceModel::IdentifierType  lNewSourceIdentifier = aSCN.GetSource();
    ZoneModel::IdentifierType          lCurrentZoneIdentifier;
    NSArray *                          lNewIndexPaths;
    NSArray *                          lPreviousIndexPaths;
    NSMutableSet *                     lReloadIndexPaths;
    Status                             lStatus;


    // If this controller is handling a group, then there is nothing to
    // do with respect to a source change for a zone.

    nlEXPECT(!mIsGroup, done);

    lStatus = mUnion.mZone->GetIdentifier(lCurrentZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different zone than
    // the one this controller is handling source selection for,
    // ignore it.

    nlEXPECT(lCurrentZoneIdentifier == lZoneIdentifier, done);

    // Determine the previous-selected source, identifier, and row.

    lPreviousIndexPaths = indexPathsForIdentifiers(mCurrentSourceIdentifiers);
    nlREQUIRE(lPreviousIndexPaths != nullptr, done);

    // Determine and set the newly-selected source, identifier, and
    // row.

    lNewIndexPaths = indexPathsForIdentifier(lNewSourceIdentifier);
    nlREQUIRE(lNewIndexPaths != nullptr, done);

    // Combine the previous and new index paths

    lReloadIndexPaths = [[NSMutableSet setWithCapacity: [lPreviousIndexPaths count] + [lNewIndexPaths count]] init];
    nlREQUIRE(lReloadIndexPaths != nullptr, done);

    [lReloadIndexPaths addObjectsFromArray: lPreviousIndexPaths];

    [lReloadIndexPaths addObjectsFromArray: lNewIndexPaths];

    // Establish the current, cached state

    lStatus = mCurrentSourceIdentifiers.SetIdentifiers(&lNewSourceIdentifier, 1);
    nlREQUIRE_SUCCESS(lStatus, done);

    // Refresh the cells for the previously- and newly-selected row.

    [self.tableView reloadRowsAtIndexPaths: [lReloadIndexPaths allObjects]
                          withRowAnimation: UITableViewRowAnimationNone];

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

- (void) controllerStateDidChange: (HLX::Client::Application::Controller &)aController withNotification: (const StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();


    switch (lType)
    {

    case StateChange::kStateChangeType_GroupSource:
        {
            const StateChange::GroupsSourceNotification &lSCN = static_cast<const StateChange::GroupsSourceNotification &>(aStateChangeNotification);

            [self handleGroupSourceChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_SourceName:
        {
            const StateChange::SourcesNameNotification &lSCN = static_cast<const StateChange::SourcesNameNotification &>(aStateChangeNotification);

            [self handleSourceNameChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneSource:
        {
            const StateChange::ZonesSourceNotification &  lSCN = static_cast<const StateChange::ZonesSourceNotification &>(aStateChangeNotification);

            [self handleZoneSourceChanged: lSCN];
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
