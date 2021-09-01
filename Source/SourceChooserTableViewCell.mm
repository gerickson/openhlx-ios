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
 *    This file implements a table view cell for a specific HLX group or
 *    zone source (input).
 *
 */

#import "SourceChooserTableViewCell.h"

#include <errno.h>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


@interface SourceChooserTableViewCell ()
{

}

@end

@implementation SourceChooserTableViewCell

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a source (input) table view cell from
 *    data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized source (input) table view cell, if
 *    successful; otherwise, null.
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
 *    Creates and initializes a source (input) table view cell with
 *    the specified style and reuse identifier.
 *
 *  @param[in]  aStyle            The style the table view cell should
 *                                be initialized with.
 *  @param[in]  aReuseIdentifier  A pointer to the reuse identifier
 *                                for the table, if reused.
 *
 *  @returns
 *    A pointer to the initialized source (input) table view cell, if
 *    successful; otherwise, null.
 *
 */
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier
{
    if (self = [super   initWithStyle: aStyle
                      reuseIdentifier: aReuseIdentifier])
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
    return;
}

// MARK: Lifecycle Management

- (void)prepareForReuse
{
    [super prepareForReuse];

    mSource = nullptr;
}

// MARK: Actions

// MARK: Getters

// MARK: Setters

// MARK: Workers

/**
 *  @brief
 *    Configure this table view cell based on the contents of the
 *    specified source identifier.
 *
 *  @param[in]  aSourceIdentifier           An immutable reference
 *                                          to the identifier for the
 *                                          source.
 *  @param[in]  aApplicationController        A reference to a shared
 *                                          pointer to a mutable HLX
 *                                          client controller instance
 *                                          to use for this table view
 *                                          cell.
 *  @param[in]  aIsSelected                 A Boolean indicating whether
 *                                          or not this source table
 *                                          view cell is the
 *                                          currently-selected source.
 *
 *  @retval  kStatus_Success  If successful.
 *  @retval  -ERANGE          If the source (input) identifier
 *                            is smaller or larger than supported.
 *  @retval  -ENOMEM          Memory could not be allocated for the
 *                            source (input) name.
 *
 */
- (Status) configureCellForIdentifier: (const HLX::Model::SourceModel::IdentifierType &)aSourceIdentifier
                       withController: (MutableApplicationControllerPointer &)aApplicationController
                           isSelected: (const bool &)aIsSelected
{
    const char *                 lUTF8StringSourceName;
    NSString *                   lNSStringSourceName;
    Status                       lRetval = kStatus_Success;


    mApplicationController = aApplicationController;

    // Get the source data model from the identifier.

    lRetval = mApplicationController->SourceGet(aSourceIdentifier, mSource);
    nlREQUIRE_SUCCESS(lRetval, done);

    // Get the source name from the model.

    lRetval = mSource->GetName(lUTF8StringSourceName);
    nlREQUIRE_SUCCESS(lRetval, done);

    lNSStringSourceName = [NSString stringWithUTF8String: lUTF8StringSourceName];
    nlREQUIRE_ACTION(lNSStringSourceName != nullptr, done, lRetval = -ENOMEM);

    self.mSourceName.text = lNSStringSourceName;
    self.accessoryType    = (aIsSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

done:
    return (lRetval);
}

@end
