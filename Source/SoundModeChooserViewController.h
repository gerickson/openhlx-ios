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
 *    a HLX zone equalizer sound mode.
 *
 */

#ifndef SOUNDMODECHOOSERVIEWCONTROLLER_H
#define SOUNDMODECHOOSERVIEWCONTROLLER_H

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

@interface SoundModeChooserViewController : UITableViewController <ApplicationControllerDelegate>
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
     *  An immutable pointer to the zone for which its zone equalizer
     *  sound mode is to be observed or mutated.
     *
     */
    const HLX::Model::ZoneModel *                 mZone;

    /**
     *  The current zone equalizer sound mode.
     *
     */
    HLX::Model::SoundModel::SoundMode             mCurrentSoundMode;
}

// MARK: Properties

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

// MARK: Setters

- (void) setApplicationController: (MutableApplicationControllerPointer &)aApplicationController
                        forZone: (const HLX::Model::ZoneModel *)aZone;

@end

#endif // SOUNDMODECHOOSERVIEWCONTROLLER_H
