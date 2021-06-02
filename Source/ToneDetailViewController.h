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
 *    This file defines a view controller for observing and mutating
 *    a HLX zone equalizer tone sound mode bass and treble levels.
 *
 */

#ifndef TONEDETAILVIEWCONTROLLER_H
#define TONEDETAILVIEWCONTROLLER_H

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

@interface ToneDetailViewController : UITableViewController <HLXClientControllerDelegate>
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
     *  An immutable pointer to the zone for which its zone equalizer
     *  tone filter detail is to be observed or mutated.
     *
     */
    const HLX::Model::ZoneModel *                 mZone;
}

// MARK: Properties

/**
 *  A pointer to the button for centering the tone bass level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mBassCenterButton;

/**
 *  A pointer to the button for decreasing the tone bass level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mBassDecreaseButton;

/**
 *  A pointer to the slider for adjusting or setting the tone bass level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *          mBassSlider;

/**
 *  A pointer to the button for increasing the tone bass level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mBassIncreaseButton;

/**
 *  A pointer to the text field for the current tone bass level value.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *       mBassLevelTextField;

/**
 *  A pointer to the button for centering the tone treble level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mTrebleCenterButton;

/**
 *  A pointer to the button for decreasing the tone treble level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mTrebleDecreaseButton;

/**
 *  A pointer to the slider for adjusting or setting the tone treble level.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *          mTrebleSlider;

/**
 *  A pointer to the button for increasing the tone treble level.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *          mTrebleIncreaseButton;

/**
 *  A pointer to the text field for the current tone treble level value.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *       mTrebleLevelTextField;

/**
 *  A pointer to the navigation bar item which is to be dynamically
 *  updated to the current zone name.
 *
 */
@property (weak, nonatomic) IBOutlet UINavigationItem *  mZoneName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onBassCenterButtonAction: (id)aSender;
- (IBAction) onBassDecreaseButtonAction: (id)aSender;
- (IBAction) onBassSliderAction: (id)aSender;
- (IBAction) onBassIncreaseButtonAction: (id)aSender;
- (IBAction) onTrebleCenterButtonAction: (id)aSender;
- (IBAction) onTrebleDecreaseButtonAction: (id)aSender;
- (IBAction) onTrebleSliderAction: (id)aSender;
- (IBAction) onTrebleIncreaseButtonAction: (id)aSender;

// MARK: Setters

- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone;

@end

#endif // TONEDETAILVIEWCONTROLLER_H
