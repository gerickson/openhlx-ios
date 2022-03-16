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

#if 0
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
- (SortCriteriaController *)initAsGroup: (const bool &)aAsGroup
{
    mAsGroup = aAsGroup;

    return (self);
}

// MARK: Introspection

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

// MARK: Workers

- (IdentifierModel::IdentifierType) mapIndexToIdentifier: (const NSUInteger &)aIndex
{
    const size_t lIndex = aIndex;
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

@end
