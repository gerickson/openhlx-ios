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
 *    equalizer or present equalizer band.
 *
 */

#import "EqualizerBandsDetailTableViewCell.h"

#include <errno.h>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


@interface EqualizerBandsDetailTableViewCell ()
{

}

@end

@implementation EqualizerBandsDetailTableViewCell

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [self initCommon];
    }

    return (self);
}

- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier:(NSString *)aReuseIdentifier
{
    if (self = [super initWithStyle: aStyle
                      reuseIdentifier: aReuseIdentifier])
    {
        [self initCommon];
    }

    return (self);
}

- (void) initCommon
{
    self.mBandSlider.minimumValue = static_cast<float>(EqualizerBandModel::kLevelMin);
    self.mBandSlider.maximumValue = static_cast<float>(EqualizerBandModel::kLevelMax);

    return;
}

// MARK: Lifecycle Management

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.mBandFrequencyLabel.text = nullptr;
    self.mBandLevel.text          = nullptr;
    self.mBandSlider.value        = static_cast<float>(EqualizerBandModel::kLevelFlat);
}

// MARK: Actions

- (IBAction) onBandCenterButtonAction: (id)aSender
{
    if (aSender == self.mBandCenterButton)
    {
        Status  lStatus;


        if (mIsPreset)
        {
            EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier;
            

            lStatus = mUnion.mEqualizerPresetModel->GetIdentifier(lEqualizerPresetIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->EqualizerPresetSetBand(lEqualizerPresetIdentifier, mEqualizerBandIdentifier, EqualizerBandModel::kLevelFlat);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else
        {
            ZoneModel::IdentifierType  lZoneIdentifier;


            lStatus = mUnion.mZoneModel->GetIdentifier(lZoneIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneSetEqualizerBand(lZoneIdentifier, mEqualizerBandIdentifier, EqualizerBandModel::kLevelFlat);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
    }

 done:
    return;
}

- (IBAction) onBandDecreaseButtonAction: (id)aSender
{
    if (aSender == self.mBandDecreaseButton)
    {
        Status  lStatus;

        
        if (mIsPreset)
        {
            EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier;
            

            lStatus = mUnion.mEqualizerPresetModel->GetIdentifier(lEqualizerPresetIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->EqualizerPresetDecreaseBand(lEqualizerPresetIdentifier, mEqualizerBandIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else
        {
            ZoneModel::IdentifierType  lZoneIdentifier;


            lStatus = mUnion.mZoneModel->GetIdentifier(lZoneIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneDecreaseEqualizerBand(lZoneIdentifier, mEqualizerBandIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
    }

 done:
    return;
}

- (IBAction) onBandSliderAction: (id)aSender
{
    if (aSender == self.mBandSlider)
    {
        const EqualizerBandModel::LevelType  lLevel = static_cast<EqualizerBandModel::LevelType>(self.mBandSlider.value);
        Status                               lStatus;

        if (mIsPreset)
        {
            EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier;
            

            lStatus = mUnion.mEqualizerPresetModel->GetIdentifier(lEqualizerPresetIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->EqualizerPresetSetBand(lEqualizerPresetIdentifier, mEqualizerBandIdentifier, lLevel);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else
        {
            ZoneModel::IdentifierType            lZoneIdentifier;


            lStatus = mUnion.mZoneModel->GetIdentifier(lZoneIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneSetEqualizerBand(lZoneIdentifier, mEqualizerBandIdentifier, lLevel);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
    }

 done:
    return;
}

- (IBAction) onBandIncreaseButtonAction: (id)aSender
{
    if (aSender == self.mBandIncreaseButton)
    {
        Status lStatus;

        if (mIsPreset)
        {
            EqualizerPresetModel::IdentifierType  lEqualizerPresetIdentifier;
            

            lStatus = mUnion.mEqualizerPresetModel->GetIdentifier(lEqualizerPresetIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->EqualizerPresetIncreaseBand(lEqualizerPresetIdentifier, mEqualizerBandIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
        else
        {
            ZoneModel::IdentifierType  lZoneIdentifier;


            lStatus = mUnion.mZoneModel->GetIdentifier(lZoneIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);

            lStatus = mApplicationController->ZoneIncreaseEqualizerBand(lZoneIdentifier, mEqualizerBandIdentifier);
            nlREQUIRE_SUCCESS(lStatus, done);
        }
    }

 done:
    return;
}

// MARK: Getters

// MARK: Setters

// MARK: Workers

- (Status) configureCellForIdentifier: (const IdentifierModel::IdentifierType &)aEqualizerIdentifier andEqualizerBand: (const EqualizerBandModel::IdentifierType &)aEqualizerBandIdentifier withController: (MutableApplicationControllerPointer &)aApplicationController asPreset: (bool)aIsPreset;
{
    const EqualizerBandModel *         lEqualizerBandModel = nullptr;
    NSNumberFormatter *                lFrequencyFormatter = nullptr;
    NSString *                         lNSStringBandFrequency = nullptr;
    NSString *                         lNSStringBandLevel = nullptr;
    EqualizerBandModel::FrequencyType  lFrequency = 0;
    EqualizerBandModel::LevelType      lLevel = EqualizerBandModel::kLevelFlat;
    Status                             lRetval = kStatus_Success;


    mIsPreset = aIsPreset;
    mApplicationController = aApplicationController;

    self.mBandSlider.minimumValue = static_cast<float>(EqualizerBandModel::kLevelMin);
    self.mBandSlider.maximumValue = static_cast<float>(EqualizerBandModel::kLevelMax);

    if (aIsPreset)
    {
        lRetval = mApplicationController->EqualizerPresetGet(aEqualizerIdentifier, mUnion.mEqualizerPresetModel);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mEqualizerPresetModel->GetEqualizerBand(aEqualizerBandIdentifier, lEqualizerBandModel);
        nlREQUIRE_SUCCESS(lRetval, done);
        nlREQUIRE(lEqualizerBandModel != nullptr, done);
    }
    else
    {
        lRetval = mApplicationController->ZoneGet(aEqualizerIdentifier, mUnion.mZoneModel);
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = mUnion.mZoneModel->GetEqualizerBand(aEqualizerBandIdentifier, lEqualizerBandModel);
        nlREQUIRE_SUCCESS(lRetval, done);
        nlREQUIRE(lEqualizerBandModel != nullptr, done);
    }
    
    mEqualizerBandIdentifier = aEqualizerBandIdentifier;

    lRetval = lEqualizerBandModel->GetFrequency(lFrequency);
    nlREQUIRE_SUCCESS(lRetval, done);
    
    lFrequencyFormatter = [[NSNumberFormatter alloc] init];
    nlREQUIRE(lFrequencyFormatter != nullptr, done);
    
    [lFrequencyFormatter setFormatterBehavior: NSNumberFormatterBehaviorDefault];
    [lFrequencyFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

    lNSStringBandFrequency = [NSString stringWithFormat: @"%@ Hz",
                              [lFrequencyFormatter stringFromNumber: [NSNumber numberWithUnsignedShort: lFrequency]]];
    nlREQUIRE(lNSStringBandFrequency != nullptr, done);

    lRetval = lEqualizerBandModel->GetLevel(lLevel);
    nlREQUIRE_SUCCESS(lRetval, done);

    lNSStringBandLevel = [NSString stringWithFormat: @"%d dB", lLevel];
    nlREQUIRE(lNSStringBandLevel != nullptr, done);

    self.mBandFrequencyLabel.text = lNSStringBandFrequency;
    self.mBandLevel.text          = lNSStringBandLevel;
    self.mBandSlider.value        = static_cast<float>(lLevel);

    if (lLevel == EqualizerBandModel::kLevelMin)
    {
        self.mBandDecreaseButton.enabled = false;
        self.mBandIncreaseButton.enabled = true;
        self.mBandCenterButton.enabled = true;
    }
    else if (lLevel == EqualizerBandModel::kLevelMax)
    {
        self.mBandDecreaseButton.enabled = true;
        self.mBandIncreaseButton.enabled = false;
        self.mBandCenterButton.enabled = true;
    }
    else if (lLevel == EqualizerBandModel::kLevelFlat)
    {
        self.mBandDecreaseButton.enabled = true;
        self.mBandIncreaseButton.enabled = true;
        self.mBandCenterButton.enabled = false;
    }
    else
    {
        self.mBandDecreaseButton.enabled = true;
        self.mBandIncreaseButton.enabled = true;
        self.mBandCenterButton.enabled = true;
    }

 done:
    return (lRetval);
}

@end
