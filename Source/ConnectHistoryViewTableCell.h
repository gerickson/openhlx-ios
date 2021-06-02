/*
*    Copyright (c) 2020-2021 Grant Erickson
*    All rights reserved.
*
*    This document is the property of Grant Erickson. It is
*    considered confidential and proprietary information.
*
*    This document may not be reproduced or transmitted in any form,
*    in whole or in part, without the express written permission of
*    Grant Erickson.
 *
 */

/**
 *  @file
 *    This file defines a table view cell for a
 *    previously-successfully connected HLX server network address,
 *    name, or URL and the time and date is was last connected to.
 *
 */

#import <UIKit/UIKit.h>

#include <OpenHLX/Common/Errors.hpp>


@interface ConnectHistoryViewTableCell : UITableViewCell
{

}

// MARK: Properties

/**
 *  The network address, name, or URL for the connect history entry.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel * mNetworkAddressOrNameLabel;

/**
 *  The last connected date and time for the connect history entry
 *  location.
 *
 */
@property (weak, nonatomic) IBOutlet UILabel * mLastConnectedDateLabel;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithStyle: (UITableViewCellStyle)aStyle reuseIdentifier: (NSString *)aReuseIdentifier;

// MARK: Workers

- (HLX::Common::Status) configureCell: (NSDictionary *)aDictionary;

@end
