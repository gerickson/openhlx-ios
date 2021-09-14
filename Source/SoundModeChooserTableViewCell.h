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
 *    This file defines a table view cell for a specific HLX zone
 *    equalizer sound mode.
 *
 */

#ifndef SOUNDMODECHOOSERTABLEVIEWCELL_H
#define SOUNDMODECHOOSERTABLEVIEWCELL_H

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

};

@interface SoundModeChooserTableViewCell : UITableViewCell
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer  mApplicationController;

    /**
     *  The zone equalizer sound mode to be observed for this cell.
     *
     */
    HLX::Model::SoundModel::SoundMode  mSoundMode;
}

// MARK: Properties

/**
 *  A pointer to the label containing the equalizer sound mode name
 *  associated with the equalizer sound mode for this table cell.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *  mSoundModeName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier;

// MARK: Actions

// MARK: Getters

// MARK: Setters

// MARK: Workers

- (HLX::Common::Status) configureCellForSoundMode: (const HLX::Model::SoundModel::SoundMode &)aSoundMode
                                   withController: (MutableApplicationControllerPointer &)aApplicationController
                                       isSelected: (const bool &)aIsSelected;

@end

#endif // SOUNDMODECHOOSERTABLEVIEWCELL_H
