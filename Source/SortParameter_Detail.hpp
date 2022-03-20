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


#import <Foundation/NSString.h>


namespace Detail
{

// MARK: Type Definitions

enum SortKey
{
    kSortKey_Invalid       = -1,

    kSortKey_Min           = 0,

    kSortKey_Favorite      = kSortKey_Min,
    kSortKey_Identifier,
    kSortKey_LastUsedDate,
    kSortKey_Mute,
    kSortKey_Name,

    kSortKey_Max,
    kSortKey_Count         = kSortKey_Max
};

enum SortOrder
{
    kSortOrder_Invalid     = -1,

    kSortOrder_Min         = false,

    kSortOrder_Descending  = kSortOrder_Min,
    kSortOrder_Ascending   = true,

    kSortOrder_Max,
    kSortOrder_Count       = kSortOrder_Max
};

struct SortParameter
{
    SortKey      mSortKey;
    SortOrder    mSortOrder;
};

// MARK: Function Prototypes

extern bool       IsSortKeyValid(const Detail::SortKey &aSortKey);
extern bool       IsSortOrderValid(const Detail::SortOrder &aSortOrder);
extern bool       IsSortParameterValid(const Detail::SortParameter &aSortParameter);

extern NSString * SortKeyDescription(const Detail::SortKey &aSortKey);
extern NSString * SortOrderDescription(const Detail::SortOrder &aSortOrder);
extern NSString * SortOrderForKeyDescription(const Detail::SortOrder &aSortOrder,
                                             const Detail::SortKey &aSortKey);
extern NSString * SortOrderForKeyDetailDescription(const Detail::SortOrder &aSortOrder,
                                                   const Detail::SortKey &aSortKey);

}; // namespace Detail
