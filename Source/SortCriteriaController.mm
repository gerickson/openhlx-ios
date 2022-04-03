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

#import <errno.h>

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Common/Errors.hpp>
#import <OpenHLX/Utilities/Assert.hpp>

#import "ClientController.hpp"
#import "SortParameter_Detail.hpp"


using namespace HLX;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace Detail
{

// MARK: Type Definitions

typedef NSComparisonResult (*SortFunction)(ClientController &aClientController,
                                           const IdentifierModel::IdentifierType &aFirstIdentifier,
                                           const IdentifierModel::IdentifierType &aSecondIdentifier);

typedef std::array<SortFunction, SortKey::kSortKey_Count> SortFunctions;
typedef std::vector<SortParameter> SortParameters;
typedef std::vector<IdentifierModel::IdentifierType> ObjectIdentifiers;

class ObjectSortFunctorBasis
{
public:
    ObjectSortFunctorBasis(ClientController &aClientController,
                           const SortFunctions &aSortKeyToFunctionMap,
                           SortParameters::const_iterator aFirstParameter,
                           SortParameters::const_iterator aLastParameter);
    ~ObjectSortFunctorBasis(void) = default;

    bool operator ()(const ObjectIdentifiers::value_type &aFirst,
                     const ObjectIdentifiers::value_type &aSecond) const;

 private:
    ClientController &              mClientController;
    const SortFunctions &           mSortKeyToFunctionMap;
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

// MARK: Function Prototypes

static NSComparisonResult BooleanCompare(const bool &aFirst,
                                         const bool &aSecond);
static NSComparisonResult GroupCompare(ClientController &aClientController,
                                       const IdentifierModel::IdentifierType &aFirstIdentifier,
                                       const IdentifierModel::IdentifierType &aSecondIdentifier,
                                       NSComparisonResult (*aCompare)(const GroupModel &aFirst, const GroupModel &aSecond));
static NSComparisonResult ZoneCompare(ClientController &aClientController,
                                      const IdentifierModel::IdentifierType &aFirstIdentifier,
                                      const IdentifierModel::IdentifierType &aSecondIdentifier,
                                      NSComparisonResult (*aCompare)(const ZoneModel &aFirst, const ZoneModel &aSecond));
static NSComparisonResult GroupFavoriteCompare(ClientController &aClientController,
                                               const IdentifierModel::IdentifierType &aFirstIdentifier,
                                               const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult ZoneFavoriteCompare(ClientController &aClientController,
                                              const IdentifierModel::IdentifierType &aFirstIdentifier,
                                              const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult DateCompare(NSDate * aFirst,
                                      NSDate * aSecond);
static NSComparisonResult GroupLastUsedDateCompare(ClientController &aClientController,
                                                   const IdentifierModel::IdentifierType &aFirstIdentifier,
                                                   const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult ZoneLastUsedDateCompare(ClientController &aClientController,
                                                  const IdentifierModel::IdentifierType &aFirstIdentifier,
                                                  const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult IdentifierCompare(const IdentifierModel::IdentifierType &aFirst,
                                            const IdentifierModel::IdentifierType &aSecond);
static NSComparisonResult GroupIdentifierCompare(const GroupModel &aFirst,
                                                 const GroupModel &aSecond);
static NSComparisonResult ZoneIdentifierCompare(const ZoneModel &aFirst,
                                                const ZoneModel &aSecond);
static NSComparisonResult GroupIdentifierCompare(ClientController &aClientController,
                                                 const IdentifierModel::IdentifierType &aFirstIdentifier,
                                                 const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult ZoneIdentifierCompare(ClientController &aClientController,
                                                const IdentifierModel::IdentifierType &aFirstIdentifier,
                                                const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult GroupMuteCompare(const GroupModel &aFirst,
                                           const GroupModel &aSecond);
static NSComparisonResult ZoneMuteCompare(const ZoneModel &aFirst,
                                          const ZoneModel &aSecond);
static NSComparisonResult GroupMuteCompare(ClientController &aClientController,
                                           const IdentifierModel::IdentifierType &aFirstIdentifier,
                                           const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult ZoneMuteCompare(ClientController &aClientController,
                                          const IdentifierModel::IdentifierType &aFirstIdentifier,
                                          const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult NameCompare(const char *aFirst,
                                      const char *aSecond);
static NSComparisonResult GroupNameCompare(const GroupModel &aFirst,
                                           const GroupModel &aSecond);
static NSComparisonResult ZoneNameCompare(const ZoneModel &aFirst,
                                          const ZoneModel &aSecond);
static NSComparisonResult GroupNameCompare(ClientController &aClientController,
                                           const IdentifierModel::IdentifierType &aFirstIdentifier,
                                           const IdentifierModel::IdentifierType &aSecondIdentifier);
static NSComparisonResult ZoneNameCompare(ClientController &aClientController,
                                          const IdentifierModel::IdentifierType &aFirstIdentifier,
                                          const IdentifierModel::IdentifierType &aSecondIdentifier);
static void ClearAndInitializeIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
                                          ObjectIdentifiers &aIdentifiers);
static void SortIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
                            const ObjectSortFunctorBasis &aSortFunctor,
                            ObjectIdentifiers &aIdentifiers);
static void SortIdentifiers(const ObjectSortFunctorBasis &aSortFunctor,
                            ObjectIdentifiers &aIdentifiers);
static void SortGroupIdentifiers(ClientController &aClientController,
                                 SortParameters::const_iterator aCurrentParameter,
                                 SortParameters::const_iterator aLastParameter,
                                 ObjectIdentifiers &aIdentifiers);
static Status InitAndSortGroupIdentifiers(ClientController &aClientController,
                                          SortParameters::const_iterator aCurrentParameter,
                                          SortParameters::const_iterator aLastParameter,
                                          ObjectIdentifiers &aIdentifiers);
static void SortZoneIdentifiers(ClientController &aClientController,
                                SortParameters::const_iterator aCurrentParameter,
                                SortParameters::const_iterator aLastParameter,
                                ObjectIdentifiers &aIdentifiers);
static Status InitAndSortZoneIdentifiers(ClientController &aClientController,
                                         SortParameters::const_iterator aCurrentParameter,
                                         SortParameters::const_iterator aLastParameter,
                                         ObjectIdentifiers &aIdentifiers);
static Status StorePreferences(const SortParameter &aSortParameter,
                               NSMutableDictionary * aSortParameterDictionary);
static Status StorePreferences(const SortParameter &aSortParameter,
                               NSMutableArray * aSortCriteriaArray);
static Status StorePreferences(const SortParameters &aSortParameters,
                               NSMutableArray * aSortCriteriaArray);
static Status LoadPreferences(SortParameter &aSortParameter,
                              NSDictionary * aSortParameterDictionary);
static Status LoadPreferences(SortParameters &aSortParameters,
                              NSArray * aSortCriteriaArray);

// MARK: Function Templates

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

// MARK: Global Variables

// MARK: Default Group and Zone Sort Parameters

static constexpr SortParameter const   sDefaultSortParameter      = {
    SortKey::kSortKey_Identifier,
    SortOrder::kSortOrder_Ascending
};

static constexpr SortParameter const & sDefaultGroupSortParameter =
    sDefaultSortParameter;

static constexpr SortParameter const & sDefaultZoneSortParameter  =
    sDefaultSortParameter;

// MARK: Group and Zone Sort Function Map

static constexpr SortFunctions const   sGroupSortKeyToFunctionMap = {{
    [SortKey::kSortKey_Favorite]     = GroupFavoriteCompare,
    [SortKey::kSortKey_Identifier]   = GroupIdentifierCompare,
    [SortKey::kSortKey_LastUsedDate] = GroupLastUsedDateCompare,
    [SortKey::kSortKey_Mute]         = GroupMuteCompare,
    [SortKey::kSortKey_Name]         = GroupNameCompare
}};

static constexpr SortFunctions const   sZoneSortKeyToFunctionMap = {{
    [SortKey::kSortKey_Favorite]     = ZoneFavoriteCompare,
    [SortKey::kSortKey_Identifier]   = ZoneIdentifierCompare,
    [SortKey::kSortKey_LastUsedDate] = ZoneLastUsedDateCompare,
    [SortKey::kSortKey_Mute]         = ZoneMuteCompare,
    [SortKey::kSortKey_Name]         = ZoneNameCompare
}};

// MARK: Preferences Keys and Values

static NSString * const kPreferencesSortKeyKey               = @"Key";

static NSString * const kPreferencesSortKeyFavoriteValue     = @"Favorite";
static NSString * const kPreferencesSortKeyIdentiferValue    = @"Identifier";
static NSString * const kPreferencesSortKeyLastUsedDateValue = @"Last Used Date";
static NSString * const kPreferencesSortKeyMuteValue         = @"Mute";
static NSString * const kPreferencesSortKeyNameValue         = @"Name";

static NSString * const kPreferencesSortOrderKey             = @"Order";

static NSString * const kPreferencesSortOrderAscendingValue  = @"Ascending";
static NSString * const kPreferencesSortOrderDescendingValue = @"Descending";

// MARK: Implementation

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

    lStatus = aClientController.GetApplicationController()->GroupGet(aFirstIdentifier,
                                                                     lFirstModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aClientController.GetApplicationController()->GroupGet(aSecondIdentifier,
                                                                     lSecondModel);
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

    lStatus = aClientController.GetApplicationController()->ZoneGet(aFirstIdentifier,
                                                                    lFirstModel);
    nlREQUIRE_SUCCESS(lStatus, done);

    lStatus = aClientController.GetApplicationController()->ZoneGet(aSecondIdentifier,
                                                                    lSecondModel);
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

    lStatus = aClientController.GetPreferencesController().GroupGetFavorite(aFirstIdentifier,
                                                                            lFirstFavorite);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().GroupGetFavorite(aSecondIdentifier,
                                                                            lSecondFavorite);
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

    lStatus = aClientController.GetPreferencesController().ZoneGetFavorite(aFirstIdentifier,
                                                                           lFirstFavorite);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().ZoneGetFavorite(aSecondIdentifier,
                                                                           lSecondFavorite);
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

    lStatus = aClientController.GetPreferencesController().GroupGetLastUsedDate(aFirstIdentifier,
                                                                                &lFirstLastUsedDate);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().GroupGetLastUsedDate(aSecondIdentifier,
                                                                                &lSecondLastUsedDate);
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

    lStatus = aClientController.GetPreferencesController().ZoneGetLastUsedDate(aFirstIdentifier,
                                                                               &lFirstLastUsedDate);
    (void)lStatus;

    lStatus = aClientController.GetPreferencesController().ZoneGetLastUsedDate(aSecondIdentifier,
                                                                               &lSecondLastUsedDate);
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

static Status
StoreSortKeyPreference(const SortParameter &aSortParameter,
                       NSMutableDictionary * aSortParameterDictionary)
{
    NSString * lSortKeyValueString;
    Status     lRetval = kStatus_Success;


    switch (aSortParameter.mSortKey)
    {

    case Detail::kSortKey_Favorite:
        lSortKeyValueString = kPreferencesSortKeyFavoriteValue;
        break;

    case Detail::kSortKey_Identifier:
        lSortKeyValueString = kPreferencesSortKeyIdentiferValue;
        break;

    case Detail::kSortKey_LastUsedDate:
        lSortKeyValueString = kPreferencesSortKeyLastUsedDateValue;
        break;

    case Detail::kSortKey_Mute:
        lSortKeyValueString = kPreferencesSortKeyMuteValue;
        break;

    case Detail::kSortKey_Name:
        lSortKeyValueString = kPreferencesSortKeyNameValue;
        break;

    default:
        lSortKeyValueString = nullptr;
        lRetval             = kError_InvalidConfiguration;
        nlREQUIRE_SUCCESS(lRetval, done);
        break;

    }

    [aSortParameterDictionary setObject: lSortKeyValueString
                                 forKey: kPreferencesSortKeyKey];

 done:
    return (lRetval);
}

static Status
StoreSortOrderPreference(const SortParameter &aSortParameter,
                         NSMutableDictionary * aSortParameterDictionary)
{
    NSString * lSortOrderValueString;
    Status     lRetval = kStatus_Success;


    switch (aSortParameter.mSortOrder)
    {

    case Detail::SortOrder::kSortOrder_Ascending:
        lSortOrderValueString = kPreferencesSortOrderAscendingValue;
        break;

    case Detail::SortOrder::kSortOrder_Descending:
        lSortOrderValueString = kPreferencesSortOrderDescendingValue;
        break;

    default:
        lSortOrderValueString = nullptr;
        lRetval               = kError_InvalidConfiguration;
        nlREQUIRE_SUCCESS(lRetval, done);
        break;

    }

    [aSortParameterDictionary setObject: lSortOrderValueString
                                 forKey: kPreferencesSortOrderKey];

 done:
    return (lRetval);
}

static Status
StorePreferences(const SortParameter &aSortParameter,
                 NSMutableDictionary * aSortParameterDictionary)
{
    Status    lRetval = kStatus_Success;


    // Sort Key

    lRetval = StoreSortKeyPreference(aSortParameter,
                                     aSortParameterDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    // Sort Order

    lRetval = StoreSortOrderPreference(aSortParameter,
                                       aSortParameterDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

static Status
StorePreferences(const SortParameter &aSortParameter,
                 NSMutableArray * aSortCriteriaArray)
{
    NSMutableDictionary * lSortParameterDictionary;
    Status lRetval = kStatus_Success;

    lSortParameterDictionary = [[NSMutableDictionary alloc] init];
    nlREQUIRE_ACTION(lSortParameterDictionary != nullptr, done, lRetval = -ENOMEM);

    lRetval = StorePreferences(aSortParameter, lSortParameterDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    [aSortCriteriaArray addObject: lSortParameterDictionary];

 done:
    return (lRetval);
}

static Status
StorePreferences(const SortParameters &aSortParameters,
                 NSMutableArray * aSortCriteriaArray)
{
    SortParameters::const_iterator lCurrentParameter = aSortParameters.cbegin();
    SortParameters::const_iterator lLastParameter    = aSortParameters.cend();
    Status                         lRetval           = kStatus_Success;

    while (lCurrentParameter != lLastParameter)
    {
        lRetval = StorePreferences(*lCurrentParameter,
                                   aSortCriteriaArray);
        nlREQUIRE_SUCCESS(lRetval, done);

        lCurrentParameter++;
    }

 done:
    return (lRetval);
}

static Status
LoadSortKeyPreference(SortParameter &aSortParameter,
                      NSDictionary * aSortParameterDictionary)
{
    NSString *lSortKeyValueString   = nullptr;
    SortKey   lSortKey;
    Status    lRetval               = kStatus_Success;

    
    lSortKeyValueString = [aSortParameterDictionary objectForKey: kPreferencesSortKeyKey];
    nlREQUIRE_ACTION(lSortKeyValueString != nullptr, done, lRetval = -ENOENT);

    if ([lSortKeyValueString isEqual: kPreferencesSortKeyFavoriteValue])
    {
        lSortKey = SortKey::kSortKey_Favorite;
    }
    else if ([lSortKeyValueString isEqual: kPreferencesSortKeyIdentiferValue])
    {
        lSortKey = SortKey::kSortKey_Identifier;
    }
    else if ([lSortKeyValueString isEqual: kPreferencesSortKeyLastUsedDateValue])
    {
        lSortKey = SortKey::kSortKey_LastUsedDate;
    }
    else if ([lSortKeyValueString isEqual: kPreferencesSortKeyMuteValue])
    {
        lSortKey = SortKey::kSortKey_Mute;
    }
    else if ([lSortKeyValueString isEqual: kPreferencesSortKeyNameValue])
    {
        lSortKey = SortKey::kSortKey_Name;
    }
    else
    {
        lSortKey = SortKey::kSortKey_Invalid;
        lRetval  = kError_InvalidConfiguration;
        nlREQUIRE_SUCCESS(lRetval, done);
    }

    aSortParameter.mSortKey = lSortKey;

done:
    return (lRetval);
}

static Status
LoadSortOrderPreference(SortParameter &aSortParameter,
                        NSDictionary * aSortParameterDictionary)
{
    NSString *lSortOrderValueString = nullptr;
    SortOrder lSortOrder;
    Status    lRetval               = kStatus_Success;


    // Sort Order

    lSortOrderValueString = [aSortParameterDictionary objectForKey: kPreferencesSortOrderKey];
    nlREQUIRE_ACTION(lSortOrderValueString != nullptr, done, lRetval = -ENOENT);

    if ([lSortOrderValueString isEqual: kPreferencesSortOrderAscendingValue])
    {
        lSortOrder = SortOrder::kSortOrder_Ascending;
    }
    else if ([lSortOrderValueString isEqual: kPreferencesSortOrderDescendingValue])
    {
        lSortOrder = SortOrder::kSortOrder_Descending;
    }
    else
    {
        lSortOrder = SortOrder::kSortOrder_Invalid;
        lRetval    = kError_InvalidConfiguration;
        nlREQUIRE_SUCCESS(lRetval, done);
    }

    aSortParameter.mSortOrder = lSortOrder;

done:
    return (lRetval);
}

static Status
LoadPreferences(SortParameter &aSortParameter,
                NSDictionary * aSortParameterDictionary)
{
    Status    lRetval               = kStatus_Success;

    // Sort Key

    lRetval = LoadSortKeyPreference(aSortParameter,
                                    aSortParameterDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    // Sort Order

    lRetval = LoadSortOrderPreference(aSortParameter,
                                      aSortParameterDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

done:
    return (lRetval);
}

static Status
LoadPreferences(SortParameters &aSortParameters,
                NSArray * aSortCriteriaArray)
{
    Status lRetval = kStatus_Success;

    for (NSDictionary * lSortParameterDictionary in aSortCriteriaArray)
    {
        SortParameter lSortParameter;

        lRetval = LoadPreferences(lSortParameter,
                                  lSortParameterDictionary);
        nlREQUIRE_SUCCESS(lRetval, done);

        aSortParameters.push_back(lSortParameter);
    }

 done:
    return (lRetval);
}

ObjectSortFunctorBasis :: ObjectSortFunctorBasis(ClientController &aClientController,
                                                 const SortFunctions &aSortKeyToFunctionMap,
                                                 SortParameters::const_iterator aFirstParameter,
                                                 SortParameters::const_iterator aLastParameter) :
    mClientController(aClientController),
    mSortKeyToFunctionMap(aSortKeyToFunctionMap),
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
        if (IsSortParameterValid(*lCurrentParameter))
        {
            const SortFunction       lSortFunction   = mSortKeyToFunctionMap[lCurrentParameter->mSortKey];
            const NSComparisonResult lSortComparison =
                lSortFunction(mClientController,
                              aFirst,
                              aSecond);

            if (lSortComparison == NSOrderedSame)
            {
                goto next_sort_parameter;
            }
            else if (((lCurrentParameter->mSortOrder == SortOrder::kSortOrder_Ascending) &&
                      (lSortComparison == NSOrderedAscending)) ||
                     ((lCurrentParameter->mSortOrder == SortOrder::kSortOrder_Descending) &&
                      (lSortComparison == NSOrderedDescending)))
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
                           sGroupSortKeyToFunctionMap,
                           aFirstParameter,
                           aLastParameter)
{
    return;
}

ZoneSortFunctor :: ZoneSortFunctor(ClientController &aClientController,
                                   SortParameters::const_iterator aCurrentParameter,
                                   SortParameters::const_iterator aLastParameter) :
    ObjectSortFunctorBasis(aClientController,
                           sZoneSortKeyToFunctionMap,
                           aCurrentParameter,
                           aLastParameter)
{
    return;
}

}; // namespace Detail

@interface SortCriteriaController ()
{
    /**
     *  A pointer to the global app HLX client controller instance.
     *
     */
    ClientController *         mClientController;

    NSString *                 mPreferencesKey;
    bool                       mAsGroup;
    Detail::SortParameters     mSortParameters;
    Detail::ObjectIdentifiers  mIdentifiers;
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
- (SortCriteriaController *)initWithPreferencesKey: (NSString *)aPreferencesKey
                                           asGroup: (const bool &)aAsGroup;
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
    NSUInteger  lRetval = 0;

    lRetval = mSortParameters.size();

    return (lRetval);
}

- (bool) hasAllCriteria
{
    bool  lRetval;

    lRetval = (mSortParameters.size() == Detail::SortKey::kSortKey_Count);

    return (lRetval);
}

- (const Detail::SortParameter &) defaultSortParameter
{
    const Detail::SortParameter &lRetval = ((mAsGroup) ?
                                            Detail::sDefaultGroupSortParameter :
                                            Detail::sDefaultZoneSortParameter);

    return (lRetval);
}

- (bool) hasSortKey: (const Detail::SortKey &)aSortKey
{
    Detail::SortParameters::const_iterator lCurrentParameter = mSortParameters.cbegin();
    Detail::SortParameters::const_iterator lLastParameter    = mSortParameters.cend();
    bool                                   lRetval           = false;


    nlREQUIRE(IsSortKeyValid(aSortKey), done);

    while (lCurrentParameter != lLastParameter)
    {
        lRetval = (lCurrentParameter->mSortKey == aSortKey);

        if (lRetval)
            break;

        lCurrentParameter++;
    }

done:
    return (lRetval);
}

- (NSUInteger) indexOfSortKey: (const Detail::SortKey &)aSortKey
{
    Detail::SortParameters::const_iterator lCurrentParameter = mSortParameters.cbegin();
    Detail::SortParameters::const_iterator lLastParameter    = mSortParameters.cend();
    NSUInteger                             lRetval           = NSNotFound;


    nlREQUIRE(IsSortKeyValid(aSortKey), done);

    while (lCurrentParameter != lLastParameter)
    {
        if (lCurrentParameter->mSortKey == aSortKey)
        {
            lRetval = std::distance(mSortParameters.cbegin(), lCurrentParameter);
            break;
        }

        lCurrentParameter++;
    }

 done:
    return (lRetval);
}

- (Detail::SortKey) sortKeyAtIndex: (const NSUInteger &)aIndex
{
    Detail::SortKey lRetval = Detail::SortKey::kSortKey_Invalid;

    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = mSortParameters[aIndex].mSortKey;

done:
    return (lRetval);
}

- (Detail::SortOrder) sortOrderAtIndex: (const NSUInteger &)aIndex
{
    Detail::SortOrder lRetval = Detail::SortOrder::kSortOrder_Ascending;

    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = mSortParameters[aIndex].mSortOrder;

done:
    return (lRetval);
}

- (Detail::SortOrder) sortOrderForSortKey: (const Detail::SortKey &)aSortKey
{
    Detail::SortParameters::const_iterator lCurrentParameter = mSortParameters.cbegin();
    Detail::SortParameters::const_iterator lLastParameter    = mSortParameters.cend();
    Detail::SortOrder                      lRetval = Detail::SortOrder::kSortOrder_Ascending;

    while (lCurrentParameter != lLastParameter)
    {
        if (lCurrentParameter->mSortKey == aSortKey)
        {
            lRetval = lCurrentParameter->mSortOrder;
            break;
        }

        lCurrentParameter++;
    }

    return (lRetval);
}

- (NSString *) sortKeyDescriptionAtIndex: (const NSUInteger &)aIndex
{
    NSString *  lRetval = nullptr;

    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = Detail::SortKeyDescription(mSortParameters[aIndex].mSortKey);
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

- (NSString *) sortOrderDescriptionAtIndex: (const NSUInteger &)aIndex
{
    NSString *  lRetval = nullptr;

    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = Detail::SortOrderDescription(mSortParameters[aIndex].mSortOrder);
    nlREQUIRE(lRetval != nullptr, done);

done:
   return (lRetval);
}

- (NSString *) sortOrderForKeyDescriptionAtIndex: (const NSUInteger &)aIndex
{
    NSString *  lRetval = nullptr;


    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = Detail::SortOrderForKeyDescription(mSortParameters[aIndex].mSortOrder,
                                                 mSortParameters[aIndex].mSortKey);
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}


- (NSString *) sortOrderForKeyDetailDescriptionAtIndex: (const NSUInteger &)aIndex
{
    NSString *  lRetval = nullptr;


    nlREQUIRE(aIndex < mSortParameters.size(), done);

    lRetval = Detail::SortOrderForKeyDetailDescription(mSortParameters[aIndex].mSortOrder,
                                                       mSortParameters[aIndex].mSortKey);
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
                                                      mSortParameters.begin(),
                                                      mSortParameters.end(),
                                                      mIdentifiers);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        lStatus = Detail::InitAndSortZoneIdentifiers(aClientController,
                                                     mSortParameters.begin(),
                                                     mSortParameters.end(),
                                                     mIdentifiers);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

    mClientController = &aClientController;

 done:
    return;
}

// MARK: Mutation

- (Status) insertSortCriteria: (const Detail::SortParameter &)aCriteria
                      atIndex: (const NSUInteger &)aIndex
{
    Status lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aIndex <= mSortParameters.size(), done, lRetval = -EINVAL);

    if (aIndex == mSortParameters.size())
    {
        mSortParameters.push_back(aCriteria);
    }
    else
    {
        mSortParameters.insert(mSortParameters.begin() + aIndex, aCriteria);
    }

done:
   return (lRetval);
}

- (Status) removeSortCriteriaAtIndex: (const NSUInteger &)aIndex
{
    Status lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aIndex < mSortParameters.size(), done, lRetval = -EINVAL);

    mSortParameters.erase(mSortParameters.begin() + aIndex);

 done:
    return (lRetval);
}

- (Status) replaceSortCriteriaAtIndex: (const NSUInteger &)aIndex
                         withCriteria: (const Detail::SortParameter &)aCriteria
{
    Status lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aIndex < mSortParameters.size(), done, lRetval = -EINVAL);

    mSortParameters[aIndex] = aCriteria;

 done:
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
                                     mSortParameters.begin(),
                                     mSortParameters.end(),
                                     mIdentifiers);
    }
    else
    {
        Detail::SortZoneIdentifiers(*mClientController,
                                    mSortParameters.begin(),
                                    mSortParameters.end(),
                                    mIdentifiers);
    }

 done:
    return (lRetval);
}

- (Status) loadPreferences: (NSArray *)aSortCriteriaArray
{
    Status lRetval = kStatus_Success;

    mSortParameters.clear();

    lRetval = Detail::LoadPreferences(mSortParameters,
                                      aSortCriteriaArray);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

- (Status) loadPreferences
{
    NSArray *  lSortCriteriaArray;
    Status     lRetval = kStatus_Success;

    lSortCriteriaArray = [[NSUserDefaults standardUserDefaults] arrayForKey: mPreferencesKey];
    Log::Debug().Write("Loading lSortCriteriaArray %p for key \"%s\"\n", lSortCriteriaArray, [mPreferencesKey UTF8String]);
    nlEXPECT(lSortCriteriaArray != nullptr, copy_default_parameter);

    Log::Debug().Write("lSortCriteriaArray: %s\n",
                       [[lSortCriteriaArray description] UTF8String]);

    lRetval = [self loadPreferences: lSortCriteriaArray];
    nlREQUIRE_SUCCESS(lRetval, done);

    return (lRetval);

copy_default_parameter:
    mSortParameters.push_back([self defaultSortParameter]);

    lRetval = [self storePreferences];
    nlREQUIRE_SUCCESS(lRetval, done);

done:
    return (lRetval);
}

- (Status) storePreferences: (NSMutableArray *)aSortCriteriaArray
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::StorePreferences(mSortParameters,
                                       aSortCriteriaArray);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

- (Status) storePreferences
{
    NSMutableArray *  lSortCriteriaArray;
    Status            lRetval = kStatus_Success;


    lSortCriteriaArray = [[NSMutableArray alloc] init];
    nlREQUIRE_ACTION(lSortCriteriaArray != nullptr, done, lRetval = -ENOMEM);

    lRetval = [self storePreferences: lSortCriteriaArray];
    nlREQUIRE_SUCCESS(lRetval, done);

    Log::Debug().Write("Storing lSortCriteriaArray %p for key \"%s\"\n", lSortCriteriaArray, [mPreferencesKey UTF8String]);

    Log::Debug().Write("lSortCriteriaArray: %s\n",
                       [[lSortCriteriaArray description] UTF8String]);

    [[NSUserDefaults standardUserDefaults] setObject: lSortCriteriaArray
                                              forKey: mPreferencesKey];

 done:
    return (lRetval);
}

@end
