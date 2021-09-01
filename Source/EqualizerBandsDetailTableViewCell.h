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
 *    This file defines a table view cell for a specific HLX zone
 *    equalizer or present equalizer band.
 *
 */

#ifndef EQUALIZERBANDSDETAILTABLEVIEWCELL_H
#define EQUALIZERBANDSDETAILTABLEVIEWCELL_H

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

class EqualizerBandModel;
class ZoneModel;

};

};

@interface EqualizerBandsDetailTableViewCell : UITableViewCell
{
    MutableApplicationControllerPointer               mApplicationController;
    bool                                            mIsPreset;
    union
	{
        const HLX::Model::EqualizerPresetModel *    mEqualizerPresetModel;
        const HLX::Model::ZoneModel *               mZoneModel;
    } mUnion;
	HLX::Model::EqualizerBandModel::IdentifierType  mEqualizerBandIdentifier;
}

// MARK: Properties

@property (weak, nonatomic) IBOutlet UIButton *                mBandCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *                mBandDecreaseButton;
@property (weak, nonatomic) IBOutlet UISlider *                mBandSlider;
@property (weak, nonatomic) IBOutlet UIButton *                mBandIncreaseButton;
@property (weak, nonatomic) IBOutlet UITextField *             mBandLevel;
@property (weak, nonatomic) IBOutlet UILabel *                 mBandFrequencyLabel;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier;

// MARK: Actions

- (IBAction) onBandCenterButtonAction: (id)aSender;
- (IBAction) onBandDecreaseButtonAction: (id)aSender;
- (IBAction) onBandSliderAction: (id)aSender;
- (IBAction) onBandIncreaseButtonAction: (id)aSender;

// MARK: Getters

// MARK: Setters

// MARK: Workers

- (HLX::Common::Status) configureCellForIdentifier: (const HLX::Model::IdentifierModel::IdentifierType &)aEqualizerIdentifier andEqualizerBand: (const HLX::Model::EqualizerBandModel::IdentifierType &)aEqualizerBandIdentifier withController: (MutableApplicationControllerPointer &)aApplicationController asPreset: (bool)aIsPreset;

@end

#endif // EQUALIZERBANDSDETAILTABLEVIEWCELL_H
