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
 *    This file implements a data controller for managing
 *    previously-successfully connected HLX server network addresses,
 *    names, or URLs.
 *
 */

#import "ConnectHistoryController.h"

#import <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Utilities/Assert.hpp>


using namespace Nuovations;


NSString * const kConnectHistoryLocationKey      = @"Location";
NSString * const kConnectHistoryLastConnectedKey = @"Last Connected";

static NSString * const kConnectHistoryKey       = @"Connect History";

static NSInteger
connectHistorySortFunction(id aFirst, id aSecond, void *aContext)
{
    NSComparisonResult  lRetval;
    NSDate *            lFirstDate = [aFirst objectForKey: kConnectHistoryLastConnectedKey];
    NSDate *            lSecondDate = [aSecond objectForKey: kConnectHistoryLastConnectedKey];

    if ((lFirstDate != nullptr) && (lSecondDate != nullptr))
    {
        lRetval = [lFirstDate compare: lSecondDate];
    }
    else if ((lFirstDate == nullptr) && (lSecondDate == nullptr))
    {
        lRetval = NSOrderedSame;
    }
    else
    {
        lRetval = ((lSecondDate == nullptr) ? NSOrderedAscending : NSOrderedDescending);
    }

 done:
    return (lRetval);
}

@interface ConnectHistoryController ()
{
    NSArray *   mConnectHistory;
}

@end

@implementation ConnectHistoryController

// MARK: Type Methods

/**
 *  @brief
 *    Return a shared instance of the connect history controller.
 *
 *  @returns
 *    A pointer to the shared instance of the connect history
 *    controller, if successful; otherwise null.
 *
 */
+ (ConnectHistoryController *)sharedController
{
    ConnectHistoryController *lRetval = nullptr;

    lRetval = [[self alloc] init];
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

// MARK: Utility

/**
 *  @brief
 *    Determines whether the specified dictionary contains the
 *    indicated network location.
 *
 *  This determines whether the specified dictionary contains the
 *  indicated network location string, based on the
 *  kConnectHistoryLocationKey dictionary key.
 *
 *  @param[in]  aDictionary  A pointer to the dictionary to check.
 *  @param[in]  aLocation    A pointer to the location to check
 *                           for in the dictionary.
 *
 *  @returns
 *    YES if @a aDictionary contains @a aLocation, based on the
 *    kConnectHistoryLocationKey; otherwise, NO.
 *
 */
+ (BOOL) dictionary: (NSDictionary *)aDictionary containsLocation: (NSString *)aLocation
{
    NSString * lLocation;
    BOOL       lRetval = NO;

    lLocation = [aDictionary objectForKey: kConnectHistoryLocationKey];
    nlREQUIRE(lLocation != nullptr, done);

    lRetval = [lLocation isEqual: aLocation];

 done:
    return (lRetval);
}

// MARK: Instance Methods

// MARK: Initialization

/**
 *  @brief
 *    Initializes a connect history object.
 *
 *  @returns
 *    An initialized connect history object.
 *
 */
- (ConnectHistoryController *)init
{
    mConnectHistory = [[NSUserDefaults standardUserDefaults] arrayForKey: kConnectHistoryKey];
    nlEXPECT(mConnectHistory != nullptr, done);

done:
    return (self);
}

// MARK: Introspection

/**
 *  @brief
 *    Return the count of connect history entries.
 *
 *  @returns
 *    The count of connect history entries.
 *
 */
- (NSUInteger) count
{
    NSUInteger lRetval = 0;

    if (mConnectHistory != nullptr)
    {
        lRetval = [mConnectHistory count];
    }

    return (lRetval);
}

/**
 *  @brief
 *    Return whether or not the connect history is empty.
 *
 *  @returns
 *    True if the connect history is empty; otherwise, false.
 *
 */
- (bool) empty
{
    return ([self count] == 0);
}

/**
 *  @brief
 *    Return the connect history entry at the specified index.
 *
 *  This attempts to return the connect history entry at the specified
 *  index, if any.
 *
 *  @param[in]  aIndex  The index of the connect history entry to
 *                      return.
 *
 *  @returns
 *    A pointer to the requested connect history entry, if present;
 *    otherwise, null.
 *
 */
- (NSDictionary *) entryAtIndex: (NSUInteger)aIndex
{
    id lRetval = nullptr;

    if (![self empty])
    {
        lRetval = [mConnectHistory objectAtIndex: aIndex];
    }

 done:
    return (lRetval);
}

/**
 *  @brief
 *    Return the most-recent connect history entry.
 *
 *  This attempts to return the most-recent connect history entry, if
 *  any.
 *
 *  @returns
 *    A pointer to the most-recent connect history entry, if present;
 *    otherwise, null.
 *
 */
- (NSDictionary *) mostRecentEntry
{
    id lRetval = nullptr;

    if (mConnectHistory != nullptr)
    {
        lRetval = [mConnectHistory lastObject];
    }

    return (lRetval);
}

// MARK: Mutation

/**
 *  @brief
 *    Add or upate the specified network location and connection date
 *    tuple to the connection history.
 *
 *  This attempts to add, if not present, or update, if present, based
 *  on @a aLocation, the network location and connection date tuple to
 *  the connection history.
 *
 *  @param[in]  aLocation  A pointer to the string representation of the
 *                         network address, name, or URL to add or update.
 *  @param[in]  aDate      A pointer to the connection date for @a aLocation
 *                         to add or update.
 *
 *  @returns
 *    True if the specified location was successfully added or
 *    updated; otherwise, false.
 *
 */
- (bool) addOrUpdateEntry: (NSString *)aLocation andDate: (NSDate *)aDate
{
    NSDictionary *  lConnectHistoryEntry;
    NSArray *       lConnectHistory;
    bool            lRetval = false;


    if ([self empty])
    {
        // Create a new location entry.

        lConnectHistoryEntry = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 aLocation, kConnectHistoryLocationKey,
                                                 aDate, kConnectHistoryLastConnectedKey,
                                                 nullptr];
        nlREQUIRE(lConnectHistoryEntry != nullptr, done);

        lConnectHistory = [NSArray arrayWithObject: lConnectHistoryEntry];
        nlREQUIRE(lConnectHistory != nullptr, done);
    }
    else
    {
        NSMutableArray *       lMutableConnectHistory;
        NSMutableDictionary *  lMutableConnectHistoryEntry;
        NSUInteger             lIndex;

        // This is not our first and only entry.
        //
        // Update an existing entry or add a new entry. However, first
        // make a mutable copy of the connect history.

        lMutableConnectHistory = [mConnectHistory mutableCopy];
        nlREQUIRE(lMutableConnectHistory != nullptr, done);

        // Next, try to find an existing entry in the connect history
        // matching the location we just connected to.

        lIndex = [lMutableConnectHistory indexOfObjectPassingTest: ^(id aDictionary, NSUInteger aIndex, BOOL *aStop) {
            return [ConnectHistoryController dictionary: aDictionary containsLocation: aLocation];
        }];

        if (lIndex != NSNotFound)
        {
            // We found an existing entry, make a mutable copy, and
            // then update the last connected time.

            lConnectHistoryEntry = [lMutableConnectHistory objectAtIndex: lIndex];
            nlREQUIRE(lConnectHistoryEntry != nullptr, done);

            lMutableConnectHistoryEntry = [lConnectHistoryEntry mutableCopy];
            nlREQUIRE(lMutableConnectHistoryEntry != nullptr, done);

            [lMutableConnectHistoryEntry setObject: aDate
                                            forKey: kConnectHistoryLastConnectedKey];

            // Now update the entry in the connect history array.

            [lMutableConnectHistory replaceObjectAtIndex: lIndex
                                              withObject: lMutableConnectHistoryEntry];
        }
        else
        {
            // We did not find an existing entry, create a new entry.
        
            lConnectHistoryEntry = [NSDictionary dictionaryWithObjectsAndKeys:
                                                     aLocation, kConnectHistoryLocationKey,
                                                     aDate, kConnectHistoryLastConnectedKey,
                                                     nullptr];
            nlREQUIRE(lConnectHistoryEntry != nullptr, done);

            [lMutableConnectHistory addObject: lConnectHistoryEntry];
        }

        // Sort the history by last connected time.

        [lMutableConnectHistory sortUsingFunction: connectHistorySortFunction
                                          context: nullptr];

        lConnectHistory = lMutableConnectHistory;
    }

    [[NSUserDefaults standardUserDefaults] setObject: lConnectHistory
                                              forKey: kConnectHistoryKey];

    if (mConnectHistory == nullptr)
    {
        mConnectHistory = [[NSUserDefaults standardUserDefaults] arrayForKey: kConnectHistoryKey];
    }

    lRetval = true;

 done:
    return (lRetval);
}

/**
 *  @brief
 *    Remove the specified connect history entry.
 *
 *  This attempts to remove, if not present, the connect history entry
 *  at the specified index.
 *
 *  @param[in]  aIndex  The index of the connect history entry to
 *                      remove.
 *
 */
- (void) removeEntryAtIndex: (NSUInteger)aIndex
{
    NSMutableArray *       lMutableConnectHistory;


    // First make a mutable copy of the connect history from which to delete.

    lMutableConnectHistory = [mConnectHistory mutableCopy];
    nlREQUIRE(lMutableConnectHistory != nullptr, done);

    // Delete the requested entry.

    [lMutableConnectHistory removeObjectAtIndex: aIndex];

    // Save the results back.

    [[NSUserDefaults standardUserDefaults] setObject: lMutableConnectHistory
                                              forKey: kConnectHistoryKey];

    mConnectHistory = [[NSUserDefaults standardUserDefaults] arrayForKey: kConnectHistoryKey];

done:
    return;
}

@end
