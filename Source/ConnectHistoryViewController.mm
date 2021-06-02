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
 *    This file implements a view controller for observing and choosing
 *    among previously-successfully connected HLX server network
 *    addresses, names, or URLs.
 *
 */

#import "ConnectHistoryViewController.h"

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ConnectHistoryController.h"
#import "ConnectHistoryViewTableCell.h"

using namespace HLX::Common;
using namespace Nuovations;

@interface ConnectHistoryViewController ()

@end

@implementation ConnectHistoryViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    UIBarButtonItem *  lDoneBarButtonItem;

    // Call the parent delegate.

    [super viewDidLoad];

    // Create and assign a "Done" button bar item to allow the user to
    // back out of the connect history view without having made a
    // selection.

    lDoneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                       target: self
                                                                       action: @selector(onDoneBarButtonAction:)];
    nlREQUIRE(lDoneBarButtonItem != nullptr, done);

    self.navigationItem.rightBarButtonItem = lDoneBarButtonItem;

done:
    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    [super viewWillAppear: aAnimated];
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a connect history view controller from
 *    data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized connect history view controller, if
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
 *    Creates and initializes a connect history view controller with
 *    the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized connect history view controller, if
 *    successful; otherwise, null.
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
    self.mSelectedNetworkAddressOrName = nullptr;

    return;
}

- (void) prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if ([[aSegue identifier] isEqual: @"OnExitConnectHistory"])
    {
        if ([aSender isKindOfClass: [ConnectHistoryViewTableCell class]])
        {
            ConnectHistoryViewTableCell *  lConnectHistoryViewTableCell = static_cast<ConnectHistoryViewTableCell *>(aSender);

            self.mSelectedNetworkAddressOrName = lConnectHistoryViewTableCell.mNetworkAddressOrNameLabel.text;
        }
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the "Done" navigation bar button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onDoneBarButtonAction: (id)aSender
{
    if (aSender == self.navigationItem.rightBarButtonItem)
    {
        [self performSegueWithIdentifier: @"OnCancelConnectHistory"
                                  sender: self];
    }

    return;
}

- (IBAction) prepareForUnwind: (UIStoryboardSegue *)aSegue
{
    return;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView:(UITableView *)aTableView
{
    static const NSInteger kTableSections = 1;

    return (kTableSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    ConnectHistoryController *  lSharedConnectHistoryController;
    NSInteger                   lRetval = 0;


    nlREQUIRE(aSection == 0, done);

    // Attempt to retrieve the shared connect history controller.

    lSharedConnectHistoryController = [ConnectHistoryController sharedController];
    nlREQUIRE(lSharedConnectHistoryController != nullptr, done);

    lRetval = [lSharedConnectHistoryController count];

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger               lSection = aIndexPath.section;
    NSString *                     lCellIdentifier = @"Connect History View Cell";
    ConnectHistoryViewTableCell *  lRetval = nullptr;


    nlREQUIRE(lSection == 0, done);

    lRetval = [aTableView dequeueReusableCellWithIdentifier: lCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableCell: lRetval
          forIndexPath: aIndexPath];

 done:
    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView commitEditingStyle: (UITableViewCellEditingStyle)aEditingStyle forRowAtIndexPath:(NSIndexPath *)aIndexPath
{
    const NSUInteger               lSection = aIndexPath.section;
    const NSUInteger               lRow = aIndexPath.row;


    nlREQUIRE(lSection == 0, done);

    if (aEditingStyle == UITableViewCellEditingStyleDelete)
    {
        ConnectHistoryController *  lSharedConnectHistoryController;


        // Attempt to retrieve the shared connect history controller.

        lSharedConnectHistoryController = [ConnectHistoryController sharedController];
        nlREQUIRE(lSharedConnectHistoryController != nullptr, done);

        // Remove the entry associated with the row.

        [lSharedConnectHistoryController removeEntryAtIndex: lRow];

        // Refresh the table data.

        [self.tableView reloadData];
    }

done:
    return;
}

// MARK: Workers

- (void) configureReusableCell: (ConnectHistoryViewTableCell *)aCell forIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger            lSection = aIndexPath.section;
    const NSUInteger            lRow = aIndexPath.row;
    ConnectHistoryController *  lSharedConnectHistoryController;
    NSDictionary *              lConnectHistoryEntry;
    Status                      lStatus;


    nlREQUIRE(lSection == 0, done);

    // Attempt to retrieve the shared connect history controller.

    lSharedConnectHistoryController = [ConnectHistoryController sharedController];
    nlREQUIRE(lSharedConnectHistoryController != nullptr, done);

    lConnectHistoryEntry = [lSharedConnectHistoryController entryAtIndex: lRow];
    nlREQUIRE(lConnectHistoryEntry != nullptr, done);

    lStatus = [aCell configureCell: lConnectHistoryEntry];
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

@end
