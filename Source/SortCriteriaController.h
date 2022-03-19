/*
 *    Copyright (c) 2022 Grant Erickson
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
 *    This file defines...
 *
 */


#import <Foundation/Foundation.h>

#import <OpenHLX/Model/IdentifierModel.hpp>

#import "ClientController.hpp"
#import "SortParameter_Detail.hpp"


@interface SortCriteriaController : NSObject

// MARK: Properties

// MARK: Type Methods

// MARK: Instance Methods

// MARK: Initialization

- (SortCriteriaController *)initWithPreferencesKey: (NSString *)aPreferencesKey asGroup: (const bool &)aAsGroup;

// MARK: Introspection

- (NSUInteger) count;
- (bool) hasSortKey: (const Detail::SortKey &)aSortKey;
- (Detail::SortKey) sortKeyAtIndex: (const NSUInteger &)aIndex;
- (Detail::SortOrder) sortOrderAtIndex: (const NSUInteger &)aIndex;
- (Detail::SortOrder) sortOrderForSortKey: (const Detail::SortKey &)aSortKey;
- (NSString *) sortKeyDescriptionAtIndex: (const NSUInteger &)aIndex;
- (NSString *) sortOrderDescriptionAtIndex: (const NSUInteger &)aIndex;
- (NSString *) sortOrderDetailDescriptionAtIndex: (const NSUInteger &)aIndex;

// MARK: Getters

// MARK: Setters

- (void) setClientController: (ClientController &)aClientController;

// MARK: Mutation

- (HLX::Common::Status) removeSortCriteriaAtIndex: (const NSUInteger &)aIndex;

// MARK: Workers

- (NSInteger) mapIdentifierToIndex: (const HLX::Model::IdentifierModel::IdentifierType &)aIdentifier;
- (HLX::Model::IdentifierModel::IdentifierType) mapIndexToIdentifier: (const NSUInteger &)aIndex;
- (HLX::Common::Status) sortIdentifiers;

@end

