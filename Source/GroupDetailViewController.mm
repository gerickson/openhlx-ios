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
 *    HLX group detailed properties such as source (input) and volume
 *    (including level and mute state).
 *
 */

#import "GroupDetailViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/HLXControllerDelegate.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Model/VolumeModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "GroupsAndZonesTableViewCell.h"
#import "HLXClientControllerDelegate.hpp"
#import "SourceChooserViewController.h"
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

@interface GroupDetailViewController ()
{

}

@end

@implementation GroupDetailViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.mVolumeSlider.minimumValue = static_cast<float>(VolumeModel::kLevelMin);
    self.mVolumeSlider.maximumValue = static_cast<float>(VolumeModel::kLevelMax);

    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status             lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mHLXClientController->SetDelegate(mHLXClientControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    [self refreshGroupMute];
    [self refreshGroupName];
    [self refreshGroupSourceName];
    [self refreshGroupVolume];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a group detail view controller from data
 *    in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group detail view controller, if
 *    successful; otherwise, null.
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
 *    Creates and initializes a group detail view controller with the
 *    specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group detail view controller, if
 *    successful; otherwise, null.
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

    mGroup = nullptr;

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if ([aSender isKindOfClass: [UITableViewCell class]])
    {
        SourceChooserViewController *  lSourceChooserViewController = [aSegue destinationViewController];
        Status                         lStatus;


        [lSourceChooserViewController setHLXClientController: mHLXClientController
                                                    forGroup: mGroup];

        lStatus = mHLXClientController->SetDelegate(nullptr);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the volume mute state switch.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onMuteSwitchAction: (id)aSender
{
    if (aSender == self.mMuteSwitch)
    {
        const VolumeModel::MuteType lMute = static_cast<VolumeModel::MuteType>(self.mMuteSwitch.on);
        GroupModel::IdentifierType  lIdentifier;
        Status                      lStatus;

        lStatus = mGroup->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->GroupSetMute(lIdentifier, lMute);
        nlEXPECT(lStatus >= 0, done);
    }

done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the volume level decrease "-"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onVolumeDecreaseButtonAction: (id)aSender
{
    if (aSender == self.mVolumeDecreaseButton)
    {
        GroupModel::IdentifierType  lIdentifier;
        Status                      lStatus;

        lStatus = mGroup->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->GroupDecreaseVolume(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the volume level adjustment
 *    slider.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onVolumeSliderAction: (id)aSender
{
    if (aSender == self.mVolumeSlider)
    {
        const VolumeModel::LevelType lVolume = static_cast<VolumeModel::LevelType>(self.mVolumeSlider.value);
        GroupModel::IdentifierType   lIdentifier;
        Status                       lStatus;

        lStatus = mGroup->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->GroupSetVolume(lIdentifier, lVolume);
        nlEXPECT(lStatus >= 0, done);
    }

done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the volume level increase "+"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onVolumeIncreaseButtonAction: (id)aSender
{
    if (aSender == self.mVolumeIncreaseButton)
    {
        GroupModel::IdentifierType lIdentifier;
        Status                     lStatus;

        lStatus = mGroup->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->GroupIncreaseVolume(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

// MARK: Setters

/**
 *  @brief
 *    Set the client controller and group for the view.
 *
 *  @param[in]  aHLXClientController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aGroup                An immutable pointer to the group
 *                                    for which its source and volume
 *                                    detail is to be observed or
 *                                    mutated.
 *
 */
- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                       forGroup: (const HLX::Model::GroupModel *)aGroup
{
    mHLXClientController = aHLXClientController;
    mGroup               = aGroup;
}

// MARK: Table View Data Source Delegation


// MARK: Workers

- (void) refreshGroupMute
{
    VolumeModel::MuteType        lMute = true;
    Status                       lStatus;

    lStatus = mGroup->GetMute(lMute);
    nlREQUIRE_SUCCESS(lStatus, done);

    self.mMuteSwitch.on       = lMute;

 done:
    return;
}

- (void) refreshGroupName
{
    const char *                 lUTF8StringGroupName;
    NSString *                   lNSStringGroupName;
    Status                       lStatus;

    lStatus = mGroup->GetName(lUTF8StringGroupName);
    nlREQUIRE_SUCCESS(lStatus, done);

    lNSStringGroupName = [NSString stringWithUTF8String: lUTF8StringGroupName];
    nlREQUIRE_ACTION(lNSStringGroupName != nullptr, done, lStatus = -ENOMEM);

    self.mGroupName.title      = lNSStringGroupName;

 done:
    return;
}

- (void) refreshGroupSourceName
{
    size_t                       lSourceCount;
    NSString *                   lNSStringSourceName;
    Status                       lStatus;


    lStatus = mGroup->GetSources(lSourceCount);
    nlREQUIRE_SUCCESS(lStatus, done);

    if (lSourceCount == 1)
    {
        SourceModel::IdentifierType  lSourceIdentifier;
        const SourceModel *          lSource;
        const char *                 lUTF8StringSourceName;

        lStatus = mGroup->GetSources(&lSourceIdentifier, lSourceCount);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->SourceGet(lSourceIdentifier, lSource);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = lSource->GetName(lUTF8StringSourceName);
        nlREQUIRE_SUCCESS(lStatus, done);

        lNSStringSourceName = [NSString stringWithUTF8String: lUTF8StringSourceName];
        nlREQUIRE_ACTION(lNSStringSourceName != nullptr, done, lStatus = -ENOMEM);
    }
    else if (lSourceCount > 1)
    {
        lNSStringSourceName = NSLocalizedString(@"MultipleGroupSourceSummaryKey", @"");
    }

    self.mSourceName.text = lNSStringSourceName;

 done:
    return;
}

- (void) refreshGroupVolume
{
    VolumeModel::LevelType      lVolume = VolumeModel::kLevelMin;
    Status                       lStatus;

    lStatus = mGroup->GetVolume(lVolume);
    nlREQUIRE_SUCCESS(lStatus, done);

    self.mVolumeSlider.value  = static_cast<float>(lVolume);

    if (lVolume == static_cast<const VolumeModel::LevelType>(self.mVolumeSlider.minimumValue))
    {
        self.mVolumeDecreaseButton.enabled = false;
        self.mVolumeIncreaseButton.enabled = true;
    }
    else if (lVolume == static_cast<const VolumeModel::LevelType>(self.mVolumeSlider.maximumValue))
    {
        self.mVolumeDecreaseButton.enabled = true;
        self.mVolumeIncreaseButton.enabled = false;
    }
    else
    {
        self.mVolumeDecreaseButton.enabled = true;
        self.mVolumeIncreaseButton.enabled = true;
    }

 done:
    return;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

- (void) controllerStateDidChange: (HLX::Client::Controller &)aController withNotification: (const HLX::Client::StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();


    switch (lType)
    {

    case StateChange::kStateChangeType_SourceName:
        // Refresh on any group source name change

        [self refreshGroupSourceName];
        break;

    case StateChange::kStateChangeType_GroupMute:
    case StateChange::kStateChangeType_GroupName:
    case StateChange::kStateChangeType_GroupSource:
    case StateChange::kStateChangeType_GroupVolume:
        {
            const StateChange::GroupsNotificationBasis &lSCN = static_cast<const StateChange::GroupsNotificationBasis &>(aStateChangeNotification);
            const GroupModel::IdentifierType lSCNIdentifier = lSCN.GetIdentifier();
            GroupModel::IdentifierType lOurIdentifier;
            Status lStatus;

            lStatus = mGroup->GetIdentifier(lOurIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            nlEXPECT(lSCNIdentifier == lOurIdentifier, done);

            switch (lType)
            {

            case StateChange::kStateChangeType_GroupMute:
                [self refreshGroupMute];
                break;

            case StateChange::kStateChangeType_GroupName:
                [self refreshGroupName];
                break;

            case StateChange::kStateChangeType_GroupSource:
                [self refreshGroupSourceName];
                break;

            case StateChange::kStateChangeType_GroupVolume:
                [self refreshGroupVolume];
                break;

            default:
                break;

            }
            break;
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
