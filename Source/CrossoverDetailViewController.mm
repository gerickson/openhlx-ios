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
 *    This file implements a view controller for observing and mutating a
 *    HLX zone equalizer high- or lowpass crossover mode filter
 *    frequency.
 *
 */

#import "CrossoverDetailViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/EqualizerPresetsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/CrossoverModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

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

@interface CrossoverDetailViewController ()
{

}

@end

@implementation CrossoverDetailViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    const CrossoverModel *           lCrossoverModel;
    CrossoverModel::FrequencyLimits  lFrequencyLimits;
    Status                           lStatus;


    [super viewDidLoad];
    
    if (mIsHighpass)
    {
        lStatus = mZone->GetHighpassCrossover(lCrossoverModel);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        lStatus = mZone->GetLowpassCrossover(lCrossoverModel);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    
    lStatus = lCrossoverModel->GetFrequencyLimits(lFrequencyLimits);
    nlREQUIRE_SUCCESS(lStatus, done);

    self.mCrossoverFrequencySlider.minimumValue = static_cast<float>(lFrequencyLimits.mMin);
    self.mCrossoverFrequencySlider.maximumValue = static_cast<float>(lFrequencyLimits.mMax);

 done:
    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status             lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mApplicationController->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    [self refreshCrossoverFrequency];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a high- or lowpass crossover filter
 *    detail view controller from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized high- or lowpass crossover filter
 *    detail view controller, if successful; otherwise, null.
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
 *    Creates and initializes a high- or lowpass crossover filter
 *    detail view controller with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized high- or lowpass crossover filter
 *    detail view controller, if successful; otherwise, null.
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

    mZone             = nullptr;
    mCurrentFrequency = 0;
    mIsHighpass       = false;

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the crossover frequency decrease
 *    "-" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onCrossoverFrequencyDecreaseButtonAction: (id)aSender
{
    if (aSender == self.mCrossoverFrequencyDecreaseButton)
    {
        static const CrossoverModel::FrequencyType  kAdjustment = -1;
        
        [self adjustCrossoverFrequency: kAdjustment];
    }
}

/**
 *  @brief
 *    This is the action handler for the crossover frequency
 *    adjustment slider.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onCrossoverFrequencySliderAction: (id)aSender
{
    if (aSender == self.mCrossoverFrequencySlider)
    {
        const CrossoverModel::FrequencyType  lFrequency = static_cast<CrossoverModel::FrequencyType>(self.mCrossoverFrequencySlider.value);

        [self setCrossoverFrequency: lFrequency];
    }
}

/**
 *  @brief
 *    This is the action handler for the crossover frequency increase
 *    "+" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onCrossoverFrequencyIncreaseButtonAction: (id)aSender
{
    if (aSender == self.mCrossoverFrequencyIncreaseButton)
    {
        static const CrossoverModel::FrequencyType  kAdjustment = 1;
        
        [self adjustCrossoverFrequency: kAdjustment];
    }
}

// MARK: Setters

/**
 *  @brief
 *    Set the client controller, zone, and highpass filter indicator
 *    for the view.
 *
 *  @param[in]  aApplicationController  A reference to a shared pointer
 *                                    to a mutable HLX client
 *                                    controller instance to use for
 *                                    this view controller.
 *  @param[in]  aZone                 An immutable pointer to the zone
 *                                    for which its equalizer high-
 *                                    or lowpass crossover filter
 *                                    detail is to be observed or
 *                                    mutated.
 *  @param[in]  aIsHighpass           An immutable reference to a
 *                                    Boolean indicating whether the
 *                                    view is for a high- (true) or
 *                                    lowpass (false) crossover
 *                                    filter.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone
                     asHighpass: (const bool &)aIsHighpass
{
    mApplicationController = aApplicationController;
    mZone                = aZone;
    mIsHighpass          = aIsHighpass;
}

// MARK: Table View Data Source Delegation

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger)aSection
{
    NSString *  lSectionHeaderTitle = nullptr;


    nlREQUIRE(aSection == 0, done);
    
    if (mIsHighpass)
    {
        lSectionHeaderTitle = @"Highpass";
    }
    else
    {
        lSectionHeaderTitle = @"Lowpass";
    }

 done:
    return (lSectionHeaderTitle);
}

// MARK: Workers

- (void) setCrossoverFrequency: (const CrossoverModel::FrequencyType &)aFrequency
{
    ZoneModel::IdentifierType  lIdentifier;
    Status                     lStatus;

    lStatus = mZone->GetIdentifier(lIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    if (mIsHighpass)
    {
        lStatus = mApplicationController->ZoneSetHighpassCrossover(lIdentifier, aFrequency);
        nlREQUIRE(lStatus >= kStatus_Success, done);
    }
    else
    {
        lStatus = mApplicationController->ZoneSetLowpassCrossover(lIdentifier, aFrequency);
        nlREQUIRE(lStatus >= kStatus_Success, done);
    }

 done:
    return;
}

- (void) adjustCrossoverFrequency: (const CrossoverModel::FrequencyType &)aAdjustment
{
    [self setCrossoverFrequency: mCurrentFrequency + aAdjustment];
}

- (void) refreshCrossoverFrequency
{
    CrossoverModel::FrequencyType  lFrequency;
    Status                         lStatus;


    if (mIsHighpass)
    {
        lStatus = mZone->GetHighpassFrequency(lFrequency);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        lStatus = mZone->GetLowpassFrequency(lFrequency);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

    [self refreshCrossoverFrequency: lFrequency];

 done:
    return;
}

- (void) refreshCrossoverFrequency: (const CrossoverModel::FrequencyType &)aFrequency
{
    NSNumberFormatter *                         lFrequencyFormatter = nullptr;
    NSString *                                  lNSStringCrossoverFrequency = nullptr;


    lFrequencyFormatter = [[NSNumberFormatter alloc] init];
    nlREQUIRE(lFrequencyFormatter != nullptr, done);
    
    [lFrequencyFormatter setFormatterBehavior: NSNumberFormatterBehaviorDefault];
    [lFrequencyFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

    lNSStringCrossoverFrequency = [NSString stringWithFormat: @"%@ Hz",
                                   [lFrequencyFormatter stringFromNumber: [NSNumber numberWithUnsignedShort: aFrequency]]];
    nlREQUIRE(lNSStringCrossoverFrequency != nullptr, done);

    self.mCrossoverFrequencySlider.value   = static_cast<float>(aFrequency);
    self.mCrossoverFrequencyTextField.text = lNSStringCrossoverFrequency;
    
    mCurrentFrequency = aFrequency;

    if (mCurrentFrequency == static_cast<const CrossoverModel::FrequencyType> (self.mCrossoverFrequencySlider.minimumValue))
    {
        self.mCrossoverFrequencyDecreaseButton.enabled = false;
        self.mCrossoverFrequencyIncreaseButton.enabled = true;
    }
    else if (mCurrentFrequency == static_cast<const CrossoverModel::FrequencyType> (self.mCrossoverFrequencySlider.maximumValue))
    {
        self.mCrossoverFrequencyDecreaseButton.enabled = true;
        self.mCrossoverFrequencyIncreaseButton.enabled = false;
    }
    else
    {
        self.mCrossoverFrequencyDecreaseButton.enabled = true;
        self.mCrossoverFrequencyIncreaseButton.enabled = true;
    }

 done:
    return;
}

- (void) handleZoneCrossoverChanged: (const StateChange::ZonesCrossoverNotificationBasis &)aSCN
{
    const ZoneModel::IdentifierType             lZoneIdentifier = aSCN.GetIdentifier();
    const CrossoverModel::FrequencyType         lCurrentFrequency = aSCN.GetFrequency();
    ZoneModel::IdentifierType                   lCurrentZoneIdentifier;
    Status                                      lStatus;


    lStatus = mZone->GetIdentifier(lCurrentZoneIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    // If the state change notification is for a different zone than
    // the one this controller is handling equalizer band modification
    // for, ignore it.

    nlEXPECT(lCurrentZoneIdentifier == lZoneIdentifier, done);

    [self refreshCrossoverFrequency: lCurrentFrequency];

 done:
    return;
}

- (void) handleZoneNameChanged: (const StateChange::ZonesNameNotification &)aSCN
{

}

- (void) handleZoneSoundModeChanged: (const StateChange::ZonesSoundModeNotification &)aSCN
{

}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

- (void) controllerStateDidChange: (HLX::Client::Application::ControllerBasis &)aController withNotification: (const StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();


    switch (lType)
    {

    case StateChange::kStateChangeType_ZoneHighpassCrossover:
    case StateChange::kStateChangeType_ZoneLowpassCrossover:
        {
            const StateChange::ZonesCrossoverNotificationBasis &lSCN = static_cast<const StateChange::ZonesCrossoverNotificationBasis &>(aStateChangeNotification);
            
            [self handleZoneCrossoverChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneName:
        {
            const StateChange::ZonesNameNotification &lSCN = static_cast<const StateChange::ZonesNameNotification &>(aStateChangeNotification);
            
            [self handleZoneNameChanged: lSCN];
        }
        break;

    case StateChange::kStateChangeType_ZoneSoundMode:
        {
            const StateChange::ZonesSoundModeNotification &lSCN = static_cast<const StateChange::ZonesSoundModeNotification &>(aStateChangeNotification);

            [self handleZoneSoundModeChanged: lSCN];
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
