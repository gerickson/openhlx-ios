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
 *    This file implements a view controller for observing and
 *    mutating a HLX zone detailed properties such as stereophonic
 *    channel balance (installer-only), equalizer channel and sound
 *    mode (installer-only), source (input), and volume (including
 *    level and mute state).
 *
 */

#import "ZoneDetailViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/VolumeModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "CrossoverDetailViewController.h"
#import "EqualizerBandsDetailViewController.h"
#import "EqualizerPresetChooserViewController.h"
#import "GroupsAndZonesTableViewCell.h"
#import "SoundModeChooserViewController.h"
#import "SourceChooserViewController.h"
#import "ToneDetailViewController.h"
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

enum
{
    kSectionBalance = 0,
    kSectionSound   = 1,
    kSectionSource  = 2,
    kSectionVolume  = 3
};

@interface ZoneDetailViewController ()
{

}

@end

@implementation ZoneDetailViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];

#if OPENHLX_INSTALLER
    self.mBalanceSlider.minimumValue = static_cast<float>(BalanceModel::kBalanceMin);
    self.mBalanceSlider.maximumValue = static_cast<float>(BalanceModel::kBalanceMax);
#endif

    self.mVolumeSlider.minimumValue = static_cast<float>(VolumeModel::kLevelMin);
    self.mVolumeSlider.maximumValue = static_cast<float>(VolumeModel::kLevelMax);

    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status             lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mApplicationController->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

#if OPENHLX_INSTALLER
    [self refreshZoneBalance];
#endif
    [self refreshZoneMute];
    [self refreshZoneName];
#if OPENHLX_INSTALLER
    [self refreshZoneSoundMode];
#endif
    [self refreshZoneSourceName];
    [self refreshZoneVolume];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone detail view controller from data
 *    in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone detail view controller, if
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
 *    Creates and initializes a zone detail view controller with the
 *    specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone detail view controller, if
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
    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    mZone = nullptr;

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if ([aSender isKindOfClass: [UITableViewCell class]])
    {
        if ([[aSegue identifier] isEqual: @"Source Chooser Segue"])
        {
            SourceChooserViewController *  lSourceChooserViewController = [aSegue destinationViewController];
            Status                         lStatus;


            [lSourceChooserViewController setApplicationController: mApplicationController
                                                         forZone: mZone];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
#if OPENHLX_INSTALLER
        else if ([[aSegue identifier] isEqual: @"Sound Mode Chooser Segue" ])
        {
            SoundModeChooserViewController *  lSoundModeChooserViewController = [aSegue destinationViewController];
            Status                         lStatus;


            [lSoundModeChooserViewController setApplicationController: mApplicationController
                                                            forZone: mZone];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
#endif // OPENHLX_INSTALLER
    }
#if OPENHLX_INSTALLER
    else
    {
        if ([[aSegue identifier] isEqual: @"Equalizer Bands Detail Segue"])
        {
            EqualizerBandsDetailViewController *  lEqualizerBandsDetailViewController = [aSegue destinationViewController];
            Status                                lStatus;


            [lEqualizerBandsDetailViewController setApplicationController: mApplicationController
                                                                forZone: mZone];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else if ([[aSegue identifier] isEqual: @"Equalizer Preset Chooser Segue"])
        {
            EqualizerPresetChooserViewController *  lEqualizerPresetChooserViewController = [aSegue destinationViewController];
            Status                                  lStatus;


            [lEqualizerPresetChooserViewController setApplicationController: mApplicationController
                                                                  forZone: mZone];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else if ([[aSegue identifier] isEqual: @"Tone Detail Segue"])
        {
            ToneDetailViewController *     lToneDetailViewController = [aSegue destinationViewController];
            Status                         lStatus;


            [lToneDetailViewController setApplicationController: mApplicationController
                                                      forZone: mZone];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else if ([[aSegue identifier] isEqual: @"Highpass Crossover Detail Segue"])
        {
            CrossoverDetailViewController *  lCrossoverDetailViewController = [aSegue destinationViewController];
            Status                           lStatus;


            [lCrossoverDetailViewController setApplicationController: mApplicationController
                                                           forZone: mZone
                                                        asHighpass: true];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else if ([[aSegue identifier] isEqual: @"Lowpass Crossover Detail Segue"])
        {
            CrossoverDetailViewController *  lCrossoverDetailViewController = [aSegue destinationViewController];
            Status                           lStatus;


            [lCrossoverDetailViewController setApplicationController: mApplicationController
                                                           forZone: mZone
                                                        asHighpass: false];

            lStatus = mApplicationController->SetDelegate(nullptr);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
    }
#endif // OPENHLX_INSTALLER

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the zone stereophonic channel
 *    balance center "▾" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBalanceCenterButtonAction: (id)aSender
{
#if OPENHLX_INSTALLER
    if (aSender == self.mBalanceCenterButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneSetBalance(lIdentifier, BalanceModel::kBalanceCenter);
        nlREQUIRE(lStatus >= kStatus_Success, done);
    }

done:
#endif // OPENHLX_INSTALLER
   return;
}

/**
 *  @brief
 *    This is the action handler for the zone stereophonic channel
 *    balance adjust left "L" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBalanceLeftButtonAction: (id)aSender
{
#if OPENHLX_INSTALLER
    if (aSender == self.mBalanceDecreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneIncreaseBalanceLeft(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
#endif // OPENHLX_INSTALLER
    return;
}

/**
 *  @brief
 *    This is the action handler for the zone stereophonic channel
 *    balance adjustment slider.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBalanceSliderAction: (id)aSender
{
#if OPENHLX_INSTALLER
    if (aSender == self.mBalanceSlider)
    {
        const BalanceModel::BalanceType lBalance = static_cast<BalanceModel::BalanceType>(self.mBalanceSlider.value);
        ZoneModel::IdentifierType       lIdentifier;
        Status                          lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneSetBalance(lIdentifier, lBalance);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
#endif // OPENHLX_INSTALLER
    return;
}

/**
 *  @brief
 *    This is the action handler for the zone stereophonic channel
 *    balance adjust right "R" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onBalanceRightButtonAction: (id)aSender
{
#if OPENHLX_INSTALLER
    if (aSender == self.mBalanceIncreaseButton)
    {
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneIncreaseBalanceRight(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
#endif // OPENHLX_INSTALLER
    return;
}

- (IBAction) onMonoSwitchAction: (id)aSender
{
    return;
}

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
        ZoneModel::IdentifierType   lIdentifier;
        Status                      lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneSetMute(lIdentifier, lMute);
        nlREQUIRE(lStatus >= kStatus_Success, done);
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
        ZoneModel::IdentifierType   lIdentifier;
        Status                      lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneDecreaseVolume(lIdentifier);
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
        ZoneModel::IdentifierType    lIdentifier;
        Status                       lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneSetVolume(lIdentifier, lVolume);
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
        ZoneModel::IdentifierType  lIdentifier;
        Status                     lStatus;

        lStatus = mZone->GetIdentifier(lIdentifier);
        nlREQUIRE_SUCCESS(lStatus, done);

        lStatus = mApplicationController->ZoneIncreaseVolume(lIdentifier);
        nlEXPECT(lStatus >= 0, done);
    }

 done:
    return;
}

// MARK: Table View Data Source Delegation

// The following table view data source delegates:
//
//   - tableView:numberOfRowsInSection:
//   - tableView:heightForRowAtIndexPath
//   - tableView:heightForHeaderInSection
//   - tableView:heightForFooterInSection
//
// are implemented in such as way (as inspired and discussed at
// https://stackoverflow.com/questions/17761878/hide-sections-of-a-static-tableview)
// such that for the non-installer variant of the app that the balance
// and sound sections are suppressed with numberOfRowsInSection
// returning zero (0) and the latter three returning 0.1f, effectively
// suppressing the display of the sections and/or rows.

/**
 *  @brief
 *    Return whether the specified table view section should be hidden.
 *
 *  @param[in]  aSection  A reference to the immutable table view
 *                        section identifier for which to determine
 *                        whether it should be hidden.
 *
 *  @returns
 *    True if the table view section associated with @a aSection should
 *    be hidden; otherwise, false.
 *
 *  @private
 *
 */
static bool shouldHideSection(const NSInteger &aSection)
{
    bool lRetval = false;


    switch (aSection)
    {

#if !(OPENHLX_INSTALLER)
    case kSectionBalance:
    case kSectionSound:
        lRetval = true;
        break;
#endif // !(OPENHLX_INSTALLER)

    case kSectionSource:
    case kSectionVolume:
    default:
        lRetval = false;
        break;

    }

    return (lRetval);
}

/**
 *  @brief
 *    Return whether the table view section associated with the
 *    specified table view index path should be hidden.
 *
 *  @param[in]  aIndexPath  A pointer to the immutable table view
 *                          index path for which to determine
 *                          whether it should be hidden.
 *
 *  @returns
 *    True if the table view section associated with @a aIndexPath
 *    should be hidden; otherwise, false.
 *
 *  @private
 *
 */
static bool shouldHideSection(const NSIndexPath *aIndexPath)
{
    const NSUInteger lSection = aIndexPath.section;
    const bool lRetval = shouldHideSection(lSection);

    return (lRetval);
}

- (NSInteger)tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    const NSInteger lRetval = (shouldHideSection(aSection) ?
                               0 :
                               [super tableView: aTableView numberOfRowsInSection: aSection]);

    return (lRetval);
}

- (CGFloat)tableView: (UITableView *)aTableView heightForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const CGFloat lRetval = (shouldHideSection(aIndexPath) ?
                             0.01f :
                             [super tableView: aTableView heightForRowAtIndexPath: aIndexPath]);

    return (lRetval);
}

- (CGFloat)tableView: (UITableView *)aTableView heightForHeaderInSection: (NSInteger)aSection
{
    const CGFloat lRetval = (shouldHideSection(aSection) ?
                             0.01f :
                             [super tableView: aTableView heightForHeaderInSection: aSection]);

    return (lRetval);
}

- (CGFloat)tableView: (UITableView *)aTableView heightForFooterInSection: (NSInteger)aSection
{
    CGFloat lRetval;


    switch (aSection)
    {

#if !(OPENHLX_INSTALLER)
    case kSectionBalance:
    case kSectionSound:
        lRetval = 0.1f;
        break;
#endif // !(OPENHLX_INSTALLER)

    case kSectionSource:
    case kSectionVolume:
    default:
        lRetval = [super tableView: aTableView heightForFooterInSection: aSection];
        break;

    }

    return (lRetval);
}

- (void)tableView: (UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)aIndexPath;
{
#if OPENHLX_INSTALLER
    const NSUInteger       lSection = aIndexPath.section;
    const NSUInteger       lRow = aIndexPath.row;
    SoundModel::SoundMode  lSoundMode;
    NSString *             lSegueIdentifier = nullptr;
    Status                 lStatus;


    nlREQUIRE(lSection == 1, done);
    nlREQUIRE(lRow == 0, done);

    lStatus = mZone->GetSoundMode(lSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    switch (lSoundMode)
    {

    case SoundModel::kSoundModeDisabled:
        break;

    case SoundModel::kSoundModeZoneEqualizer:
        lSegueIdentifier = @"Equalizer Bands Detail Segue";
        break;

    case SoundModel::kSoundModePresetEqualizer:
        lSegueIdentifier = @"Equalizer Preset Chooser Segue";
        break;

    case SoundModel::kSoundModeTone:
        lSegueIdentifier = @"Tone Detail Segue";
        break;

    case SoundModel::kSoundModeLowpass:
        lSegueIdentifier = @"Lowpass Crossover Detail Segue";
        break;

    case SoundModel::kSoundModeHighpass:
        lSegueIdentifier = @"Highpass Crossover Detail Segue";
        break;

    default:
        break;
    }

    if (lSegueIdentifier != nullptr)
    {
        [self performSegueWithIdentifier: lSegueIdentifier
                                  sender: self];
    }

 done:
#endif // OPENHLX_INSTALLER
    return;
}

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
 *                                    for which its zone detail is to
 *                                    be observed or mutated.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone
{
    mApplicationController = aApplicationController;
    mZone                = aZone;
}

// MARK: Workers

#if OPENHLX_INSTALLER
- (void) refreshZoneBalance
{
    BalanceModel::BalanceType    lBalance;
    Status                       lStatus;

    lStatus = mZone->GetBalance(lBalance);
    nlREQUIRE_SUCCESS(lStatus, done);

    self.mBalanceSlider.value = static_cast<float>(lBalance);

    if (lBalance == static_cast<const BalanceModel::BalanceType>(self.mBalanceSlider.minimumValue))
    {
        self.mBalanceDecreaseButton.enabled = false;
        self.mBalanceIncreaseButton.enabled = true;
        self.mBalanceCenterButton.enabled = true;
    }
    else if (lBalance == static_cast<const BalanceModel::BalanceType>(self.mBalanceSlider.maximumValue))
    {
        self.mBalanceDecreaseButton.enabled = true;
        self.mBalanceIncreaseButton.enabled = false;
        self.mBalanceCenterButton.enabled = true;
    }
    else if (lBalance == BalanceModel::kBalanceCenter)
    {
        self.mBalanceDecreaseButton.enabled = true;
        self.mBalanceIncreaseButton.enabled = true;
        self.mBalanceCenterButton.enabled = false;
    }
    else
    {
        self.mBalanceDecreaseButton.enabled = true;
        self.mBalanceIncreaseButton.enabled = true;
        self.mBalanceCenterButton.enabled = true;
    }

 done:
    return;
}
#endif // OPENHLX_INSTALLER

- (void) refreshZoneMute
{
    VolumeModel::MuteType        lMute = true;
    Status                       lStatus;

    lStatus = mZone->GetMute(lMute);
    nlREQUIRE_SUCCESS(lStatus, done);

    self.mMuteSwitch.on       = lMute;

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

#if OPENHLX_INSTALLER
- (void) refreshZoneSoundMode
{
    SoundModel::ChannelMode       lChannelMode;
    SoundModel::SoundMode         lSoundMode;
    NSString *                    lSoundModeString;
    UITableViewCellAccessoryType  lAccessoryType;
    Status                        lStatus;

    lStatus = mZone->GetChannelMode(lChannelMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mZone->GetSoundMode(lSoundMode);
    nlREQUIRE_SUCCESS(lStatus, done);

    switch (lSoundMode)
    {

    case SoundModel::kSoundModeDisabled:
        lSoundModeString = @"Disabled";
        lAccessoryType   = UITableViewCellAccessoryDisclosureIndicator;
        break;

    case SoundModel::kSoundModeZoneEqualizer:
        lSoundModeString = @"Custom EQ";
        lAccessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        break;

    case SoundModel::kSoundModePresetEqualizer:
        lSoundModeString = @"Preset EQ";
        lAccessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        break;

    case SoundModel::kSoundModeTone:
        lSoundModeString = @"Bass/Treble";
        lAccessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        break;

    case SoundModel::kSoundModeLowpass:
        lSoundModeString = @"Lowpass Crossover";
        lAccessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        break;

    case SoundModel::kSoundModeHighpass:
        lSoundModeString = @"Highpass Crossover";
        lAccessoryType   = UITableViewCellAccessoryDetailDisclosureButton;
        break;

    default:
        lSoundModeString = @"Unknown";
        lAccessoryType   = UITableViewCellAccessoryNone;
        break;
    }

    self.mMonoAudioSwitch.on          = (lChannelMode == SoundModel::kChannelModeMono);
    self.mSoundModeLabel.text         = lSoundModeString;
    self.mSoundModeCell.accessoryType = lAccessoryType;

 done:
    return;
}
#endif // OPENHLX_INSTALLER

- (void) refreshZoneSourceName
{
    SourceModel::IdentifierType  lSourceIdentifier;
    const SourceModel *          lSource;
    const char *                 lUTF8StringSourceName;
    NSString *                   lNSStringSourceName;
    Status                       lStatus;


    lStatus = mZone->GetSource(lSourceIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = mApplicationController->SourceGet(lSourceIdentifier, lSource);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = lSource->GetName(lUTF8StringSourceName);
    nlREQUIRE_SUCCESS(lStatus, done);

    lNSStringSourceName = [NSString stringWithUTF8String: lUTF8StringSourceName];
    nlREQUIRE_ACTION(lNSStringSourceName != nullptr, done, lStatus = -ENOMEM);

    self.mSourceName.text     = lNSStringSourceName;

 done:
    return;
}

- (void) refreshZoneVolume
{
    VolumeModel::LevelType      lVolume = VolumeModel::kLevelMin;
    Status                       lStatus;

    lStatus = mZone->GetVolume(lVolume);
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

    case StateChange::kStateChangeType_SourceName:
        // Refresh on any zone source name change

        [self refreshZoneSourceName];
        break;

#if OPENHLX_INSTALLER
    case StateChange::kStateChangeType_ZoneBalance:
#endif
    case StateChange::kStateChangeType_ZoneMute:
    case StateChange::kStateChangeType_ZoneName:
#if OPENHLX_INSTALLER
    case StateChange::kStateChangeType_ZoneSoundMode:
#endif
    case StateChange::kStateChangeType_ZoneSource:
    case StateChange::kStateChangeType_ZoneVolume:
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

#if OPENHLX_INSTALLER
            case StateChange::kStateChangeType_ZoneBalance:
                [self refreshZoneBalance];
                break;
#endif

            case StateChange::kStateChangeType_ZoneMute:
                [self refreshZoneMute];
                break;

            case StateChange::kStateChangeType_ZoneName:
                [self refreshZoneName];
                break;

#if OPENHLX_INSTALLER
            case StateChange::kStateChangeType_ZoneSoundMode:
                [self refreshZoneSoundMode];
                break;
#endif

            case StateChange::kStateChangeType_ZoneSource:
                [self refreshZoneSourceName];
                break;

            case StateChange::kStateChangeType_ZoneVolume:
                [self refreshZoneVolume];
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
