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
 *    This file implements a view controller for observing and mutating a
 *    HLX zone equalizer or preset equalizer band levels.
 *
 */

#import "EqualizerBandsDetailViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/HLXControllerDelegate.hpp>
#include <OpenHLX/Client/EqualizerPresetsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/EqualizerBandsModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "EqualizerBandsDetailTableViewCell.h"
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

@interface EqualizerBandsDetailViewController ()
{

}

@end

@implementation EqualizerBandsDetailViewController

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

    [self.tableView reloadData];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone or preset equalizer view
 *    controller from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone or preset equalizer view
 *    controller, if successful; otherwise, null.
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
 *    Creates and initializes a zone or preset equalizer view
 *    controller with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone or preset equalizer view
 *    controller, if successful; otherwise, null.
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
 *                                    for which its zone or preset
 *                                    equalizer band levels are to be
 *                                    observed or mutated.
 *
 */
- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    mHLXClientController = aHLXClientController;
    mZone                = aZone;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    static const NSInteger kNumberOfSections = 1;

    return (kNumberOfSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    static const size_t  kValue = EqualizerBandsModel::kEqualizerBandsMax;
    NSInteger            lRetval = 0;


    nlREQUIRE(aSection == 0, done);

    lRetval = kValue;

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                            lSection = aIndexPath.section;
    EqualizerBandsDetailTableViewCell *         lRetval = nullptr;


    nlREQUIRE(lSection == 0, done);

    lRetval = [aTableView dequeueReusableCellWithIdentifier: @"Equalizer Band View Cell"];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableCell: lRetval
                   forIndexPath: aIndexPath];

 done:
    return (lRetval);
}

// MARK: Workers

- (void) configureReusableCell: (EqualizerBandsDetailTableViewCell *)aCell forIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                          lSection = aIndexPath.section;
    const NSUInteger                          lRow = aIndexPath.row;

    // HLX identifiers are one rather than zero based; however, UIKit
    // table rows are zero based. Consequently, increment the row by
    // one to account for this.

    const EqualizerBandModel::IdentifierType  lEqualizerBandIdentifier = (lRow + 1);
    ZoneModel::IdentifierType                 lZoneIdentifier;
    Status                                    lStatus;


    nlREQUIRE(lSection == 0, done);

    lStatus = mZone->GetIdentifier(lZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = [aCell configureCellForIdentifier: lZoneIdentifier
                               andEqualizerBand: lEqualizerBandIdentifier
                                 withController: mHLXClientController
                                       asPreset: false];
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

- (void) handleEqualizerPresetBandChanged: (const StateChange::EqualizerPresetsBandNotification &)aSCN
{

}

- (void) handleEqualizerPresetNameChanged: (const StateChange::EqualizerPresetsNameNotification &)aSCN
{

}

- (void) handleZoneEqualizerBandChanged: (const StateChange::ZonesEqualizerBandNotification &)aSCN
{
    const ZoneModel::IdentifierType             lChangedZoneIdentifier = aSCN.GetIdentifier();
    const EqualizerBandModel::IdentifierType    lChangedEqualizerBandIdentifier = aSCN.GetBand();
    const NSUInteger                            lChangedRow = (lChangedEqualizerBandIdentifier - 1);
    ZoneModel::IdentifierType                   lCurrentZoneIdentifier;
    NSIndexPath *                               lIndexPath;
    Status                                      lStatus;


    lStatus = mZone->GetIdentifier(lCurrentZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different zone than
    // the one this controller is handling equalizer band modification
    // for, ignore it.
    
    nlEXPECT(lCurrentZoneIdentifier == lChangedZoneIdentifier, done);

    lIndexPath = [NSIndexPath indexPathForRow: lChangedRow
                                    inSection: 0];

    [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
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

    case StateChange::kStateChangeType_EqualizerPresetBand:
        {
            const StateChange::EqualizerPresetsBandNotification &lSCN = static_cast<const StateChange::EqualizerPresetsBandNotification &>(aStateChangeNotification);

            [self handleEqualizerPresetBandChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_EqualizerPresetName:
        {
            const StateChange::EqualizerPresetsNameNotification &lSCN = static_cast<const StateChange::EqualizerPresetsNameNotification &>(aStateChangeNotification);

            [self handleEqualizerPresetNameChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneEqualizerBand:
        {
            const StateChange::ZonesEqualizerBandNotification &lSCN = static_cast<const StateChange::ZonesEqualizerBandNotification &>(aStateChangeNotification);

            [self handleZoneEqualizerBandChanged: lSCN];
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
