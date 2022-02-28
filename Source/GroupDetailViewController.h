/*
 *    Copyright (c) 2019-2022 Grant Erickson
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
 *    HLX group detailed properties such as source (input) and volume
 *    (including level and mute state).
 *
 */

#ifndef GROUPDETAILVIEWCONTROLLER_H
#define GROUPDETAILVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ClientController.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class ApplicationControllerDelegate;

@interface GroupDetailViewController : UITableViewController <ApplicationControllerDelegate>
{
    /**
     *  A pointer to the global app HLX client controller instance.
     *
     */
    ClientController *                                  mClientController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>      mApplicationControllerDelegate;

    /**
     *  An immutable pointer to the group for which its source and volume
     *  detail is to be observed or mutated.
     *
     */
    const HLX::Model::GroupModel *                      mGroup;
}

// MARK: Properties

/**
 *  A pointer to the switch which asserts (enables) or deasserts
 *  (disables) the group favorite preference.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *         mFavoriteSwitch;

/**
 *  A pointer to the label which describes the last used date of
 *  the group.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *          mLastUsedLabel;

/**
 *  A pointer to the switch which asserts (enables) or deasserts
 *  (disables) the group volume mute state.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *         mMuteSwitch;

/**
 *  A pointer to the label containing the group source (input) name.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *          mSourceName;

/**
 *  A pointer to the button for decreasing the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *         mVolumeDecreaseButton;

/**
 *  A pointer to the slider for setting the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *         mVolumeSlider;

/**
 *  A pointer to the button for increasing the volume level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *         mVolumeIncreaseButton;

/**
 *  A pointer to the navigation bar item which is to be dynamically
 *  updated to the current group name.
 *
 */
@property (weak, nonatomic) IBOutlet UINavigationItem * mGroupName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onFavoriteSwitchAction: (id)aSender;
- (IBAction) onMuteSwitchAction: (id)aSender;
- (IBAction) onVolumeDecreaseButtonAction: (id)aSender;
- (IBAction) onVolumeSliderAction: (id)aSender;
- (IBAction) onVolumeIncreaseButtonAction: (id)aSender;

// MARK: Setters

- (void) setClientController: (ClientController &)aClientController
                    forGroup: (const HLX::Model::GroupModel *)aGroup;

@end

#endif // GROUPDETAILVIEWCONTROLLER_H
