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
 *    This file implements a table view cell for a specific HLX group or
 *    zone, limited to its name, source (input), and volume (including
 *    level and mute state) properties.
 *
 */

#import "GroupsAndZonesTableViewCell.h"

#include <errno.h>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Model/VolumeModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


@interface GroupsAndZonesTableViewCell ()
{

}

@end

@implementation GroupsAndZonesTableViewCell

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a group or zone table view cell from
 *    data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone table view cell, if
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
 *    Creates and initializes a group or zone table view cell with the
 *    specified style and reuse identifier.
 *
 *  @param[in]  aStyle            The style the table view cell should
 *                                be initialized with.
 *  @param[in]  aReuseIdentifier  A pointer to the reuse identifier
 *                                for the table, if reused.
 *
 *  @returns
 *    A pointer to the initialized group or zone table view cell, if
 *    successful; otherwise, null.
 *
 */
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier
{
    if (self = [super   initWithStyle: aStyle
                      reuseIdentifier: aReuseIdentifier])
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
    self.mVolumeSlider.minimumValue = static_cast<float>(VolumeModel::kLevelMin);
    self.mVolumeSlider.maximumValue = static_cast<float>(VolumeModel::kLevelMax);

    return;
}

// MARK: Lifecycle Management

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.mGroupOrZoneName.text = nullptr;
    self.mSourceName.text      = nullptr;
    self.mVolumeSlider.value   = static_cast<float>(VolumeModel::kLevelMin);
    self.mMuteSwitch.on        = true;
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
        Status lStatus;

        if (mIsGroup)
        {
            GroupModel::IdentifierType lIdentifier;

            lStatus = mUnion.mGroup->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->GroupSetMute(lIdentifier, lMute);
            nlEXPECT(lStatus >= 0, done);
        }
        else
        {
            ZoneModel::IdentifierType lIdentifier;

            lStatus = mUnion.mZone->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneSetMute(lIdentifier, lMute);
            nlEXPECT(lStatus >= 0, done);
        }
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
        Status lStatus;

        if (mIsGroup)
        {
            GroupModel::IdentifierType lIdentifier;

            lStatus = mUnion.mGroup->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->GroupDecreaseVolume(lIdentifier);
            nlEXPECT(lStatus >= 0, done);
        }
        else
        {
            ZoneModel::IdentifierType lIdentifier;

            lStatus = mUnion.mZone->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneDecreaseVolume(lIdentifier);
            nlEXPECT(lStatus >= 0, done);
        }
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
        Status lStatus;

        if (mIsGroup)
        {
            GroupModel::IdentifierType lIdentifier;

            lStatus = mUnion.mGroup->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->GroupSetVolume(lIdentifier, lVolume);
            nlEXPECT(lStatus >= 0, done);
        }
        else
        {
            ZoneModel::IdentifierType lIdentifier;

            lStatus = mUnion.mZone->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneSetVolume(lIdentifier, lVolume);
            nlEXPECT(lStatus >= 0, done);
        }
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
        Status lStatus;

        if (mIsGroup)
        {
            GroupModel::IdentifierType lIdentifier;

            lStatus = mUnion.mGroup->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->GroupIncreaseVolume(lIdentifier);
            nlEXPECT(lStatus >= 0, done);
        }
        else
        {
            ZoneModel::IdentifierType lIdentifier;

            lStatus = mUnion.mZone->GetIdentifier(lIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneIncreaseVolume(lIdentifier);
            nlEXPECT(lStatus >= 0, done);
        }
    }

 done:
    return;
}


// MARK: Getters

/**
 *  @brief
 *    Returns whether the cell is associated with a group or zone.
 *
 *  @returns
 *    True if the cell is associated with a group; otherwise, false.
 *
 */
- (bool) isGroup
{
    return (mIsGroup);
}

/**
 *  @brief
 *    Returns a pointer to the group data model associated with the
 *    cell.
 *
 *  This attempts to return a pointer to the group data model
 *  associated with the cell.
 *
 *  @returns
 *    A pointer to the group data model if the cell is associated with
 *    a group; otherwise, null.
 *
 */
- (const HLX::Model::GroupModel *) group
{
    return (mIsGroup ? mUnion.mGroup : nullptr);
}

/**
 *  @brief
 *    Returns a pointer to the zone data model associated with the
 *    cell.
 *
 *  This attempts to return a pointer to the zone data model
 *  associated with the cell.
 *
 *  @returns
 *    A pointer to the zone data model if the cell is associated with
 *    a zone; otherwise, null.
 *
 */
- (const HLX::Model::ZoneModel *) zone
{
    return (mIsGroup ? nullptr : mUnion.mZone);
}

// MARK: Setters

// MARK: Workers

/**
 *  @brief
 *    Configure this table view cell based on the specified group or
 *    zone identifier.
 *
 *  @param[in]  aIdentifier           An immutable reference to the
 *                                    identifier for the group or
 *                                    zone.
 *  @param[in]  aApplicationController  A reference to a shared
 *                                    pointer to a mutable HLX
 *                                    client controller instance
 *                                    to use for this table view
 *                                    cell.
 *  @param[in]  aIsGroup              A Boolean indicating whether
 *                                    or not this table view cell is
 *                                    for a group.
 *
 *  @retval  kStatus_Success  If successful.
 *  @retval  -ERANGE          If the group or zone identifier
 *                            is smaller or larger than supported.
 *  @retval  -ENOMEM          Memory could not be allocated for the
 *                            group, source, or zone names.
 *
 */
- (Status) configureCellForIdentifier: (const IdentifierModel::IdentifierType &)aIdentifier
                       withController: (MutableApplicationControllerPointer &)aApplicationController
		              asGroup: (bool)aIsGroup
{
    const char *                 lUTF8StringGroupOrZoneName;
    NSString *                   lNSStringGroupOrZoneName;
    const char *                 lUTF8StringSourceName;
    NSString *                   lNSStringSourceName;
    SourceModel::IdentifierType  lSourceIdentifier;
    const SourceModel *          lSource;
    VolumeModel::LevelType       lVolume = VolumeModel::kLevelMin;
    VolumeModel::MuteType        lMute = true;
    Status                       lRetval = kStatus_Success;


    mIsGroup = aIsGroup;

    mApplicationController = aApplicationController;

    self.mVolumeSlider.minimumValue = static_cast<float>(VolumeModel::kLevelMin);
    self.mVolumeSlider.maximumValue = static_cast<float>(VolumeModel::kLevelMax);

    if (aIsGroup)
    {
        size_t lSourceCount;

        lRetval = mApplicationController->GroupGet(aIdentifier, mUnion.mGroup);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mGroup->GetName(lUTF8StringGroupOrZoneName);
        nlREQUIRE_SUCCESS(lRetval, done);

        lNSStringGroupOrZoneName = [NSString stringWithUTF8String: lUTF8StringGroupOrZoneName];
        nlREQUIRE_ACTION(lNSStringGroupOrZoneName != nullptr, done, lRetval = -ENOMEM);

        lRetval = mUnion.mGroup->GetSources(lSourceCount);
        nlREQUIRE_SUCCESS(lRetval, done);

        if (lSourceCount == 1)
        {
            lRetval = mUnion.mGroup->GetSources(&lSourceIdentifier, lSourceCount);
            nlREQUIRE_SUCCESS(lRetval, done);

            lRetval = mApplicationController->SourceGet(lSourceIdentifier, lSource);
            nlREQUIRE_SUCCESS(lRetval, done);

            lRetval = lSource->GetName(lUTF8StringSourceName);
            nlREQUIRE_SUCCESS(lRetval, done);

            lNSStringSourceName = [NSString stringWithUTF8String: lUTF8StringSourceName];
            nlREQUIRE_ACTION(lNSStringSourceName != nullptr, done, lRetval = -ENOMEM);
        }
        else if (lSourceCount > 1)
        {
            lNSStringSourceName = NSLocalizedString(@"MultipleGroupSourceSummaryKey", @"");
        }

        lRetval = mUnion.mGroup->GetVolume(lVolume);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mGroup->GetMute(lMute);
        nlREQUIRE_SUCCESS(lRetval, done);
    }
    else
    {
        lRetval = mApplicationController->ZoneGet(aIdentifier, mUnion.mZone);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mZone->GetName(lUTF8StringGroupOrZoneName);
        nlREQUIRE_SUCCESS(lRetval, done);

        lNSStringGroupOrZoneName = [NSString stringWithUTF8String: lUTF8StringGroupOrZoneName];
        nlREQUIRE_ACTION(lNSStringGroupOrZoneName != nullptr, done, lRetval = -ENOMEM);

        lRetval = mUnion.mZone->GetSource(lSourceIdentifier);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mApplicationController->SourceGet(lSourceIdentifier, lSource);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = lSource->GetName(lUTF8StringSourceName);
        nlREQUIRE_SUCCESS(lRetval, done);

        lNSStringSourceName = [NSString stringWithUTF8String: lUTF8StringSourceName];
        nlREQUIRE_ACTION(lNSStringSourceName != nullptr, done, lRetval = -ENOMEM);

        lRetval = mUnion.mZone->GetVolume(lVolume);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mZone->GetMute(lMute);
        nlREQUIRE_SUCCESS(lRetval, done);
    }

    self.mGroupOrZoneName.text = lNSStringGroupOrZoneName;
    self.mSourceName.text      = lNSStringSourceName;
    self.mVolumeSlider.value   = static_cast<float>(lVolume);
    self.mMuteSwitch.on        = lMute;

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
    return (lRetval);
}

@end
