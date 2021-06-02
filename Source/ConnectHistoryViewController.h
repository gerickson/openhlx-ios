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
 *    This file defines a view controller for observing and choosing
 *    among previously-successfully connected HLX server network
 *    addresses, names, or URLs.
 *
 */

#import <UIKit/UIKit.h>

@interface ConnectHistoryViewController : UITableViewController

// MARK: Properties

/**
 *  A pointer to the text representation of the user-selected network
 *  address, name, or URL, if any.
 *
 */
@property (strong, nonatomic) NSString *  mSelectedNetworkAddressOrName;

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onDoneBarButtonAction: (id)aSender;

@end

