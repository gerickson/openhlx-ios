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
 *    This file defines a table view cell for a specific HLX group or
 *    zone source (input).
 *
 */

#ifndef SOURCECHOOSERTABLEVIEWCELL_H
#define SOURCECHOOSERTABLEVIEWCELL_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/HLXController.hpp>
#include <OpenHLX/Client/HLXControllerDelegate.hpp>

#import "HLXClientControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

namespace Model
{

class SourceModel;

};

};

@interface SourceChooserTableViewCell : UITableViewCell
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableHLXClientControllerPointer  mHLXClientController;

    /**
     *  An immutable pointer to the source (input) data model for which
     *  its identifier and name are to be observed.
     *
     */
    const HLX::Model::SourceModel *    mSource;
}

// MARK: Properties

/**
 *  A pointer to the label containing the source (input) name
 *  associated with the source identifier for this table cell.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *  mSourceName;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier;

// MARK: Actions

// MARK: Getters

// MARK: Setters

// MARK: Workers

- (HLX::Common::Status) configureCellForIdentifier: (const HLX::Model::SourceModel::IdentifierType &)aIdentifier
                                    withController: (MutableHLXClientControllerPointer &)aHLXClientController
                                        isSelected: (const bool &)aIsSelected;

@end

#endif // SOURCECHOOSERTABLEVIEWCELL_H
