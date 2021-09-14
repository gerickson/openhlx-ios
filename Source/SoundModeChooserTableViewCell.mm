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
 *    This file implements a table view cell for a specific HLX zone
 *    equalizer sound mode.
 *
 */

#import "SoundModeChooserTableViewCell.h"

#include <errno.h>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


@interface SoundModeChooserTableViewCell ()
{

}

@end

@implementation SoundModeChooserTableViewCell

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a zone equalizer sound mode table view
 *    cell from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized zone sound mode table view cell, if
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
 *    Creates and initializes a zone equalizer sound mode table view
 *    cell with the specified style and reuse identifier.
 *
 *  @param[in]  aStyle            The style the table view cell should
 *                                be initialized with.
 *  @param[in]  aReuseIdentifier  A pointer to the reuse identifier
 *                                for the table, if reused.
 *
 *  @returns
 *    A pointer to the initialized zone equalizer sound mode table
 *    view cell, if successful; otherwise, null.
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
    return;
}

// MARK: Lifecycle Management

- (void)prepareForReuse
{
    [super prepareForReuse];

    mSoundMode = SoundModel::kSoundModeDisabled;
}

// MARK: Actions

// MARK: Getters

// MARK: Setters

// MARK: Workers

/**
 *  @brief
 *    Configure this table view cell based on the specified sound
 *    mode.
 *
 *  @param[in]  aSoundMode                  An immutable reference to
 *                                          the current sound mode for
 *                                          the zone equalizer.
 *  @param[in]  aApplicationController        A reference to a shared
 *                                          pointer to a mutable HLX
 *                                          client controller instance
 *                                          to use for this table view
 *                                          cell.
 *  @param[in]  aIsSelected                 A Boolean indicating whether
 *                                          or not this zone equalizer
 *                                          sound mode table view cell
 *                                          is the currently-selected
 *                                          sound mode.
 *
 *  @retval  kStatus_Success  If successful.
 *
 */
- (Status) configureCellForSoundMode: (const HLX::Model::SoundModel::SoundMode &)aSoundMode
                      withController: (MutableApplicationControllerPointer &)aApplicationController
                          isSelected: (const bool &)aIsSelected
{
    NSString *  lSoundModeString;
    Status      lRetval = kStatus_Success;


    mApplicationController = aApplicationController;

    switch (aSoundMode)
    {

    case SoundModel::kSoundModeDisabled:
        lSoundModeString = @"Disabled";
        break;

    case SoundModel::kSoundModeZoneEqualizer:
        lSoundModeString = @"Custom EQ";
        break;

    case SoundModel::kSoundModePresetEqualizer:
        lSoundModeString = @"Preset EQ";
        break;

    case SoundModel::kSoundModeTone:
        lSoundModeString = @"Bass/Treble";
        break;

    case SoundModel::kSoundModeLowpass:
        lSoundModeString = @"Lowpass Crossover";
        break;

    case SoundModel::kSoundModeHighpass:
        lSoundModeString = @"Highpass Crossover";
        break;

    default:
        lSoundModeString = @"Unknown";
        break;
    }

    self.mSoundModeName.text = lSoundModeString;
    self.accessoryType       = (aIsSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

    mSoundMode = aSoundMode;

done:
    return (lRetval);
}

@end
