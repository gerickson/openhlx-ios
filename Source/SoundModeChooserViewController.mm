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
 *    a HLX zone equalizer sound mode.
 *
 */

#import "SoundModeChooserViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/SoundModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "SoundModeChooserTableViewCell.h"
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
static NSArray *
indexPathsForSoundMode(Iterator aBegin, Iterator aEnd)
{
    const size_t      lSoundModeCount = (aEnd - aBegin);
    NSMutableArray *  lIndexPaths = nullptr;


    lIndexPaths = [[NSMutableArray arrayWithCapacity: lSoundModeCount] init];
    nlREQUIRE(lIndexPaths != nullptr, done);

    while (aBegin != aEnd)
    {
        const NSUInteger  lRow = (*aBegin);
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
indexPathsForSoundMode(const SoundModel::SoundMode &aSoundMode)
{
    const SoundModel::SoundMode *lBegin = &aSoundMode;
    const SoundModel::SoundMode *lEnd = lBegin + 1;


    return (indexPathsForSoundMode(lBegin, lEnd));
}

@interface SoundModeChooserViewController ()
{

}

@end

@implementation SoundModeChooserViewController

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
    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    mCurrentSoundMode = SoundModel::kSoundModeDisabled;

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
 *  @param[in]  aApplicationController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aZone                 An immutable pointer to the zone
 *                                    for which its zone equalizer
 *                                    sound mode is to be observed or
 *                                    mutated.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    SoundModel::SoundMode  lSoundMode;
    Status                 lStatus;


    mApplicationController = aApplicationController;
    mZone                = aZone;

    lStatus = mZone->GetSoundMode(lSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    mCurrentSoundMode = lSoundMode;

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
    NSInteger  lRetval = 0;


    nlREQUIRE(aSection == 0, done);

    lRetval = (SoundModel::kSoundModeMax - SoundModel::kSoundModeMin + 1);

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                   lSection = aIndexPath.section;
    const NSUInteger                   lRow = aIndexPath.row;
    const SoundModel::SoundMode        lSoundMode = lRow;
    SoundModel::SoundMode              lCurrentSoundMode;
    SoundModeChooserTableViewCell *    lRetval = nullptr;
    Status                             lStatus;
    bool                               lIsSelected;


    nlREQUIRE(lSection == 0, done);

    lRetval = [aTableView dequeueReusableCellWithIdentifier: @"Sound Mode Chooser View Cell"];
    nlREQUIRE(lRetval != nullptr, done);

    lStatus = mZone->GetSoundMode(lCurrentSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    lIsSelected = (lCurrentSoundMode == lSoundMode);

    if (lIsSelected)
    {
        mCurrentSoundMode = lCurrentSoundMode;
    }

    [self configureReusableCell: lRetval
                   forSoundMode: lSoundMode
                     isSelected: lIsSelected];

 done:
    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView didSelectRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                   lSection = aIndexPath.section;
    const NSUInteger                   lRow = aIndexPath.row;
    const SoundModel::SoundMode        lSelectedSoundMode = lRow;
    ZoneModel::IdentifierType          lZoneIdentifier;
    Status                             lStatus;


    // Sanity check to ensure we are not in an out-of-bounds section.

    nlREQUIRE(lSection == 0, done);

    // The only thing that needs to be done here is to send a set
    // sound mode request. Any UI changes will be handled on the state
    // change notification, if successful.

    lStatus = mZone->GetIdentifier(lZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // Note that, unfortunately, a successful sound mode change will
    // not result in a subsequent notification of the properties
    // associated with that sound mode. Consequently, we must follow
    // up the sound mode set with a query for the same zone to force a
    // notification of the associated properties.

    lStatus = mApplicationController->ZoneSetSoundMode(lZoneIdentifier, lSelectedSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mApplicationController->ZoneQuery(lZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

// MARK: Workers

- (void) configureReusableCell: (SoundModeChooserTableViewCell *)aCell
                  forSoundMode: (const SoundModel::SoundMode &)aSoundMode
		    isSelected: (const bool &)aIsSelected
{
    Status           lStatus;


    lStatus = [aCell configureCellForSoundMode: aSoundMode
                                withController: mApplicationController
                                    isSelected: aIsSelected];
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: State Change Notification Handlers

- (void) handleZoneSoundModeChanged: (const StateChange::ZonesSoundModeNotification &)aSCN
{
    const ZoneModel::IdentifierType  lZoneIdentifier = aSCN.GetIdentifier();
    const SoundModel::SoundMode      lNewSoundMode = aSCN.GetSoundMode();
    ZoneModel::IdentifierType        lCurrentZoneIdentifier;
    NSArray *                        lNewIndexPaths;
    NSArray *                        lPreviousIndexPaths;
    NSMutableSet *                   lReloadIndexPaths;
    Status                           lStatus;


    lStatus = mZone->GetIdentifier(lCurrentZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different zone than
    // the one this controller is handling sound mode selection for,
    // ignore it.

    nlEXPECT(lCurrentZoneIdentifier == lZoneIdentifier, done);

    // Determine the previous-selected sound mode and row.

    lPreviousIndexPaths = indexPathsForSoundMode(mCurrentSoundMode);
    nlREQUIRE(lPreviousIndexPaths != nullptr, done);

    // Determine and set the newly-selected sound mode and row.

    lNewIndexPaths = indexPathsForSoundMode(lNewSoundMode);
    nlREQUIRE(lNewIndexPaths != nullptr, done);

    // Combine the previous and new index paths

    lReloadIndexPaths = [[NSMutableSet setWithCapacity: [lPreviousIndexPaths count] + [lNewIndexPaths count]] init];
    nlREQUIRE(lReloadIndexPaths != nullptr, done);

    [lReloadIndexPaths addObjectsFromArray: lPreviousIndexPaths];

    [lReloadIndexPaths addObjectsFromArray: lNewIndexPaths];

    // Establish the current, cached state

    mCurrentSoundMode = lNewSoundMode;

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

- (void) controllerStateDidChange: (HLX::Client::Application::ControllerBasis &)aController withNotification: (const HLX::Client::StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();


    switch (lType)
    {

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
