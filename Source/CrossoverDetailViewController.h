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
 *    This file defines a view controller for observing and mutating a
 *    HLX zone equalizer high- or lowpass crossover mode filter
 *    frequency.
 *
 */

#ifndef CROSSOVERDETAILVIEWCONTROLLER_H
#define CROSSOVERDETAILVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ApplicationControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class ApplicationControllerDelegate;

@interface CrossoverDetailViewController : UITableViewController <ApplicationControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer             mApplicationController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;

    /**
     *  An immutable pointer to the zone for which its equalizer high-
     *  or lowpass crossover filter detail is to be observed or
     *  mutated.
     *
     */
    const HLX::Model::ZoneModel *                 mZone;

    /**
     *  The current crossover frequency for the high- or lowpass
     *  crossover filter.
     *
     */
    HLX::Model::CrossoverModel::FrequencyType     mCurrentFrequency;

    /**
     *  A Boolean indicating whether the view is for a high- (true) or
     *  lowpass (false) crossover filter.
     *
     */
    bool                                          mIsHighpass;
}

// MARK: Properties

/**
 *  A pointer to the button for decreasing the high- or lowpass
 *  crossover filter frequency.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *    mCrossoverFrequencyDecreaseButton;

/**
 *  A pointer to the slider for setting the high- or lowpass crossover
 *  filter frequency.
 *
 */
@property (weak, nonatomic) IBOutlet UISlider *    mCrossoverFrequencySlider;

/**
 *  A pointer to the button for increasing the high- or lowpass
 *  crossover filter frequency.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *    mCrossoverFrequencyIncreaseButton;

/**
 *  A pointer to the text field for the current high- or lowpass
 *  crossover filter frequency value.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField * mCrossoverFrequencyTextField;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onCrossoverFrequencyDecreaseButtonAction: (id)aSender;
- (IBAction) onCrossoverFrequencySliderAction: (id)aSender;
- (IBAction) onCrossoverFrequencyIncreaseButtonAction: (id)aSender;

// MARK: Setters

- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone
                     asHighpass: (const bool &)aIsHighpass;

@end

#endif // CROSSOVERDETAILVIEWCONTROLLER_H
