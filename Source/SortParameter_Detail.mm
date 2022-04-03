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
 *    This file implements...
 *
 */

#import "SortParameter_Detail.hpp"

#import <Foundation/NSBundle.h>

#import <OpenHLX/Utilities/Assert.hpp>


namespace Detail
{

// MARK: Global Variables

// MARK: Localization Table Names

static NSString * const kSortCriteriaTableName               = @"SortCriteria";

bool
IsSortKeyValid(const SortKey &aSortKey)
{
    const bool lRetval = ((aSortKey   >= SortKey::kSortKey_Min) &&
                          (aSortKey   <  SortKey::kSortKey_Max));

    return (lRetval);
}

bool
IsSortOrderValid(const SortOrder &aSortOrder)
{
    const bool lRetval = ((aSortOrder   >= SortOrder::kSortOrder_Min) &&
                          (aSortOrder   <  SortOrder::kSortOrder_Max));

    return (lRetval);
}

bool
IsSortParameterValid(const SortParameter &aSortParameter)
{
    const bool lRetval = (IsSortKeyValid(aSortParameter.mSortKey) &&
                          IsSortOrderValid(aSortParameter.mSortOrder));

    return (lRetval);
}

NSString *
SortKeyDescription(const Detail::SortKey &aSortKey)
{
    NSString * lRetval = nullptr;


    nlREQUIRE(IsSortKeyValid(aSortKey), done);

    switch (aSortKey)
    {

    case Detail::kSortKey_Favorite:
        lRetval = NSLocalizedStringFromTable(@"FavoriteSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::kSortKey_Identifier:
        lRetval = NSLocalizedStringFromTable(@"IdentifierSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::kSortKey_LastUsedDate:
        lRetval = NSLocalizedStringFromTable(@"LastUsedDateSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::kSortKey_Mute:
        lRetval = NSLocalizedStringFromTable(@"MuteSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::kSortKey_Name:
        lRetval = NSLocalizedStringFromTable(@"NameSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::kSortKey_UseCount:
        lRetval = NSLocalizedStringFromTable(@"UseCountSortKeyCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    default:
        break;

    }

 done:
    return (lRetval);
}

NSString *
SortOrderDescription(const Detail::SortOrder &aSortOrder)
{
    NSString * lRetval = nullptr;


    nlREQUIRE(IsSortOrderValid(aSortOrder), done);

    switch (aSortOrder)
    {

    case Detail::SortOrder::kSortOrder_Ascending:
        lRetval = NSLocalizedStringFromTable(@"AscendingSortOrderCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    case Detail::SortOrder::kSortOrder_Descending:
        lRetval = NSLocalizedStringFromTable(@"DescendingSortOrderCriteriaKey",
                                             Detail::kSortCriteriaTableName, @"");
        break;

    default:
        break;

    }

 done:
    return (lRetval);
}

NSString *
SortOrderForKeyDescription(const Detail::SortOrder &aSortOrder,
                           const Detail::SortKey &aSortKey)
{
    static constexpr size_t        kAscendingIndex = static_cast<size_t>(Detail::SortOrder::kSortOrder_Ascending);
    static constexpr size_t        kDescendingIndex = static_cast<size_t>(Detail::SortOrder::kSortOrder_Descending);
    NSString * const               kSortOrderForKeyDescription[Detail::SortKey::kSortKey_Count][Detail::kSortOrder_Count] = {
        [Detail::SortKey::kSortKey_Favorite]     = {
            [kDescendingIndex] = @"FavoriteDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"FavoriteAscendingSortOrderCriteriaKey"
        },
        [Detail::SortKey::kSortKey_Identifier]   = {
            [kDescendingIndex] = @"NumericDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"NumericAscendingSortOrderCriteriaKey"
        },
        [Detail::SortKey::kSortKey_LastUsedDate] = {
            [kDescendingIndex] = @"DateDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"DateAscendingSortOrderCriteriaKey"
        },
        [Detail::SortKey::kSortKey_Mute]         = {
            [kDescendingIndex] = @"MuteDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"MuteAscendingSortOrderCriteriaKey"
        },
        [Detail::SortKey::kSortKey_Name]         = {
            [kDescendingIndex] = @"AlphabeticDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"AlphabeticAscendingSortOrderCriteriaKey"
        },
        [Detail::SortKey::kSortKey_UseCount]         = {
            [kDescendingIndex] = @"NumericDescendingSortOrderCriteriaKey",
            [kAscendingIndex]  = @"NumericAscendingSortOrderCriteriaKey"
        }
    };
    NSString *                     lLocalizedStringKey;
    NSString *                     lRetval         = nullptr;


    nlREQUIRE(IsSortKeyValid(aSortKey), done);
    nlREQUIRE(IsSortOrderValid(aSortOrder), done);

    lLocalizedStringKey = kSortOrderForKeyDescription[aSortKey][aSortOrder];

    lRetval = NSLocalizedStringFromTable(lLocalizedStringKey,
                                         Detail::kSortCriteriaTableName, @"");

done:
    return (lRetval);
}

NSString *
SortOrderForKeyDetailDescription(const Detail::SortOrder &aSortOrder,
                                 const Detail::SortKey &aSortKey)
{
    NSString * lSortOrderDescription       = nullptr;
    NSString * lSortOrderForKeyDescription = nullptr;
    NSString * lRetval                     = nullptr;


    lSortOrderDescription = SortOrderDescription(aSortOrder);
    nlREQUIRE(lSortOrderDescription != nullptr, done);

    lSortOrderForKeyDescription = SortOrderForKeyDescription(aSortOrder,
                                                             aSortKey);
    nlREQUIRE(lSortOrderForKeyDescription != nullptr, done);

    lRetval = [[NSString alloc] initWithFormat:
        NSLocalizedStringFromTable(@"SortOrderCriteriaOrderAndDetailFormatKey",
                                   Detail::kSortCriteriaTableName,
                                   @""),
        lSortOrderDescription,
        lSortOrderForKeyDescription];
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

}; // namespace Detail
