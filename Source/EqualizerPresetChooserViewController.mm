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
 *    This file implements a view controller for observing and choosing
 *    the HLX zone equalizer equalizer preset sound mode preset.
 *
 */

#import "EqualizerPresetChooserViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/HLXControllerDelegate.hpp>
#include <OpenHLX/Client/EqualizerPresetsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/EqualizerBandsModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "EqualizerPresetChooserTableViewCell.h"
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

template <typename Iterator>
static NSArray *indexPathsForEqualizerPreset(Iterator aBegin, Iterator aEnd)
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

static NSArray *indexPathsForEqualizerPreset(const SoundModel::SoundMode &aEqualizerPresetIdentifier)
{
    const EqualizerPresetModel::IdentifierType *lBegin = &aEqualizerPresetIdentifier;
    const EqualizerPresetModel::IdentifierType *lEnd = lBegin + 1;


    return (indexPathsForEqualizerPreset(lBegin, lEnd));
}

@interface EqualizerPresetChooserViewController ()
{

}

@end

@implementation EqualizerPresetChooserViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status  lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mHLXClientController->SetDelegate(mHLXClientControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone preset equalizer preset
 *    identifier chooser view controller from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone preset equalizer preset
 *    identifier chooser view controller, if successful; otherwise,
 *    null.
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
 *    Creates and initializes a zone preset equalizer preset
 *    identifier chooser view controller with the specified NIB name
 *    and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone preset equalizer preset
 *    identifier chooser view controller, if successful; otherwise,
 *    null.
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
    mHLXClientControllerDelegate.reset(new HLXClientControllerDelegate(self));
    nlREQUIRE(mHLXClientControllerDelegate != nullptr, done);

    mCurrentEqualizerPresetIdentifier = IdentifierModel::kIdentifierInvalid;

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
 *    Set the client controller and zone for the view.
 *
 *  @param[in]  aHLXClientController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aZone                 An immutable pointer to the zone
 *                                    for which its zone equalizer
 *                                    preset identifier is to be
 *                                    observed or mutated.
 *
 */
- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier;
    Status                                lStatus;


    mHLXClientController = aHLXClientController;
    mZone                = aZone;

    lStatus = mZone->GetEqualizerPreset(lEqualizerPresetIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    mCurrentEqualizerPresetIdentifier = lEqualizerPresetIdentifier;

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
    size_t     lValue = 0;
    NSInteger  lRetval = 0;
    Status     lStatus;


    nlREQUIRE(aSection == 0, done);

    lStatus = mHLXClientController->EqualizerPresetsGetMax(lValue);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = lValue;

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                            lSection = aIndexPath.section;
    const NSUInteger                            lRow = aIndexPath.row;

    // HLX identifiers are one rather than zero based; however, UIKit
    // table rows are zero based. Consequently, increment the row by
    // one to account for this to arrive at the equalizer preset identifier.

    const EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier = (lRow + 1);
    EqualizerPresetModel::IdentifierType        lCurrentEqualizerPresetIdentifier;
    EqualizerPresetChooserTableViewCell *       lRetval = nullptr;
    Status                                      lStatus;
    bool                                        lIsSelected;


    nlREQUIRE(lSection == 0, done);

    lRetval = [aTableView dequeueReusableCellWithIdentifier: @"Equalizer Preset Chooser View Cell"];
    nlREQUIRE(lRetval != nullptr, done);

    lStatus = mZone->GetEqualizerPreset(lCurrentEqualizerPresetIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lIsSelected = (lCurrentEqualizerPresetIdentifier == lEqualizerPresetIdentifier);

    if (lIsSelected)
    {
        mCurrentEqualizerPresetIdentifier = lCurrentEqualizerPresetIdentifier;
    }

    [self        configureReusableCell: lRetval
          forEqualizerPresetIdentifier: lEqualizerPresetIdentifier
                            isSelected: lIsSelected];

 done:
    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView didSelectRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                            lSection = aIndexPath.section;
    const NSUInteger                            lRow = aIndexPath.row;
    const EqualizerPresetModel::IdentifierType  lSelectedEqualizerPresetIdentifier = (lRow + 1);
    ZoneModel::IdentifierType                   lZoneIdentifier;
    Status                                      lStatus;


    // Sanity check to ensure we are not in an out-of-bounds section.

    nlREQUIRE(lSection == 0, done);

    // The only thing that needs to be done here is to send a set
    // equalizer preset request. Any UI changes will be handled on
    // the state change notification, if successful.

    lStatus = mZone->GetIdentifier(lZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mHLXClientController->ZoneSetEqualizerPreset(lZoneIdentifier, lSelectedEqualizerPresetIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

// MARK: Workers

- (void) configureReusableCell: (EqualizerPresetChooserTableViewCell *)aCell forEqualizerPresetIdentifier: (const EqualizerPresetModel::IdentifierType &)aEqualizerPresetIdentifier isSelected: (const bool &)aIsSelected
{
    Status           lStatus;


    lStatus = [aCell configureCellForEqualizerPresetIdentifier: aEqualizerPresetIdentifier
                                                withController: mHLXClientController
                                                    isSelected: aIsSelected];
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: State Change Notification Handlers

- (void) handleEqualizerPresetNameChanged: (const StateChange::EqualizerPresetsNameNotification &)aSCN
{
    const NSUInteger  lRow = (aSCN.GetIdentifier() - 1);
    const NSUInteger  lSection = 0;
    NSIndexPath *     lIndexPath;


    lIndexPath = [NSIndexPath indexPathForRow: lRow
                                    inSection: lSection];

    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                          withRowAnimation: UITableViewRowAnimationNone];
}

- (void) handleZoneEqualizerPresetChanged: (const StateChange::ZonesEqualizerPresetNotification &)aSCN
{
    const ZoneModel::IdentifierType             lZoneIdentifier = aSCN.GetIdentifier();
    const EqualizerPresetModel::IdentifierType  lNewEqualizerPresetIdentifier = aSCN.GetEqualizerPreset();
    ZoneModel::IdentifierType                   lCurrentZoneIdentifier;
    NSArray *                                   lNewIndexPaths;
    NSArray *                                   lPreviousIndexPaths;
    NSMutableSet *                              lReloadIndexPaths;
    Status                                      lStatus;


    lStatus = mZone->GetIdentifier(lCurrentZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different zone than
    // the one this controller is handling equalizer preset selection
    // for, ignore it.

    nlEXPECT(lCurrentZoneIdentifier == lZoneIdentifier, done);

    // Determine the previous-selected sound mode and row.

    lPreviousIndexPaths = indexPathsForEqualizerPreset(mCurrentEqualizerPresetIdentifier);
    nlREQUIRE(lPreviousIndexPaths != nullptr, done);

    // Determine and set the newly-selected equalizer preset and row.

    lNewIndexPaths = indexPathsForEqualizerPreset(lNewEqualizerPresetIdentifier);
    nlREQUIRE(lNewIndexPaths != nullptr, done);

    // Combine the previous and new index paths

    lReloadIndexPaths = [[NSMutableSet setWithCapacity: [lPreviousIndexPaths count] + [lNewIndexPaths count]] init];
    nlREQUIRE(lReloadIndexPaths != nullptr, done);

    [lReloadIndexPaths addObjectsFromArray: lPreviousIndexPaths];

    [lReloadIndexPaths addObjectsFromArray: lNewIndexPaths];

    // Establish the current, cached state

    mCurrentEqualizerPresetIdentifier = lNewEqualizerPresetIdentifier;

    // Refresh the cells for the previously- and newly-selected row.

    [self.tableView reloadRowsAtIndexPaths: [lReloadIndexPaths allObjects]
                          withRowAnimation: UITableViewRowAnimationNone];

 done:
    return;
}

- (void) handleZoneNameChanged: (const StateChange::ZonesNameNotification &)aSCN
{
    return;
}

- (void) handleZoneSoundModeChanged: (const StateChange::ZonesSoundModeNotification &)aSCN
{
    return;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

- (void) controllerStateDidChange: (Controller &)aController withNotification: (const StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();


    switch (lType)
    {

    case StateChange::kStateChangeType_EqualizerPresetName:
        {
            const StateChange::EqualizerPresetsNameNotification &lSCN = static_cast<const StateChange::EqualizerPresetsNameNotification &>(aStateChangeNotification);

            [self handleEqualizerPresetNameChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneEqualizerPreset:
        {
	    const StateChange::ZonesEqualizerPresetNotification &lSCN = static_cast<const StateChange::ZonesEqualizerPresetNotification &>(aStateChangeNotification);

	    [self handleZoneEqualizerPresetChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneName:
        {
            const StateChange::ZonesNameNotification &lSCN = static_cast<const StateChange::ZonesNameNotification &>(aStateChangeNotification);
            
            [self handleZoneNameChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneSoundMode:
        {
            const StateChange::ZonesSoundModeNotification &lSCN = static_cast<const StateChange::ZonesSoundModeNotification &>(aStateChangeNotification);

            [self handleZoneSoundModeChanged: lSCN];
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
