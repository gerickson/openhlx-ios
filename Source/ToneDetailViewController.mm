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
 *    This file implements a view controller for observing and mutating
 *    a HLX zone equalizer tone sound mode bass and treble levels.
 *
 */

#import "ToneDetailViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/HLXControllerDelegate.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/ToneModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

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

@interface ToneDetailViewController ()
{

}

@end

@implementation ToneDetailViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.mBassSlider.minimumValue = static_cast<float>(ToneModel::kLevelMin);
    self.mBassSlider.maximumValue = static_cast<float>(ToneModel::kLevelMax);

    self.mTrebleSlider.minimumValue = static_cast<float>(ToneModel::kLevelMin);
    self.mTrebleSlider.maximumValue = static_cast<float>(ToneModel::kLevelMax);

    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status             lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mHLXClientController->SetDelegate(mHLXClientControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    [self refreshZoneTone];
    [self refreshZoneSoundMode];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone equalizer tone sound mode detail
 *    view controller from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone equalizer tone sound mode
 *    detail view controller, if successful; otherwise, null.
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
 *    Creates and initializes a zone equalizer tone sound mode detail
 *    view controller with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone equalizer tone sound mode
 *    detail view controller, if successful; otherwise, null.
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

    mZone = nullptr;

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the tone bass level center "▾"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBassCenterButtonAction: (id)aSender
{
    if (aSender == self.mBassCenterButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneSetBass(lIdentifier, ToneModel::kLevelFlat);
        nlREQUIRE(lStatus >= kStatus_Success, done);
    }

done:
   return;
}

/**
 *  @brief
 *    This is the action handler for the tone bass level decrease "-"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBassDecreaseButtonAction: (id)aSender
{
    if (aSender == self.mBassDecreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneDecreaseBass(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone bass level adjustment
 *    slider.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBassSliderAction: (id)aSender
{
    if (aSender == self.mBassSlider)
    {
        const ToneModel::LevelType  lBass = static_cast<ToneModel::LevelType>(self.mBassSlider.value);
        ZoneModel::IdentifierType   lIdentifier;
        Status                      lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneSetBass(lIdentifier, lBass);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone bass level increase "+"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBassIncreaseButtonAction: (id)aSender
{
    if (aSender == self.mBassIncreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneIncreaseBass(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone treble level center "▾"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onTrebleCenterButtonAction: (id)aSender
{
    if (aSender == self.mTrebleCenterButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneSetTreble(lIdentifier, ToneModel::kLevelFlat);
        nlREQUIRE(lStatus >= kStatus_Success, done);
    }

done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone treble level decrease "-"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onTrebleDecreaseButtonAction: (id)aSender
{
    if (aSender == self.mTrebleDecreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneDecreaseTreble(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone treble level adjustment
 *    slider.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onTrebleSliderAction: (id)aSender
{
    if (aSender == self.mTrebleSlider)
    {
        const ToneModel::LevelType  lTreble = static_cast<ToneModel::LevelType>(self.mTrebleSlider.value);
        ZoneModel::IdentifierType   lIdentifier;
        Status                      lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneSetTreble(lIdentifier, lTreble);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the tone treble level increase "+"
 *    button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onTrebleIncreaseButtonAction: (id)aSender
{
    if (aSender == self.mTrebleIncreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mHLXClientController->ZoneIncreaseTreble(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

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
 *                                    for which its zone equalizer tone
 *                                    sound mode detail is to be observed
 *                                    or mutated.
 *
 */
- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    mHLXClientController = aHLXClientController;
    mZone                = aZone;
}

// MARK: Table View Data Source Delegation


// MARK: Workers

- (void) refreshZoneTone
{
    ToneModel::LevelType  lBass;
    ToneModel::LevelType  lTreble;
    Status                lStatus;

    lStatus = mZone->GetTone(lBass, lTreble);
    nlREQUIRE_SUCCESS(lStatus, done);

    [self refreshZoneToneBass: lBass
                    andTreble: lTreble];

 done:
    return;
}

- (void) refreshZoneToneBass: (const ToneModel::LevelType &)aBass
         andTreble: (const ToneModel::LevelType &)aTreble
{
    [self refreshZoneBass: aBass];
    [self refreshZoneTreble: aTreble];
}

- (void) refreshZoneBass: (const ToneModel::LevelType &)aBass
{
    NSString * lBassLevelText = nullptr;


    lBassLevelText = [NSString stringWithFormat: @"%d dB", aBass];
    nlREQUIRE(lBassLevelText != nullptr, done);

    self.mBassSlider.value        = static_cast<float>(aBass);
    self.mBassLevelTextField.text = lBassLevelText;

    if (aBass == static_cast<const ToneModel::LevelType>(self.mBassSlider.minimumValue))
    {
        self.mBassDecreaseButton.enabled = false;
        self.mBassIncreaseButton.enabled = true;
        self.mBassCenterButton.enabled = true;
    }
    else if (aBass == static_cast<const ToneModel::LevelType>(self.mBassSlider.maximumValue))
    {
        self.mBassDecreaseButton.enabled = true;
        self.mBassIncreaseButton.enabled = false;
        self.mBassCenterButton.enabled = true;
    }
    else if (aBass == ToneModel::kLevelFlat)
    {
        self.mBassDecreaseButton.enabled = true;
        self.mBassIncreaseButton.enabled = true;
        self.mBassCenterButton.enabled = false;
    }
    else
    {
        self.mBassDecreaseButton.enabled = true;
        self.mBassIncreaseButton.enabled = true;
        self.mBassCenterButton.enabled = true;
    }

 done:
    return;
}

- (void) refreshZoneTreble: (const ToneModel::LevelType &)aTreble
{
    NSString * lTrebleLevelText = nullptr;


    lTrebleLevelText = [NSString stringWithFormat: @"%d dB", aTreble];
    nlREQUIRE(lTrebleLevelText != nullptr, done);

    self.mTrebleSlider.value        = static_cast<float>(aTreble);
    self.mTrebleLevelTextField.text = lTrebleLevelText;

    if (aTreble == static_cast<const ToneModel::LevelType>(self.mTrebleSlider.minimumValue))
    {
        self.mTrebleDecreaseButton.enabled = false;
        self.mTrebleIncreaseButton.enabled = true;
        self.mTrebleCenterButton.enabled = true;
    }
    else if (aTreble == static_cast<const ToneModel::LevelType>(self.mTrebleSlider.maximumValue))
    {
        self.mTrebleDecreaseButton.enabled = true;
        self.mTrebleIncreaseButton.enabled = false;
        self.mTrebleCenterButton.enabled = true;
    }
    else if (aTreble == ToneModel::kLevelFlat)
    {
        self.mTrebleDecreaseButton.enabled = true;
        self.mTrebleIncreaseButton.enabled = true;
        self.mTrebleCenterButton.enabled = false;
    }
    else
    {
        self.mTrebleDecreaseButton.enabled = true;
        self.mTrebleIncreaseButton.enabled = true;
        self.mTrebleCenterButton.enabled = true;
    }

 done:
    return;
}

- (void) refreshZoneName
{
    const char *                 lUTF8StringZoneName;
    NSString *                   lNSStringZoneName;
    Status                       lStatus;

    lStatus = mZone->GetName(lUTF8StringZoneName);
    nlREQUIRE_SUCCESS(lStatus, done);

    lNSStringZoneName = [NSString stringWithUTF8String: lUTF8StringZoneName];
    nlREQUIRE_ACTION(lNSStringZoneName != nullptr, done, lStatus = -ENOMEM);

    self.mZoneName.title      = lNSStringZoneName;

 done:
    return;
}

- (void) refreshZoneSoundMode
{
    SoundModel::ChannelMode       lChannelMode;
    SoundModel::SoundMode         lSoundMode;
    Status                        lStatus;

    lStatus = mZone->GetChannelMode(lChannelMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mZone->GetSoundMode(lSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    switch (lSoundMode)
    {

    case SoundModel::kSoundModeDisabled:
        break;

    case SoundModel::kSoundModeZoneEqualizer:
        break;

    case SoundModel::kSoundModePresetEqualizer:
        break;

    case SoundModel::kSoundModeTone:
        break;

    case SoundModel::kSoundModeLowpass:
        break;

    case SoundModel::kSoundModeHighpass:
        break;

    default:
        break;
    }

 done:
    return;
}

- (void) handleZoneToneChanged: (const StateChange::ZonesToneNotification &)aSCN
{
    [self refreshZoneToneBass: aSCN.GetBass()
                    andTreble: aSCN.GetTreble()];
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

    case StateChange::kStateChangeType_ZoneName:
    case StateChange::kStateChangeType_ZoneSoundMode:
    case StateChange::kStateChangeType_ZoneTone:
        {
            const StateChange::ZonesNotificationBasis &lSCN = static_cast<const StateChange::ZonesNotificationBasis &>(aStateChangeNotification);
            const ZoneModel::IdentifierType lSCNIdentifier = lSCN.GetIdentifier();
            ZoneModel::IdentifierType lOurIdentifier;
            Status lStatus;

            lStatus = mZone->GetIdentifier(lOurIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            nlEXPECT(lSCNIdentifier == lOurIdentifier, done);

            switch (lType)
            {

            case StateChange::kStateChangeType_ZoneName:
                [self refreshZoneName];
                break;

            case StateChange::kStateChangeType_ZoneSoundMode:
                [self refreshZoneSoundMode];
                break;

            case StateChange::kStateChangeType_ZoneTone:
                {
                    const StateChange::ZonesToneNotification &lSCN = static_cast<const StateChange::ZonesToneNotification &>(aStateChangeNotification);
		
                    [self handleZoneToneChanged: lSCN];
                }
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
