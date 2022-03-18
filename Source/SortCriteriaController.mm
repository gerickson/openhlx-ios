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

#import "SortCriteriaController.h"

#import <algorithm>
#import <array>
#import <vector>

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Common/Errors.hpp>
#import <OpenHLX/Utilities/Assert.hpp>

#import "ClientController.hpp"


using namespace HLX;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace Detail
{

// Type Definitions

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

enum class SortOrder : bool
{
    kSortOrder_Descending = false,
    kSortOrder_Ascending  = true
};

typedef NSComparisonResult (*SortFunction)(ClientController &aClientController,
                                           const IdentifierModel::IdentifierType &aFirstIdentifier,
                                           const IdentifierModel::IdentifierType &aSecondIdentifier);

struct SortParameter
{
    SortKey      mSortKey;
    SortOrder    mSortOrder;
    SortFunction mSortFunction;
};

typedef std::array<SortParameter, SortKey::kSortKey_Count> SortParameters;
typedef std::vector<IdentifierModel::IdentifierType> ObjectIdentifiers;

class ObjectSortFunctorBasis
{
public:
    ObjectSortFunctorBasis(ClientController &aClientController,
                           SortParameters::const_iterator aFirstParameter,
                           SortParameters::const_iterator aLastParameter);
    ~ObjectSortFunctorBasis(void) = default;

    bool operator ()(const ObjectIdentifiers::value_type &aFirst,
                     const ObjectIdentifiers::value_type &aSecond) const;

 private:
    ClientController &              mClientController;
    SortParameters::const_iterator  mFirstParameter;
    SortParameters::const_iterator  mLastParameter;
};

class GroupSortFunctor :
    public ObjectSortFunctorBasis
{
 public:
    GroupSortFunctor(ClientController &aClientController,
                     SortParameters::const_iterator aFirstParameter,
                     SortParameters::const_iterator aLastParameter);
    ~GroupSortFunctor(void) = default;
};

class ZoneSortFunctor :
    public ObjectSortFunctorBasis
{
 public:
    ZoneSortFunctor(ClientController &aClientController,
                    SortParameters::const_iterator aCurrentParameter,
                    SortParameters::const_iterator aLastParameter);
    ~ZoneSortFunctor(void) = default;
};

ObjectSortFunctorBasis :: ObjectSortFunctorBasis(ClientController &aClientController,
                                                 SortParameters::const_iterator aFirstParameter,
                                                 SortParameters::const_iterator aLastParameter) :
    mClientController(aClientController),
    mFirstParameter(aFirstParameter),
    mLastParameter(aLastParameter)
{
    return;
}

bool 
ObjectSortFunctorBasis :: operator ()(const ObjectIdentifiers::value_type &aFirst,
                                      const ObjectIdentifiers::value_type &aSecond) const
{
    SortParameters::const_iterator lCurrentParameter = mFirstParameter;
    bool                           lRetval = false;

    while (lCurrentParameter != mLastParameter)
    {
        if ((lCurrentParameter->mSortKey      != kSortKey_Invalid) &&
            (lCurrentParameter->mSortFunction != nullptr         ))
        {
            const NSComparisonResult lComparison =
                lCurrentParameter->mSortFunction(mClientController,
                                                 aFirst,
                                                 aSecond);

            if (lComparison == NSOrderedSame)
            {
                goto next_sort_parameter;
            }
            else if (((lCurrentParameter->mSortOrder == SortOrder::kSortOrder_Ascending) &&
                      (lComparison == NSOrderedAscending)) ||
                     ((lCurrentParameter->mSortOrder == SortOrder::kSortOrder_Descending) &&
                      (lComparison == NSOrderedDescending)))
            {
                lRetval = true;
                break;
            }
            else
            {
                lRetval = false;
                break;
            }
        }

    next_sort_parameter:
        lCurrentParameter++;
    }

    return (lRetval);
}

GroupSortFunctor :: GroupSortFunctor(ClientController &aClientController,
                                     SortParameters::const_iterator aFirstParameter,
                                     SortParameters::const_iterator aLastParameter) :
    ObjectSortFunctorBasis(aClientController,
                           aFirstParameter,
                           aLastParameter)
{
    return;
}

ZoneSortFunctor :: ZoneSortFunctor(ClientController &aClientController,
                                   SortParameters::const_iterator aCurrentParameter,
                                   SortParameters::const_iterator aLastParameter) :
    ObjectSortFunctorBasis(aClientController,
                           aCurrentParameter,
                           aLastParameter)
{
    return;
}

static NSComparisonResult
BooleanCompare(const bool &aFirst,
               const bool &aSecond)
{
    NSComparisonResult lRetval;

    if (aFirst < aSecond)
        lRetval = NSOrderedAscending;
    else if (aFirst > aSecond)
        lRetval = NSOrderedDescending;
    else
        lRetval = NSOrderedSame;

    return (lRetval);
}

static NSComparisonResult
GroupCompare(ClientController &aClientController,
             const IdentifierModel::IdentifierType &aFirstIdentifier,
             const IdentifierModel::IdentifierType &aSecondIdentifier,
             NSComparisonResult (*aCompare)(const GroupModel &aFirst, const GroupModel &aSecond))
{
    const GroupModel * lFirstModel  = nullptr;
    const GroupModel * lSecondModel = nullptr;
    Status             lStatus;
    NSComparisonResult lRetval = NSOrderedSame;

    lStatus = aClientController.GetApplicationController()->GroupGet(aFirstIdentifier, lFirstModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aClientController.GetApplicationController()->GroupGet(aSecondIdentifier, lSecondModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = aCompare(*lFirstModel, *lSecondModel);

done:
    return (lRetval);
}

static NSComparisonResult
ZoneCompare(ClientController &aClientController,
             const IdentifierModel::IdentifierType &aFirstIdentifier,
             const IdentifierModel::IdentifierType &aSecondIdentifier,
             NSComparisonResult (*aCompare)(const ZoneModel &aFirst, const ZoneModel &aSecond))
{
    const ZoneModel *  lFirstModel  = nullptr;
    const ZoneModel *  lSecondModel = nullptr;
    Status             lStatus;
    NSComparisonResult lRetval = NSOrderedSame;

    lStatus = aClientController.GetApplicationController()->ZoneGet(aFirstIdentifier, lFirstModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aClientController.GetApplicationController()->ZoneGet(aSecondIdentifier, lSecondModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = aCompare(*lFirstModel, *lSecondModel);

done:
    return (lRetval);
}

static NSComparisonResult
GroupFavoriteCompare(ClientController &aClientController,
                     const IdentifierModel::IdentifierType &aFirstIdentifier,
                     const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    ClientObjectPreferencesModel::FavoriteType  lFirstFavorite = false;
    ClientObjectPreferencesModel::FavoriteType  lSecondFavorite = false;
    Status                                      lStatus;
    NSComparisonResult                          lRetval = NSOrderedSame;

    lStatus = aClientController.GetPreferencesController().GroupGetFavorite(aFirstIdentifier, lFirstFavorite);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().GroupGetFavorite(aSecondIdentifier, lSecondFavorite);
    (void)lStatus;

    lRetval = BooleanCompare(lFirstFavorite, lSecondFavorite);

done:
    return (lRetval);
}

static NSComparisonResult
ZoneFavoriteCompare(ClientController &aClientController,
                    const IdentifierModel::IdentifierType &aFirstIdentifier,
                    const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    ClientObjectPreferencesModel::FavoriteType  lFirstFavorite = false;
    ClientObjectPreferencesModel::FavoriteType  lSecondFavorite = false;
    Status                                      lStatus;
    NSComparisonResult                          lRetval = NSOrderedSame;

    lStatus = aClientController.GetPreferencesController().ZoneGetFavorite(aFirstIdentifier, lFirstFavorite);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().ZoneGetFavorite(aSecondIdentifier, lSecondFavorite);
    (void)lStatus;

    lRetval = BooleanCompare(lFirstFavorite, lSecondFavorite);

done:
    return (lRetval);

}

static NSComparisonResult
DateCompare(NSDate * aFirst,
            NSDate * aSecond)
{
    NSComparisonResult  lRetval = NSOrderedSame;

    if ((aFirst != nullptr) && (aSecond != nullptr))
    {
        lRetval = [aFirst compare: aSecond];
    }
    else if ((aFirst == nullptr) && (aSecond == nullptr))
    {
        lRetval = NSOrderedSame;
    }
    else
    {
        lRetval = ((aSecond == nullptr) ? NSOrderedAscending : NSOrderedDescending);
    }

    return (lRetval);
}

static NSComparisonResult
GroupLastUsedDateCompare(ClientController &aClientController,
                         const IdentifierModel::IdentifierType &aFirstIdentifier,
                         const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    NSDate *            lFirstLastUsedDate  = nullptr;
    NSDate *            lSecondLastUsedDate = nullptr;
    Status              lStatus;
    NSComparisonResult  lRetval = NSOrderedSame;

    lStatus = aClientController.GetPreferencesController().GroupGetLastUsedDate(aFirstIdentifier, &lFirstLastUsedDate);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().GroupGetLastUsedDate(aSecondIdentifier, &lSecondLastUsedDate);
    (void)lStatus;

    lRetval = DateCompare(lFirstLastUsedDate, lSecondLastUsedDate);

done:
    return (lRetval);
}

static NSComparisonResult
ZoneLastUsedDateCompare(ClientController &aClientController,
                        const IdentifierModel::IdentifierType &aFirstIdentifier,
                        const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    NSDate *            lFirstLastUsedDate  = nullptr;
    NSDate *            lSecondLastUsedDate = nullptr;
    Status              lStatus;
    NSComparisonResult  lRetval = NSOrderedSame;

    lStatus = aClientController.GetPreferencesController().ZoneGetLastUsedDate(aFirstIdentifier, &lFirstLastUsedDate);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().ZoneGetLastUsedDate(aSecondIdentifier, &lSecondLastUsedDate);
    (void)lStatus;

    lRetval = DateCompare(lFirstLastUsedDate, lSecondLastUsedDate);

done:
    return (lRetval);
}

static NSComparisonResult
IdentifierCompare(const IdentifierModel::IdentifierType &aFirst,
                  const IdentifierModel::IdentifierType &aSecond)
{
    NSComparisonResult lRetval;

    if (aFirst < aSecond)
        lRetval = NSOrderedAscending;
    else if (aFirst > aSecond)
        lRetval = NSOrderedDescending;
    else
        lRetval = NSOrderedSame;

    return (lRetval);
}

template <class Object>
static NSComparisonResult
ObjectIdentifierCompare(const Object &aFirstObject,
                        const Object &aSecondObject)
{
    IdentifierModel::IdentifierType  lFirstIdentifier  = IdentifierModel::kIdentifierInvalid;
    IdentifierModel::IdentifierType  lSecondIdentifier = IdentifierModel::kIdentifierInvalid;;
    Status                           lStatus;
    NSComparisonResult               lRetval = NSOrderedSame;

    lStatus = aFirstObject.GetIdentifier(lFirstIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aSecondObject.GetIdentifier(lSecondIdentifier);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = IdentifierCompare(lFirstIdentifier, lSecondIdentifier);

 done:
    return (lRetval);
}

static NSComparisonResult
GroupIdentifierCompare(const GroupModel &aFirst,
                       const GroupModel &aSecond)
{
    return (ObjectIdentifierCompare<GroupModel>(aFirst, aSecond));
}

static NSComparisonResult
ZoneIdentifierCompare(const ZoneModel &aFirst,
                      const ZoneModel &aSecond)
{
    return (ObjectIdentifierCompare<ZoneModel>(aFirst, aSecond));
}

static NSComparisonResult
GroupIdentifierCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = GroupCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    GroupIdentifierCompare);

    return (lRetval);
}

static NSComparisonResult
ZoneIdentifierCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = ZoneCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    ZoneIdentifierCompare);

    return (lRetval);
}

template <class Object>
static NSComparisonResult
ObjectMuteCompare(const Object &aFirstObject,
                  const Object &aSecondObject)
{
    VolumeModel::MuteType   lFirstMute = false;
    VolumeModel::MuteType   lSecondMute = false;
    Status                  lStatus;
    NSComparisonResult      lRetval = NSOrderedSame;

    lStatus = aFirstObject.GetMute(lFirstMute);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aSecondObject.GetMute(lSecondMute);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = BooleanCompare(lFirstMute, lSecondMute);

 done:
    return (lRetval);
}

static NSComparisonResult
GroupMuteCompare(const GroupModel &aFirst,
                 const GroupModel &aSecond)
{
    return (ObjectMuteCompare<GroupModel>(aFirst, aSecond));
}

static NSComparisonResult
ZoneMuteCompare(const ZoneModel &aFirst,
                const ZoneModel &aSecond)
{
    return (ObjectMuteCompare<ZoneModel>(aFirst, aSecond));
}

static NSComparisonResult
GroupMuteCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = GroupCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    GroupMuteCompare);

    return (lRetval);
}

static NSComparisonResult
ZoneMuteCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = ZoneCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    ZoneMuteCompare);

    return (lRetval);
}

static NSComparisonResult
NameCompare(const char *aFirst,
            const char *aSecond)
{
    const int          lComparison = strcmp(aFirst, aSecond);
    NSComparisonResult lRetval;

    if (lComparison < 0)
        lRetval = NSOrderedAscending;
    else if (lComparison > 0)
        lRetval = NSOrderedDescending;
    else
        lRetval = NSOrderedSame;

    return (lRetval);
}

template <class Object>
static NSComparisonResult
ObjectNameCompare(const Object &aFirstObject,
                  const Object &aSecondObject)
{
    const char *        lFirstName = nullptr;
    const char *        lSecondName = nullptr;
    Status              lStatus;
    NSComparisonResult  lRetval = NSOrderedSame;

    lStatus = aFirstObject.GetName(lFirstName);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aSecondObject.GetName(lSecondName);
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = NameCompare(lFirstName, lSecondName);

 done:
    return (lRetval);
}

static NSComparisonResult
GroupNameCompare(const GroupModel &aFirst,
                 const GroupModel &aSecond)
{
    return (ObjectNameCompare<GroupModel>(aFirst, aSecond));
}

static NSComparisonResult
ZoneNameCompare(const ZoneModel &aFirst,
                const ZoneModel &aSecond)
{
    return (ObjectNameCompare<ZoneModel>(aFirst, aSecond));
}

static NSComparisonResult
GroupNameCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = GroupCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    GroupNameCompare);

    return (lRetval);
}

static NSComparisonResult
ZoneNameCompare(ClientController &aClientController,
                const IdentifierModel::IdentifierType &aFirstIdentifier,
                const IdentifierModel::IdentifierType &aSecondIdentifier)
{
    const NSComparisonResult lRetval = ZoneCompare(aClientController,
                                                    aFirstIdentifier,
                                                    aSecondIdentifier,
                                                    ZoneNameCompare);

    return (lRetval);
}


static void
ClearAndInitializeIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
                              ObjectIdentifiers &aIdentifiers)
{
    aIdentifiers.clear();

    for (auto lIdentifier = IdentifierModel::kIdentifierMin;
         lIdentifier <= aIdentifiersMax;
         lIdentifier++)
    {
        aIdentifiers.push_back(lIdentifier);
    }
}

static void
LogIdentifiers(const char *aWhich, ObjectIdentifiers &aIdentifiers)
{
    ObjectIdentifiers::const_iterator lCurrent = aIdentifiers.begin();
    ObjectIdentifiers::const_iterator lLast = aIdentifiers.end();

    Log::Debug().Write("%s identifiers:", aWhich);

    while (lCurrent != lLast)
    {
        Log::Debug().Write(" %hhu", *lCurrent);

        lCurrent++;
    }

    Log::Debug().Write("\n");
}

static void
SortIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
                const ObjectSortFunctorBasis &aSortFunctor,
                ObjectIdentifiers &aIdentifiers)
{
    ClearAndInitializeIdentifiers(aIdentifiersMax, aIdentifiers);

    std::sort(aIdentifiers.begin(),
              aIdentifiers.end(),
              aSortFunctor);
}                           

static void
SortIdentifiers(const ObjectSortFunctorBasis &aSortFunctor,
                ObjectIdentifiers &aIdentifiers)
{
    std::sort(aIdentifiers.begin(),
              aIdentifiers.end(),
              aSortFunctor);
}                           

static void
SortGroupIdentifiers(ClientController &aClientController,
                     SortParameters::const_iterator aCurrentParameter,
                     SortParameters::const_iterator aLastParameter,
                     ObjectIdentifiers &aIdentifiers)
{
    const GroupSortFunctor           lGroupSortFunctor(aClientController,
                                                       aCurrentParameter,
                                                       aLastParameter);

    SortIdentifiers(lGroupSortFunctor,
                    aIdentifiers);
}

static Status
InitAndSortGroupIdentifiers(ClientController &aClientController,
                            SortParameters::const_iterator aCurrentParameter,
                            SortParameters::const_iterator aLastParameter,
                            ObjectIdentifiers &aIdentifiers)
{
    const GroupSortFunctor           lGroupSortFunctor(aClientController,
                                                       aCurrentParameter,
                                                       aLastParameter);
    IdentifierModel::IdentifierType  lIdentifiersMax = 0;
    Status                           lRetval;

    lRetval = aClientController.GetApplicationController()->GroupsGetMax(lIdentifiersMax);
    nlREQUIRE_SUCCESS(lRetval, done);

    SortIdentifiers(lIdentifiersMax,
                    lGroupSortFunctor,
                    aIdentifiers);

 done:
    return (lRetval);
}

static void
SortZoneIdentifiers(ClientController &aClientController,
                    SortParameters::const_iterator aCurrentParameter,
                    SortParameters::const_iterator aLastParameter,
                    ObjectIdentifiers &aIdentifiers)
{
    const ZoneSortFunctor           lZoneSortFunctor(aClientController,
                                                     aCurrentParameter,
                                                     aLastParameter);

    SortIdentifiers(lZoneSortFunctor,
                    aIdentifiers);
}

static Status
InitAndSortZoneIdentifiers(ClientController &aClientController,
                           SortParameters::const_iterator aCurrentParameter,
                           SortParameters::const_iterator aLastParameter,
                           ObjectIdentifiers &aIdentifiers)
{
    const ZoneSortFunctor           lZoneSortFunctor(aClientController,
                                                     aCurrentParameter,
                                                     aLastParameter);
    IdentifierModel::IdentifierType  lIdentifiersMax = 0;
    Status                           lRetval;

    lRetval = aClientController.GetApplicationController()->ZonesGetMax(lIdentifiersMax);
    nlREQUIRE_SUCCESS(lRetval, done);

    SortIdentifiers(lIdentifiersMax,
                    lZoneSortFunctor,
                    aIdentifiers);

 done:
    return (lRetval);
}

// Global Variables

#if 1
static const SortParameters sGroupSortParameters = {{
    { kSortKey_Mute,         SortOrder::kSortOrder_Ascending,  GroupMuteCompare         },
    { kSortKey_LastUsedDate, SortOrder::kSortOrder_Descending, GroupLastUsedDateCompare },
    { kSortKey_Favorite,     SortOrder::kSortOrder_Descending, GroupFavoriteCompare     },
    { kSortKey_Name,         SortOrder::kSortOrder_Ascending,  GroupNameCompare         },
    { kSortKey_Identifier,   SortOrder::kSortOrder_Ascending,  GroupIdentifierCompare   },
}};

static const SortParameters sZoneSortParameters = {{
    { kSortKey_Mute,         SortOrder::kSortOrder_Ascending,  ZoneMuteCompare          },
    { kSortKey_LastUsedDate, SortOrder::kSortOrder_Descending, ZoneLastUsedDateCompare  },
    { kSortKey_Favorite,     SortOrder::kSortOrder_Descending, ZoneFavoriteCompare      },
    { kSortKey_Name,         SortOrder::kSortOrder_Ascending,  ZoneNameCompare          },
    { kSortKey_Identifier,   SortOrder::kSortOrder_Ascending,  ZoneIdentifierCompare    },
}};
#else
static const SortParameters sGroupSortParameters = {{
    { kSortKey_Identifier,   SortOrder::kSortOrder_Ascending,  GroupIdentifierCompare   },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
}};

static const SortParameters sZoneSortParameters = {{
    { kSortKey_Identifier,   SortOrder::kSortOrder_Ascending,  ZoneIdentifierCompare    },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
    { kSortKey_Invalid,      SortOrder::kSortOrder_Ascending,  nullptr                  },
}};
#endif

}; // namespace Detail

@interface SortCriteriaController ()
{
    NSString *                 mPreferencesKey;
    bool                       mAsGroup;
    Detail::ObjectIdentifiers  mIdentifiers;

    /**
     *  A pointer to the global app HLX client controller instance.
     *
     */
    ClientController *         mClientController;
}

@end

@implementation SortCriteriaController

// MARK: Type Methods

// MARK: Utility

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
- (SortCriteriaController *)initWithPreferencesKey: (NSString *)aPreferencesKey asGroup: (const bool &)aAsGroup;
{
    Status                   lStatus;
    SortCriteriaController * lRetval = nullptr;


    nlREQUIRE(aPreferencesKey != nullptr, done);

    mPreferencesKey = aPreferencesKey;
    mAsGroup        = aAsGroup;

    lStatus = [self loadPreferences];
    nlREQUIRE_SUCCESS(lStatus, done);

    lRetval = self;

 done:
    return (lRetval);
}

// MARK: Introspection

- (NSUInteger) count
{
    const Detail::SortParameters & lSortParameters = ((mAsGroup) ? Detail::sGroupSortParameters : Detail::sZoneSortParameters);
    NSUInteger                     lRetval = 0;

    lRetval = lSortParameters.size();

    return (lRetval);
}

static NSString *
SortKeyDescription(const Detail::SortKey &aSortKey)
{
    NSString * lRetval;

    switch (aSortKey)
    {

    case Detail::kSortKey_Favorite:
        lRetval = NSLocalizedStringFromTable(@"FavoriteSortKeyCriteriaKey", @"SortCriteria", @"");
        break;

    case Detail::kSortKey_Identifier:
        lRetval = NSLocalizedStringFromTable(@"IdentifierSortKeyCriteriaKey", @"SortCriteria", @"");
        break;

    case Detail::kSortKey_LastUsedDate:
        lRetval = NSLocalizedStringFromTable(@"LastUsedDateSortKeyCriteriaKey", @"SortCriteria", @"");
        break;

    case Detail::kSortKey_Mute:
        lRetval = NSLocalizedStringFromTable(@"MuteSortKeyCriteriaKey", @"SortCriteria", @"");
        break;

    case Detail::kSortKey_Name:
        lRetval = NSLocalizedStringFromTable(@"NameSortKeyCriteriaKey", @"SortCriteria", @"");
        break;

    default:
        lRetval = nullptr;
        break;

    }

    return (lRetval);
}

- (NSString *) sortKeyDescriptionAtIndex: (const NSUInteger &)aIndex
{
    const Detail::SortParameters & lSortParameters = ((mAsGroup) ? Detail::sGroupSortParameters : Detail::sZoneSortParameters);
    NSString *                     lRetval         = nullptr;

    nlREQUIRE(aIndex < lSortParameters.size(), done);

    lRetval = SortKeyDescription(lSortParameters[aIndex].mSortKey);
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

static NSString *
SortOrderDescription(const Detail::SortOrder &aSortOrder)
{
    NSString * lRetval;

    switch (aSortOrder)
    {

    case Detail::SortOrder::kSortOrder_Ascending:
        lRetval = NSLocalizedStringFromTable(@"AscendingSortOrderCriteriaKey", @"SortCriteria", @"");
        break;

    case Detail::SortOrder::kSortOrder_Descending:
        lRetval = NSLocalizedStringFromTable(@"DescendingSortOrderCriteriaKey", @"SortCriteria", @"");
        break;

    default:
        lRetval = nullptr;
        break;

    }

    return (lRetval);
}

- (NSString *) sortOrderDescriptionAtIndex: (const NSUInteger &)aIndex
{
    const Detail::SortParameters & lSortParameters = ((mAsGroup) ? Detail::sGroupSortParameters : Detail::sZoneSortParameters);
    NSString *                     lRetval         = nullptr;

    nlREQUIRE(aIndex < lSortParameters.size(), done);

    lRetval = SortOrderDescription(lSortParameters[aIndex].mSortOrder);
    nlREQUIRE(lRetval != nullptr, done);

done:
   return (lRetval);
}

static NSString *
SortOrderForKeyDescription(const Detail::SortOrder &aSortOrder,
                           const Detail::SortKey &aSortKey)
{
    static const size_t            kAscendingIndex = static_cast<size_t>(Detail::SortOrder::kSortOrder_Ascending);
    static const size_t            kDescendingIndex = static_cast<size_t>(Detail::SortOrder::kSortOrder_Descending);
    NSString * const               kSortOrderForKeyDescription[Detail::SortKey::kSortKey_Count][2] = {
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
        }
    };
    NSString *                     lLocalizedStringKey;
    NSString *                     lRetval         = nullptr;

    nlREQUIRE(aSortKey < Detail::SortKey::kSortKey_Max, done);

    lLocalizedStringKey = kSortOrderForKeyDescription[aSortKey][static_cast<size_t>(aSortOrder)];

    lRetval = NSLocalizedStringFromTable(lLocalizedStringKey, @"SortCriteria", @"");

done:
    return (lRetval);
}

- (NSString *) sortOrderDetailDescriptionAtIndex: (const NSUInteger &)aIndex
{
    const Detail::SortParameters & lSortParameters = ((mAsGroup) ? Detail::sGroupSortParameters : Detail::sZoneSortParameters);
    NSString *                     lSortOrderDescription = nullptr;
    NSString *                     lSortOrderForKeyDescription = nullptr;
    NSString *                     lRetval         = nullptr;


    nlREQUIRE(aIndex < lSortParameters.size(), done);

    lSortOrderDescription = SortOrderDescription(lSortParameters[aIndex].mSortOrder);
    nlREQUIRE(lSortOrderDescription != nullptr, done);

    lSortOrderForKeyDescription = SortOrderForKeyDescription(lSortParameters[aIndex].mSortOrder,
                                                             lSortParameters[aIndex].mSortKey);
    nlREQUIRE(lSortOrderForKeyDescription != nullptr, done);

    lRetval = [[NSString alloc] initWithFormat: NSLocalizedStringFromTable(@"SortOrderCriteriaOrderAndDetailFormatKey", @"SortCriteria", @""), lSortOrderDescription,
        lSortOrderForKeyDescription];
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

// MARK: Setters

/**
 *  @brief
 *    Set the client controller for the view.
 *
 *  @param[in]  aClientController  A reference to an app client
 *                                 controller instance to use for
 *                                 this view controller.
 *
 */
- (void) setClientController: (ClientController &)aClientController
{
    Status lStatus;


    if (mAsGroup)
    {
        lStatus = Detail::InitAndSortGroupIdentifiers(aClientController,
                                                      Detail::sGroupSortParameters.begin(),
                                                      Detail::sGroupSortParameters.end(),
                                                      mIdentifiers);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        lStatus = Detail::InitAndSortZoneIdentifiers(aClientController,
                                                     Detail::sZoneSortParameters.begin(),
                                                     Detail::sZoneSortParameters.end(),
                                                     mIdentifiers);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

    mClientController = &aClientController;

 done:
    return;
}

// MARK: Mutation

- (Status) removeSortCriteriaAtIndex: (const NSUInteger &)aIndex
{
    DeclareScopedFunctionTracer(lTracer);
    Status lRetval = kStatus_Success;

    return (lRetval);
}

// MARK: Workers

- (NSInteger) mapIdentifierToIndex: (const IdentifierModel::IdentifierType &)aIdentifier
{
    Detail::ObjectIdentifiers::const_iterator lResult = std::find(mIdentifiers.cbegin(),
                                                                  mIdentifiers.cend(),
                                                                  aIdentifier);
    NSInteger                                 lRetval = NSNotFound;

    nlREQUIRE(lResult != mIdentifiers.end(), done);

    lRetval = static_cast<NSInteger>(std::distance(mIdentifiers.cbegin(), lResult));

 done:
    return (lRetval);
}

- (IdentifierModel::IdentifierType) mapIndexToIdentifier: (const NSUInteger &)aIndex
{
    const size_t                    lIndex  = aIndex;
    IdentifierModel::IdentifierType lRetval = IdentifierModel::kIdentifierInvalid;

    nlREQUIRE(lIndex < mIdentifiers.size(), done);

    lRetval = mIdentifiers[lIndex];

 done:
    return (lRetval);
}

- (Status) sortIdentifiers
{
    Status lRetval = kStatus_Success;


    nlREQUIRE_ACTION(mClientController != nullptr, done, lRetval = -ENXIO);

    if (mAsGroup)
    {
        Detail::SortGroupIdentifiers(*mClientController,
                                     Detail::sGroupSortParameters.begin(),
                                     Detail::sGroupSortParameters.end(),
                                     mIdentifiers);
    }
    else
    {
        Detail::SortZoneIdentifiers(*mClientController,
                                    Detail::sZoneSortParameters.begin(),
                                    Detail::sZoneSortParameters.end(),
                                    mIdentifiers);
    }

 done:
    return (lRetval);
}

- (Status) loadPreferences: (NSDictionary *)aSortCriteriaDictionary
{
    Status lRetval = kStatus_Success;

    return (lRetval);
}

- (Status) loadPreferences
{
    NSDictionary *  lSortCriteriaDictionary;
    Status          lRetval = kStatus_Success;

    lSortCriteriaDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey: mPreferencesKey];
    Log::Debug().Write("Loading lSortCriteriaDictionary %p for key %s\n", lSortCriteriaDictionary, [mPreferencesKey UTF8String]);
    nlEXPECT(lSortCriteriaDictionary != nullptr, done);

    Log::Debug().Write("lSortCriteriaDictionary: %s\n",
                       [[lSortCriteriaDictionary description] UTF8String]);

    lRetval = [self loadPreferences: lSortCriteriaDictionary];
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);

}

- (Status) storePreferences: (NSMutableDictionary *)aSortCriteriaDictionary
{
    Status                 lRetval = kStatus_Success;

    return (lRetval);
}

- (Status) storePreferences
{
    NSMutableDictionary *  lSortCriteriaDictionary;
    Status                 lRetval = kStatus_Success;


    lSortCriteriaDictionary = [[NSMutableDictionary alloc] init];
    nlREQUIRE_ACTION(lSortCriteriaDictionary != nullptr, done, lRetval = -ENOMEM);

    lRetval = [self storePreferences: lSortCriteriaDictionary];
    nlREQUIRE_SUCCESS(lRetval, done);

    Log::Debug().Write("Storing lSortCriteriaDictionary %p for key %s\n", lSortCriteriaDictionary, [mPreferencesKey UTF8String]);

    Log::Debug().Write("lSortCriteriaDictionary: %s\n",
                       [[lSortCriteriaDictionary description] UTF8String]);

    [[NSUserDefaults standardUserDefaults] setObject: lSortCriteriaDictionary
                                              forKey: mPreferencesKey];

 done:
    return (lRetval);
}

@end
