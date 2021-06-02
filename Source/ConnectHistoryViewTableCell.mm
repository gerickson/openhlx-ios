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
 *    This file implements a table view cell for a
 *    previously-successfully connected HLX server network address,
 *    name, or URL and the time and date is was last connected to.
 *
 */

#import "ConnectHistoryViewTableCell.h"

#include <errno.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ConnectHistoryController.h"


using namespace HLX::Common;
using namespace Nuovations;


@interface ConnectHistoryViewTableCell ()
{

}

@end

@implementation ConnectHistoryViewTableCell

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a connect history table view cell from
 *    data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized connect history table view cell, if
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
 *    Creates and initializes a connect history table view cell with
 *    the specified style and reuse identifier.
 *
 *  @param[in]  aStyle            The style the table view cell should
 *                                be initialized with.
 *  @param[in]  aReuseIdentifier  A pointer to the reuse identifier
 *                                for the table, if reused.
 *
 *  @returns
 *    A pointer to the initialized connect history table view cell, if
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

    self.mNetworkAddressOrNameLabel.text = nullptr;
    self.mLastConnectedDateLabel.text    = nullptr;
}

// MARK: Actions

// MARK: Workers

/**
 *  @brief
 *    Configure this table view cell based on the contents of the
 *    specified connect history dictionary entry.
 *
 *  @param[in]  aDictionary  A pointer to the connect history
 *                           dictionary entry to configure the table
 *                           view cell with. It is expected to contain
 *                           entries for the @a
 *                           kConnectHistoryLocationKey and @a
 *                           kConnectHistoryLastConnectedKey keys.
 *
 *  @retval  kStatus_Success  If successful.
 *  @retval  -EINVAL          If @a aDictionary was null.
 *  @retval  -ENOENT          A value for either of the @a
 *                            kConnectHistoryLocationKey or @a
 *                            kConnectHistoryLastConnectedKey keys
 *                            could not be found.
 *  @retval  -ENOMEM          Memory could not be allocated for the
 *                            date formatter or for the date-formatted
 *                            string for the @a
 *                            kConnectHistoryLastConnectedKey value.
 *
 */
- (Status) configureCell: (NSDictionary *)aDictionary
{
    NSString *                     lConnectHistoryEntryLocation;
    NSDate *                       lConnectHistoryEntryDate;
    NSString *                     lConnectHistoryEntryLastConnectedDateString;
    NSDateFormatter *              lFormatter;
    Status                         lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aDictionary != nullptr, done, lRetval = -EINVAL);

    lFormatter = [[NSDateFormatter alloc] init];
    nlREQUIRE_ACTION(lFormatter != nullptr, done, lRetval = -ENOMEM);

    lConnectHistoryEntryLocation = [aDictionary objectForKey: kConnectHistoryLocationKey];
    nlEXPECT_ACTION(lConnectHistoryEntryLocation != nullptr, done, lRetval = -ENOENT);

    lConnectHistoryEntryDate = [aDictionary objectForKey: kConnectHistoryLastConnectedKey];
    nlEXPECT_ACTION(lConnectHistoryEntryDate != nullptr, done, lRetval = -ENOENT);

    lFormatter.doesRelativeDateFormatting = YES;
    lFormatter.dateStyle                  = NSDateFormatterShortStyle;
    lFormatter.timeStyle                  = NSDateFormatterShortStyle;

    lConnectHistoryEntryLastConnectedDateString = [lFormatter stringFromDate: lConnectHistoryEntryDate];
    nlREQUIRE_ACTION(lConnectHistoryEntryLastConnectedDateString != nullptr, done, lRetval = -ENOMEM);

    self.mNetworkAddressOrNameLabel.text = lConnectHistoryEntryLocation;
    self.mLastConnectedDateLabel.text    = lConnectHistoryEntryLastConnectedDateString;

done:
    return (lRetval);
}

@end
