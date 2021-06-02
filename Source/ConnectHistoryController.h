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
 *    This file defines a data controller for managing
 *    previously-successfully connected HLX server network addresses,
 *    names, or URLs.
 *
 */

#import <Foundation/Foundation.h>


extern NSString * const kConnectHistoryLocationKey;
extern NSString * const kConnectHistoryLastConnectedKey;

@interface ConnectHistoryController : NSObject

// MARK: Properties

// MARK: Type Methods

+ (ConnectHistoryController *)sharedController;

// MARK: Instance Methods

// MARK: Initialization

- (ConnectHistoryController *)init;

// MARK: Introspection

- (NSUInteger) count;
- (bool) empty;
- (NSDictionary *) entryAtIndex: (NSUInteger)aIndex;
- (NSDictionary *) mostRecentEntry;

// MARK: Mutation

- (bool) addOrUpdateEntry: (NSString *)aLocation andDate: (NSDate *)aDate;
- (void) removeEntryAtIndex: (NSUInteger)aIndex;

@end

