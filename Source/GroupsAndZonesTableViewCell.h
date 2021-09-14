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
 *    This file defines a table view cell for a specific HLX group or
 *    zone, limited to its name, source (input), and volume (including
 *    level and mute state) properties.
 *
 */

#ifndef GROUPSANDZONESTABLEVIEWCELL_H
#define GROUPSANDZONESTABLEVIEWCELL_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

namespace Model
{

class GroupModel;
class ZoneModel;

};

};

@interface GroupsAndZonesTableViewCell : UITableViewCell
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer  mApplicationController;

    /**
     *  A Boolean indicating whether the table view cell is for a
     *  group or zone.
     *
     */
    bool                               mIsGroup;

    /**
     *  An immutable pointer to the group or zone, depending on the
     *  state of @a mIsGroup.
     *
     */
    union
    {
        /**
         *  An immutable pointer to the group, if @a mIsGroup is true.
         *
         */
        const HLX::Model::GroupModel * mGroup;

        /**
         *  An immutable pointer to the zone, if @a mIsGroup is false.
         *
         */
        const HLX::Model::ZoneModel *  mZone;
    } mUnion;
}

// MARK: Properties

/**
 *  A pointer to the switch which asserts (enables) or deasserts
 *  (disables) the group or zone volume mute state.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *                mMuteSwitch;

/**
 *  A pointer to the label containing the group or zone source (input) name.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *                 mSourceName;

/**
 *  A pointer to the button for decreasing the group or zone volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mVolumeDecreaseButton;

/**
 *  A pointer to the slider for setting the group or zone volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *                mVolumeSlider;

/**
 *  A pointer to the button for increasing the group or zone volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mVolumeIncreaseButton;

/**
 *  A pointer to the label containing the group or zone name.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *                 mGroupOrZoneName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier;

// MARK: Actions

- (IBAction) onMuteSwitchAction: (id)aSender;
- (IBAction) onVolumeDecreaseButtonAction: (id)aSender;
- (IBAction) onVolumeSliderAction: (id)aSender;
- (IBAction) onVolumeIncreaseButtonAction: (id)aSender;

// MARK: Getters

- (bool) isGroup;
- (const HLX::Model::GroupModel *) group;
- (const HLX::Model::ZoneModel *) zone;

// MARK: Setters

// MARK: Workers

- (HLX::Common::Status) configureCellForIdentifier: (const HLX::Model::IdentifierModel::IdentifierType &)aIdentifier
                                    withController: (MutableApplicationControllerPointer &)aApplicationController
                                           asGroup: (bool)aIsGroup;

@end

#endif // GROUPSANDZONESTABLEVIEWCELL_H
