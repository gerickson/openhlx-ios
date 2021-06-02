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
 *    This file defines a view controller for observing and choosing
 *    the HLX zone equalizer equalizer preset sound mode preset.
 *
 */

#ifndef EQUALIZERPRESETCHOOSERVIEWCONTROLLER_H
#define EQUALIZERPRESETCHOOSERVIEWCONTROLLER_H

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

@interface EqualizerPresetChooserViewController : UITableViewController <HLXClientControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableHLXClientControllerPointer                 mHLXClientController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<HLXClientControllerDelegate>      mHLXClientControllerDelegate;

    /**
     *  An immutable pointer to the zone for which its zone or preset
     *  equalizer band levels are to be observed or mutated.
     *
     */
    const HLX::Model::ZoneModel *                     mZone;

    /**
     *  The current equalizer preset identifier for the zone preset
     *  equalizer.
     *
     */
    HLX::Model::EqualizerPresetModel::IdentifierType  mCurrentEqualizerPresetIdentifier;
}

// MARK: Properties

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

// MARK: Setters

- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone;

@end

#endif // EQUALIZERPRESETCHOOSERVIEWCONTROLLER_H
