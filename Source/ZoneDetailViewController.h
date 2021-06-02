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
 *    This file defines a view controller for observing and mutating a
 *    HLX zone detailed properties such as stereophonic channel
 *    balance (installer-only), equalizer channel and sound mode
 *    (installer-only), source (input), and volume (including level
 *    and mute state).
 *
 */

#ifndef ZONEDETAILVIEWCONTROLLER_H
#define ZONEDETAILVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/HLXController.hpp>
#include <OpenHLX/Client/HLXControllerDelegate.hpp>

#import "HLXClientControllerDelegate.hpp"
#import "HLXClientControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class HLXClientControllerDelegate;

@interface ZoneDetailViewController : UITableViewController <HLXClientControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableHLXClientControllerPointer             mHLXClientController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<HLXClientControllerDelegate>  mHLXClientControllerDelegate;

    /**
     *  An immutable pointer to the zone for which its stereophonic
     *  channel balance (installer-only), equalizer channel and sound
     *  mode (installer-only), source (input), and volume (including
     *  level and mute state) detail are to be observed or mutated.
     *
     */
    const HLX::Model::ZoneModel *                 mZone;
}

// MARK: Properties

/**
 *  A pointer to the slider for centering the zone stereophonic
 *  channel balance (installer-only) level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mBalanceCenterButton;

/**
 *  A pointer to the slider for adjusting to the left the zone
 *  stereophonic channel balance (installer-only) level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mBalanceDecreaseButton;

/**
 *  A pointer to the slider for setting the zone stereophonic
 *  channel balance (installer-only) level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *                mBalanceSlider;

/**
 *  A pointer to the slider for adjusting to the right the zone
 *  stereophonic channel balance (installer-only) level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mBalanceIncreaseButton;

/**
 *  A pointer to the immutable switch that indicates the zone channel
 *  mode.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *                mMonoAudioSwitch;

/**
 *  A pointer to the switch which asserts (enables) or deasserts
 *  (disables) the zone volume mute state.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *                mMuteSwitch;

/**
 *  A pointer to the label containing the zone source (input) name.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *                 mSourceName;

/**
 *  A pointer to the table cell for the zone equalizer sound mode.
 *
 */
@property (weak, nonatomic) IBOutlet UITableViewCell *         mSoundModeCell;

/**
 *  A pointer to the label for the zone equalizer sound mode name.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *                 mSoundModeLabel;

/**
 *  A pointer to the button for decreasing the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mVolumeDecreaseButton;

/**
 *  A pointer to the slider for setting the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *                mVolumeSlider;

/**
 *  A pointer to the button for increasing the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                mVolumeIncreaseButton;

/**
 *  A pointer to the navigation bar item which is to be dynamically
 *  updated to the current zone name.
 *
 */
@property (weak, nonatomic) IBOutlet UINavigationItem *        mZoneName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onBalanceCenterButtonAction: (id)aSender;
- (IBAction) onBalanceLeftButtonAction: (id)aSender;
- (IBAction) onBalanceSliderAction: (id)aSender;
- (IBAction) onBalanceRightButtonAction: (id)aSender;
- (IBAction) onMonoSwitchAction: (id)aSender;
- (IBAction) onMuteSwitchAction: (id)aSender;
- (IBAction) onVolumeDecreaseButtonAction: (id)aSender;
- (IBAction) onVolumeSliderAction: (id)aSender;
- (IBAction) onVolumeIncreaseButtonAction: (id)aSender;

// MARK: Setters

- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone;

@end

#endif // ZONEDETAILVIEWCONTROLLER_H
