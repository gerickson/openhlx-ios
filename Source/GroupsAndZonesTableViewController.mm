/*
 *    Copyright (c) 2019-2022 Grant Erickson
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
 *    This file implements a view controller for observing and mutating a
 *    HLX group or zone, limited to their name, source (input), and
 *    volume (including level and mute state) properties.
 *
 */

#import "GroupsAndZonesTableViewController.h"

#import <algorithm>
#import <array>
#import <vector>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Client/GroupsStateChangeNotifications.hpp>
#include <OpenHLX/Client/ZonesStateChangeNotifications.hpp>
#include <OpenHLX/Model/VolumeModel.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "GroupsAndZonesTableViewCell.h"
#import "GroupDetailViewController.h"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"
#import "ZoneDetailViewController.h"


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace HLX
{

namespace Client
{

class Controller;

};

};

typedef std::vector<IdentifierModel::IdentifierType> ObjectIdentifiers;

@interface GroupsAndZonesTableViewController ()
{
    ObjectIdentifiers mGroupIdentifiers;
    ObjectIdentifiers mZoneIdentifiers;
}

@end

@implementation GroupsAndZonesTableViewController

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

enum SortKey
{
    kSortKey_Invalid       = -1,

    kSortKey_Min           = 0,

    kSortKey_Identifier    = kSortKey_Min,
    kSortKey_Favorite,
    kSortKey_LastUsedDate,
    kSortKey_Mute,
    kSortKey_Name,

    kSortKey_Max,
    kSortKey_Count         = kSortKey_Max
};

enum
{
    kSortOrder_Descending = false,
    kSortOrder_Ascending  = true
};

union SortOrder
{
    bool mAscending;
    bool mLowestToHighest;
    bool mIsFavorite;
    bool mOldestToNewest;
    bool mIsMuted;
    bool mAToZ;
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

typedef std::array<SortParameter, kSortKey_Count> SortParameters;

class ObjectSortFunctorBasis
{
public:
    ObjectSortFunctorBasis(ClientController &aClientController,
                           SortParameters::const_iterator aFirstParameter,
                           SortParameters::const_iterator aLastParameter) :
        mClientController(aClientController),
        mFirstParameter(aFirstParameter),
        mLastParameter(aLastParameter)
    {
        return;
    }
    ~ObjectSortFunctorBasis(void) = default;

    bool operator ()(const ObjectIdentifiers::value_type &aFirst,
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
                else if (((lCurrentParameter->mSortOrder.mAscending) &&
                          (lComparison == NSOrderedAscending)) ||
                         ((!lCurrentParameter->mSortOrder.mAscending) &&
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
                     SortParameters::const_iterator aLastParameter) :
        ObjectSortFunctorBasis(aClientController,
                               aFirstParameter,
                                aLastParameter)
    {
        return;
    }
    ~GroupSortFunctor(void) = default;
};

class ZoneSortFunctor :
    public ObjectSortFunctorBasis
{
 public:
    ZoneSortFunctor(ClientController &aClientController,
                    SortParameters::const_iterator aCurrentParameter,
                    SortParameters::const_iterator aLastParameter) :
        ObjectSortFunctorBasis(aClientController,
                               aCurrentParameter,
                               aLastParameter)
    {
        return;
    }
    ~ZoneSortFunctor(void) = default;
};

static void ClearAndInitializeIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
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

static void SortIdentifiers(const IdentifierModel::IdentifierType &aIdentifiersMax,
                            const ObjectSortFunctorBasis &aSortFunctor,
                            ObjectIdentifiers &aIdentifiers)
{
    ClearAndInitializeIdentifiers(aIdentifiersMax, aIdentifiers);

    std::sort(aIdentifiers.begin(),
              aIdentifiers.end(),
              aSortFunctor);
}                           

static void SortGroupIdentifiers(ClientController &aClientController,
                                 SortParameters::const_iterator aCurrentParameter,
                                 SortParameters::const_iterator aLastParameter,
                                 ObjectIdentifiers &aIdentifiers)
{
    const GroupSortFunctor           lGroupSortFunctor(aClientController,
                                                       aCurrentParameter,
                                                       aLastParameter);
    IdentifierModel::IdentifierType  lIdentifiersMax = 0;
    Status                           lStatus;

    lStatus = aClientController.GetApplicationController()->GroupsGetMax(lIdentifiersMax);
    nlREQUIRE_SUCCESS(lStatus, done);

    SortIdentifiers(lIdentifiersMax,
                    lGroupSortFunctor,
                    aIdentifiers);

 done:
    return;
}

static void SortZoneIdentifiers(ClientController &aClientController,
                                SortParameters::const_iterator aCurrentParameter,
                                SortParameters::const_iterator aLastParameter,
                                ObjectIdentifiers &aIdentifiers)
{
    const ZoneSortFunctor            lZoneSortFunctor(aClientController,
                                                      aCurrentParameter,
                                                      aLastParameter);
    IdentifierModel::IdentifierType  lIdentifiersMax = 0;
    Status                           lStatus;

    lStatus = aClientController.GetApplicationController()->ZonesGetMax(lIdentifiersMax);
    nlREQUIRE_SUCCESS(lStatus, done);

    SortIdentifiers(lIdentifiersMax,
                    lZoneSortFunctor,
                    aIdentifiers);

 done:
    return;
}

#if 0
static const SortParameters sGroupSortParameters = {{
    { kSortKey_Mute,         kSortOrder_Ascending,  GroupMuteCompare         },
    { kSortKey_LastUsedDate, kSortOrder_Descending, GroupLastUsedDateCompare },
    { kSortKey_Favorite,     kSortOrder_Descending, GroupFavoriteCompare     },
    { kSortKey_Name,         kSortOrder_Ascending,  GroupNameCompare         },
    { kSortKey_Identifier,   kSortOrder_Ascending,  GroupIdentifierCompare   },
}};

static const SortParameters sZoneSortParameters = {{
    { kSortKey_Mute,         kSortOrder_Ascending,  ZoneMuteCompare          },
    { kSortKey_LastUsedDate, kSortOrder_Descending, ZoneLastUsedDateCompare  },
    { kSortKey_Favorite,     kSortOrder_Descending, ZoneFavoriteCompare      },
    { kSortKey_Name,         kSortOrder_Ascending,  ZoneNameCompare          },
    { kSortKey_Identifier,   kSortOrder_Ascending,  ZoneIdentifierCompare    },
}};
#else
static const SortParameters sGroupSortParameters = {{
    { kSortKey_Identifier,   kSortOrder_Ascending,  GroupIdentifierCompare   },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
}};

static const SortParameters sZoneSortParameters = {{
    { kSortKey_Identifier,   kSortOrder_Ascending,  ZoneIdentifierCompare    },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
    { kSortKey_Invalid,      0,                     nullptr                  },
}};
#endif

// MARK: View Delegation

- (void) viewDidLoad
{
    UIBarButtonItem *lFlexibleSpaceButtonItem;
    UIBarButtonItem *lFilterButtonItem;
    UIBarButtonItem *lSortButtonItem;
    NSArray         *lToolbarItems;

    [super viewDidLoad];

    lFlexibleSpaceButtonItem = [[ UIBarButtonItem alloc ] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    nlREQUIRE(lFlexibleSpaceButtonItem != nullptr, done);

    lFilterButtonItem = [[ UIBarButtonItem alloc ] initWithTitle: @"Filter"
                                                           style: UIBarButtonItemStylePlain
                                                          target: self
                                                          action: @selector(onFilterButtonAction:)];
    nlREQUIRE(lFilterButtonItem != nullptr, done);

    lSortButtonItem = [[ UIBarButtonItem alloc ] initWithTitle: @"Sort"
                                                           style: UIBarButtonItemStylePlain
                                                          target: self
                                                          action: @selector(onSortButtonAction:)];
    nlREQUIRE(lSortButtonItem != nullptr, done);

    lToolbarItems = [ NSArray arrayWithObjects: lFlexibleSpaceButtonItem,
                                                lFilterButtonItem,
                                                lFlexibleSpaceButtonItem,
                                                lSortButtonItem,
                                                lFlexibleSpaceButtonItem,
                                                nil ];
    nlREQUIRE(lToolbarItems != nullptr, done);

    [self setToolbarItems: lToolbarItems];

    [self.navigationController setToolbarHidden: NO
                               animated: YES];

 done:
    return;
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

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status  lStatus;


    [super viewWillAppear: aAnimated];

    mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

    lStatus = mClientController->GetApplicationController()->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    SortGroupIdentifiers(*mClientController,
                         sGroupSortParameters.begin(),
                         sGroupSortParameters.end(),
                         mGroupIdentifiers);
    LogIdentifiers("Group", mGroupIdentifiers);
    SortZoneIdentifiers(*mClientController,
                        sZoneSortParameters.begin(),
                        sZoneSortParameters.end(),
                        mZoneIdentifiers);
    LogIdentifiers("Zone", mZoneIdentifiers);

    [self.tableView reloadData];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a group or zone list view controller
 *    from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone list view controller,
 *    if successful; otherwise, null.
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
 *    Creates and initializes a group or zone list view controller
 *    with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone list view controller,
 *    if successful; otherwise, null.
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
    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

 done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if ([aSender isKindOfClass: [GroupsAndZonesTableViewCell class]])
    {
        GroupsAndZonesTableViewCell *  lGroupsAndZonesCell = aSender;
        const bool                     lIsGroup = [lGroupsAndZonesCell isGroup];
        Status                         lStatus;

        if (lIsGroup)
        {
            GroupDetailViewController *  lGroupDetailViewController = [aSegue destinationViewController];

            [lGroupDetailViewController setClientController: *mClientController
                                                   forGroup: [lGroupsAndZonesCell group]];
        }
        else
        {
            ZoneDetailViewController *   lZoneDetailViewController = [aSegue destinationViewController];

            [lZoneDetailViewController setClientController: *mClientController
                                                   forZone: [lGroupsAndZonesCell zone]];
        }

        lStatus = mClientController->GetApplicationController()->SetDelegate(nullptr);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the group or zone segmented
 *    control.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onGroupZoneSegmentedControlAction: (id)aSender
{
    if (aSender == self.mGroupZoneSegmentedControl)
    {
        mShowStyle = self.mGroupZoneSegmentedControl.selectedSegmentIndex;

        [self.tableView reloadData];
    }

    return;
}

- (IBAction) onFilterButtonAction: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
}

- (IBAction) onSortButtonAction: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
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
    mClientController = &aClientController;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    static const NSInteger kNumberOfSections = 1;

    return (kNumberOfSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    IdentifierModel::IdentifierType  lValue = 0;
    NSInteger                        lRetval = 0;
    Status                           lStatus;


    nlREQUIRE(aSection == 0, done);

    if (mShowStyle == kShowStyleGroups)
    {
        lStatus = mClientController->GetApplicationController()->GroupsGetMax(lValue);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else if (mShowStyle == kShowStyleZones)
    {
        lStatus = mClientController->GetApplicationController()->ZonesGetMax(lValue);
        nlREQUIRE_SUCCESS(lStatus, done);
    }

    lRetval = lValue;

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const bool                     lAsGroup = (mShowStyle == kShowStyleGroups);
    GroupsAndZonesTableViewCell *  lRetval = nullptr;
    NSString *                     lCellIdentifier = nullptr;

    if (lAsGroup)
    {
        lCellIdentifier = @"Group Table View Cell";
    }
    else
    {
        lCellIdentifier = @"Zone Table View Cell";

    }

    lRetval = [aTableView dequeueReusableCellWithIdentifier: lCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableCell: lRetval
                   forIndexPath: aIndexPath];

 done:
    return (lRetval);
}

// MARK: Workers

- (IdentifierModel::IdentifierType) mapRowToIdentifier: (const NSUInteger &)aRow
           asGroup: (const bool &)aAsGroup
{
    const size_t                          lIndex  = aRow;
    const IdentifierModel::IdentifierType lRetval = ((aAsGroup) ?
                                                     mGroupIdentifiers[lIndex] :
                                                     mZoneIdentifiers[lIndex]);

    return (lRetval);
}

- (void) configureReusableCell: (GroupsAndZonesTableViewCell *)aCell
                  forIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger  lSection = aIndexPath.section;
    const NSUInteger  lRow = aIndexPath.row;


    nlREQUIRE(lSection == 0, done);

    if ((mShowStyle == kShowStyleGroups) || (mShowStyle == kShowStyleZones))
    {
        const bool  lAsGroup = (mShowStyle == kShowStyleGroups);
        Status      lStatus;

        // HLX identifiers are one rather than zero based; however,
        // UIKit table rows are zero based. Consequently, increment
        // the row by one to account for this.

        lStatus = [aCell configureCellForIdentifier: [self mapRowToIdentifier: lRow
                                                                      asGroup: lAsGroup]
                                     withController: *mClientController
                                            asGroup: lAsGroup];
        nlVERIFY_SUCCESS(lStatus);
    }

 done:
    return;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

- (void) controllerStateDidChange: (HLX::Client::Application::ControllerBasis &)aController withNotification: (const StateChange::NotificationBasis &)aStateChangeNotification
{
    const StateChange::Type  lType = aStateChangeNotification.GetType();
    NSIndexPath *            lIndexPath;

    switch (lType)
    {

    case StateChange::kStateChangeType_GroupMute:
    case StateChange::kStateChangeType_GroupName:
    case StateChange::kStateChangeType_GroupSource:
    case StateChange::kStateChangeType_GroupVolume:
        {
            if (mShowStyle == kShowStyleGroups)
            {
                const StateChange::GroupsNotificationBasis &lSCN = static_cast<const StateChange::GroupsNotificationBasis &>(aStateChangeNotification);
                const NSUInteger lRow = (lSCN.GetIdentifier() - 1);

                lIndexPath = [NSIndexPath indexPathForRow: lRow
                                          inSection: 0];

                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                                withRowAnimation: UITableViewRowAnimationNone];
            }
        }
        break;

    case StateChange::kStateChangeType_SourceName:
        [self.tableView reloadData];
        break;

    case StateChange::kStateChangeType_ZoneMute:
    case StateChange::kStateChangeType_ZoneName:
    case StateChange::kStateChangeType_ZoneSource:
    case StateChange::kStateChangeType_ZoneVolume:
        {
            if (mShowStyle == kShowStyleZones)
            {
                const StateChange::ZonesNotificationBasis &lSCN = static_cast<const StateChange::ZonesNotificationBasis &>(aStateChangeNotification);
                const NSUInteger lRow = (lSCN.GetIdentifier() - 1);

                lIndexPath = [NSIndexPath indexPathForRow: lRow
                                          inSection: 0];

                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: lIndexPath]
                                withRowAnimation: UITableViewRowAnimationNone];
            }
        }
        break;

    default:
        break;

    }

 done:
    return;
}

@end
