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
 *    This file...
 *
 */

#import "ClientPreferencesController.hpp"

#import <vector>

#import <Foundation/NSDictionary.h>
#import <Foundation/NSNumberFormatter.h>
#import <Foundation/NSUserDefaults.h>

#import <CFUtilities/CFUtilities.hpp>
#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;
using namespace std;


static NSString * kFavoriteKey     = @"Favorite";
static NSString * kGroupsKey       = @"Groups";
static NSString * kLastUsedDateKey = @"Last Used";
static NSString * kZonesKey        = @"Zones";

namespace Detail
{

static NSString *
CreateControllerIdentifier(const NetworkModel::EthernetEUI48Type &aEthernetEUI48)
{
    NSString *lRetval = nullptr;

    lRetval = [[NSString alloc] initWithFormat: @"%02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx",
                                aEthernetEUI48[0],
                                aEthernetEUI48[1],
                                aEthernetEUI48[2],
                                aEthernetEUI48[3],
                                aEthernetEUI48[4],
                                aEthernetEUI48[5]];
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

static NSNumberFormatter *
CreateObjectIdentifierFormatter(void)
{
    NSNumberFormatter *lRetval = nullptr;

    lRetval = [[NSNumberFormatter alloc] init];
    nlREQUIRE(lRetval != nullptr, done);

    [lRetval setFormatterBehavior: NSNumberFormatterBehaviorDefault];
    [lRetval setNumberStyle:       NSNumberFormatterNoStyle];

 done:
    return (lRetval);
}

static NSString *
CreateObjectIdentifier(const IdentifierModel::IdentifierType &aObjectIdentifier)
{
    NSNumberFormatter *  lObjectIdentifierFormatter = nullptr;
    NSNumber *           lObjectIdentifier = nullptr;
    NSString *           lRetval = nullptr;


    lObjectIdentifierFormatter = CreateObjectIdentifierFormatter();
    nlREQUIRE(lObjectIdentifierFormatter != nullptr, done);

    lObjectIdentifier = [[NSNumber alloc] initWithUnsignedChar: aObjectIdentifier];
    nlREQUIRE(lObjectIdentifier != nullptr, done);

    lRetval = [lObjectIdentifierFormatter stringFromNumber: lObjectIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

 done:
    return (lRetval);
}

static IdentifierModel::IdentifierType
GetObjectIdentifier(NSString *aObjectIdentifier)
{
    NSNumberFormatter *              lObjectIdentifierFormatter = nullptr;
    NSNumber *                       lObjectIdentifier = nullptr;
    IdentifierModel::IdentifierType  lRetval = IdentifierModel::kIdentifierInvalid;


    lObjectIdentifierFormatter = CreateObjectIdentifierFormatter();
    nlREQUIRE(lObjectIdentifierFormatter != nullptr, done);

    lObjectIdentifier = [lObjectIdentifierFormatter numberFromString: aObjectIdentifier];
    nlREQUIRE(lObjectIdentifier != nullptr, done);
        
    lRetval = [lObjectIdentifier unsignedCharValue];

 done:
    return (lRetval);
}

static bool
ObjectHasPreferences(const ClientObjectsPreferencesModel &aObjectsPreferencesModel, const IdentifierModel::IdentifierType &aObjectIdentifier)
{
    const ClientObjectPreferencesModel * lObjectPreferencesModel = nullptr;
    Status                               lStatus;
    bool                                 lRetval = false;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there may be no object preferences model.

    lStatus = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);
    nlEXPECT_SUCCESS(lStatus, done);

    lRetval = (lObjectPreferencesModel != nullptr);

 done:
    return (lRetval);
}

static Status
ObjectGetFavorite(const ClientObjectsPreferencesModel &aObjectsPreferencesModel, const IdentifierModel::IdentifierType &aObjectIdentifier, ClientPreferencesController::FavoriteType &aFavorite)
{
    const ClientObjectPreferencesModel * lObjectPreferencesModel = nullptr;
    Status                               lRetval = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there may be no object preferences model.

    lRetval = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);
    nlEXPECT_SUCCESS(lRetval, done);

    lRetval = lObjectPreferencesModel->GetFavorite(aFavorite);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

static Status
ObjectGetLastUsedDate(const ClientObjectsPreferencesModel &aObjectsPreferencesModel, const IdentifierModel::IdentifierType &aObjectIdentifier, NSDate **aLastUsedDate)
{
    const ClientObjectPreferencesModel *       lObjectPreferencesModel = nullptr;
    ClientLastUsedDateModel::LastUsedDateType  lLastUsedDate = nullptr;
    Status                                     lRetval = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there may be no object preferences model.

    lRetval = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);
    nlEXPECT_SUCCESS(lRetval, done);

    lRetval = lObjectPreferencesModel->GetLastUsedDate(lLastUsedDate);
    nlREQUIRE_SUCCESS(lRetval, done);

    *aLastUsedDate = (__bridge NSDate *)lLastUsedDate;

 done:
    return (lRetval);
}

static Status
ObjectGetUseCount(const ClientObjectsPreferencesModel &aObjectsPreferencesModel, const IdentifierModel::IdentifierType &aObjectIdentifier, ClientPreferencesController::UseCountType &aUseCount)
{
    const ClientObjectPreferencesModel * lObjectPreferencesModel = nullptr;
    Status                               lRetval = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there may be no object preferences model.

    lRetval = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);
    nlEXPECT_SUCCESS(lRetval, done);

    lRetval = lObjectPreferencesModel->GetUseCount(aUseCount);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

static Status
ObjectSetFavorite(ClientObjectsPreferencesModel &aObjectsPreferencesModel, const IdentifierModel::IdentifierType &aObjectIdentifier, const ClientPreferencesController::FavoriteType &aFavorite, NSDate *aDate)
{
    ClientObjectPreferencesModel *       lObjectPreferencesModel = nullptr;
    ClientObjectPreferencesModel         lTempPreferencesModel;
    Status                               lRetval = kStatus_Success;

    lRetval = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);

    if (lRetval == -ENOENT)
    {
        lRetval = lTempPreferencesModel.Init();
        nlREQUIRE_SUCCESS(lRetval, done);
        
        lObjectPreferencesModel = &lTempPreferencesModel;
    }

    if (lObjectPreferencesModel != nullptr)
    {
        lRetval = lObjectPreferencesModel->SetFavorite(aFavorite);
        nlREQUIRE(lRetval >= kStatus_Success, done);

        lRetval = lObjectPreferencesModel->SetLastUsedDate((__bridge CFDateRef)(aDate));
        nlREQUIRE(lRetval >= kStatus_Success, done);
    
        if (lObjectPreferencesModel == &lTempPreferencesModel)
        {
            lRetval = aObjectsPreferencesModel.SetObjectPreferences(aObjectIdentifier,
                                                                    *lObjectPreferencesModel);
            nlREQUIRE_SUCCESS(lRetval, done);
        }
    }

 done:
    return (lRetval);
}

static Status
ObjectSetLastUsedDate(ClientObjectsPreferencesModel &aObjectsPreferencesModel,
                      const IdentifierModel::IdentifierType &aObjectIdentifier,
                      NSDate *aLastUsedDate)
{
    ClientObjectPreferencesModel *             lObjectPreferencesModel = nullptr;
    ClientObjectPreferencesModel               lTempPreferencesModel;
    ClientLastUsedDateModel::LastUsedDateType  lLastUsedDate = (__bridge CFDateRef)aLastUsedDate;
    Status                                     lRetval = kStatus_Success;

    lRetval = aObjectsPreferencesModel.GetObjectPreferences(aObjectIdentifier, lObjectPreferencesModel);

    if (lRetval == -ENOENT)
    {
        lRetval = lTempPreferencesModel.Init();
        nlREQUIRE_SUCCESS(lRetval, done);
        
        lObjectPreferencesModel = &lTempPreferencesModel;
    }

    if (lObjectPreferencesModel != nullptr)
    {
        lRetval = lObjectPreferencesModel->SetLastUsedDate(lLastUsedDate);
        nlREQUIRE_SUCCESS(lRetval, done);

        if (lObjectPreferencesModel == &lTempPreferencesModel)
        {
            lRetval = aObjectsPreferencesModel.SetObjectPreferences(aObjectIdentifier,
                                                                    *lObjectPreferencesModel);
            nlREQUIRE_SUCCESS(lRetval, done);
        }
    }

 done:
    return (lRetval);
}

static Status
ObjectReset(ClientObjectsPreferencesModel &aObjectsPreferencesModel,
            const IdentifierModel::IdentifierType &aObjectIdentifier)
{
    Status                               lRetval = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there may be no object preferences model.

    lRetval = aObjectsPreferencesModel.RemoveObjectPreferences(aObjectIdentifier);
    if (lRetval == -ENOENT)
    {
        lRetval = kStatus_Success;
    }
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

static Status
LoadObjectFavoritePreference(ClientObjectPreferencesModel &aObjectPreferencesModel,
                             NSString *aFavoriteKey,
                             NSDictionary *aObjectDictionary)
{
    NSNumber *                       lFavoriteNumber;
    Status                           lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aFavoriteKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectDictionary != nullptr, done, lRetval = -EINVAL);

    lFavoriteNumber = [aObjectDictionary objectForKey: aFavoriteKey];
    nlEXPECT(lFavoriteNumber != nullptr, done);

    lRetval = aObjectPreferencesModel.SetFavorite([lFavoriteNumber boolValue]);
    nlREQUIRE(lRetval >= kStatus_Success, done);

done:
   return (lRetval);
}

static Status
LoadObjectLastUsedDatePreference(ClientObjectPreferencesModel &aObjectPreferencesModel,
                                 NSString *aLastUsedDateKey,
                                 NSDictionary *aObjectDictionary)
{
    NSDate *                         lLastUsedDate;
    Status                           lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aLastUsedDateKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectDictionary != nullptr, done, lRetval = -EINVAL);

    lLastUsedDate = [aObjectDictionary objectForKey: aLastUsedDateKey];
    nlEXPECT(lLastUsedDate != nullptr, done);

    lRetval = aObjectPreferencesModel.SetLastUsedDate((__bridge CFDateRef)lLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

done:
   return (lRetval);
}

static Status
LoadObjectPreferences(ClientObjectPreferencesModel &aObjectPreferencesModel,
                      NSString *aObjectKey,
                      NSDictionary *aObjectsDictionary)
{
    NSDictionary *                   lObjectDictionary;
    Status                           lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aObjectKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectsDictionary != nullptr, done, lRetval = -EINVAL);

    lObjectDictionary = [aObjectsDictionary objectForKey: aObjectKey];
    nlEXPECT(lObjectDictionary != nullptr, done);

    lRetval = LoadObjectFavoritePreference(aObjectPreferencesModel,
                                           kFavoriteKey,
                                           lObjectDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = LoadObjectLastUsedDatePreference(aObjectPreferencesModel,
                                               kLastUsedDateKey,
                                               lObjectDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

done:
   return (lRetval);
}

static Status
LoadObjectsPreferences(ClientObjectsPreferencesModel &aObjectsPreferencesModel,
                       NSString *aObjectsKey,
                       NSDictionary *aControllerDictionary)
{
    NSDictionary *                   lObjectsDictionary;
    NSArray *                        lObjectKeysArray;
    Status                           lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aObjectsKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aControllerDictionary != nullptr, done, lRetval = -EINVAL);

    lObjectsDictionary = [aControllerDictionary objectForKey: aObjectsKey];
    nlEXPECT(lObjectsDictionary != nullptr, done);

    lObjectKeysArray = [lObjectsDictionary allKeys];
    nlEXPECT(lObjectKeysArray != nullptr, done);

    for (NSString * lObjectKey in lObjectKeysArray)
    {
        IdentifierModel::IdentifierType  lObjectIdentifier;
        ClientObjectPreferencesModel     lObjectPreferencesModel;
                           

        lRetval = lObjectPreferencesModel.Init();
        nlREQUIRE_SUCCESS(lRetval, done);

        lRetval = LoadObjectPreferences(lObjectPreferencesModel,
                                        lObjectKey,
                                        lObjectsDictionary);
        nlREQUIRE_SUCCESS(lRetval, done);

        lObjectIdentifier = GetObjectIdentifier(lObjectKey);

        lRetval = aObjectsPreferencesModel.SetObjectPreferences(lObjectIdentifier,
                                                                lObjectPreferencesModel);
        nlREQUIRE_SUCCESS(lRetval, done);
    }

done:
   return (lRetval);
}

static Status
StoreObjectFavoritePreference(const ClientObjectPreferencesModel &aObjectPreferencesModel,
                             NSString *aFavoriteKey,
                             NSMutableDictionary *aObjectDictionary)
{
    ClientPreferencesController::FavoriteType  lFavorite;
    NSNumber *                                 lFavoriteNumber;
    Status                                     lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aFavoriteKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectDictionary != nullptr, done, lRetval = -EINVAL);

    lRetval = aObjectPreferencesModel.GetFavorite(lFavorite);
    nlREQUIRE_SUCCESS(lRetval, done);

    lFavoriteNumber = [[NSNumber alloc] initWithBool: lFavorite];
    nlREQUIRE_ACTION(lFavoriteNumber != nullptr, done, lRetval = -ENOMEM);

    [aObjectDictionary setObject: lFavoriteNumber
                          forKey: aFavoriteKey];

done:
   return (lRetval);
}

static Status
StoreObjectLastUsedDatePreference(const ClientObjectPreferencesModel &aObjectPreferencesModel,
                                  NSString *aLastUsedDateKey,
                                  NSMutableDictionary *aObjectDictionary)
{
    CFDateRef  lLastUsedDate;
    Status     lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aLastUsedDateKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectDictionary != nullptr, done, lRetval = -EINVAL);

    lRetval = aObjectPreferencesModel.GetLastUsedDate(lLastUsedDate);
    nlREQUIRE_SUCCESS(lRetval, done);

    [aObjectDictionary setObject: (__bridge NSDate *)lLastUsedDate
                          forKey: aLastUsedDateKey];

done:
   return (lRetval);
}

static Status
StoreObjectPreferences(const ClientObjectPreferencesModel &aObjectPreferencesModel,
                       NSString *aObjectKey,
                       NSMutableDictionary *aObjectsDictionary)
{
    NSMutableDictionary *            lObjectDictionary;
    Status                           lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aObjectKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aObjectsDictionary != nullptr, done, lRetval = -EINVAL);

    lObjectDictionary = [[NSMutableDictionary alloc] init];

    lRetval = StoreObjectFavoritePreference(aObjectPreferencesModel,
                                            kFavoriteKey,
                                            lObjectDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = StoreObjectLastUsedDatePreference(aObjectPreferencesModel,
                                                kLastUsedDateKey,
                                                lObjectDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    [aObjectsDictionary setObject: lObjectDictionary
                           forKey: aObjectKey];

done:
   return (lRetval);
}

static Status
StoreObjectsPreferences(const ClientObjectsPreferencesModel &aObjectsPreferencesModel,
                        NSString *aObjectsKey,
                        NSMutableDictionary *aControllerDictionary)
{
    NSMutableDictionary *                    lObjectsDictionary;
    IdentifiersCollection                    lObjectIdentifiersCollection;
    size_t                                   lObjectIdentifierCount;
    vector<IdentifierModel::IdentifierType>  lObjectIdentifiers;
    vector<IdentifierModel::IdentifierType>::const_iterator lObjectIdentifierIterator;
    Status                                   lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aObjectsKey != nullptr, done, lRetval = -EINVAL);
    nlREQUIRE_ACTION(aControllerDictionary != nullptr, done, lRetval = -EINVAL);

    lObjectsDictionary = [[NSMutableDictionary alloc] init];
    nlREQUIRE_ACTION(lObjectsDictionary != nullptr, done, lRetval = -ENOMEM);
    
    lRetval = lObjectIdentifiersCollection.Init();
    nlREQUIRE_SUCCESS(lRetval, done);
    
    lRetval = aObjectsPreferencesModel.GetObjectIdentifiers(lObjectIdentifiersCollection);
    nlREQUIRE_SUCCESS(lRetval, done);
    
    lRetval = lObjectIdentifiersCollection.GetCount(lObjectIdentifierCount);
    nlREQUIRE_SUCCESS(lRetval, done);

    lObjectIdentifiers.resize(lObjectIdentifierCount);
    
    lRetval = lObjectIdentifiersCollection.GetIdentifiers(&lObjectIdentifiers[0],
                                                          lObjectIdentifierCount);
    nlREQUIRE_SUCCESS(lRetval, done);

    lObjectIdentifierIterator = lObjectIdentifiers.begin();

    while (lObjectIdentifierIterator != lObjectIdentifiers.end())
    {
        const IdentifierModel::IdentifierType  lObjectIdentifier = *lObjectIdentifierIterator;
        NSString *                             lObjectKey;
        const ClientObjectPreferencesModel *   lObjectPreferencesModel;


        lRetval = aObjectsPreferencesModel.GetObjectPreferences(lObjectIdentifier,
                                                                lObjectPreferencesModel);
        nlREQUIRE_SUCCESS(lRetval, done);

        lObjectKey = CreateObjectIdentifier(lObjectIdentifier);
        nlREQUIRE_ACTION(lObjectKey != nullptr, done, lRetval = -EINVAL);

        lRetval = StoreObjectPreferences(*lObjectPreferencesModel,
                                         lObjectKey,
                                         lObjectsDictionary);
        nlREQUIRE_SUCCESS(lRetval, done);
        
        lObjectIdentifierIterator++;
    }

    [aControllerDictionary setObject: lObjectsDictionary
                              forKey: aObjectsKey];

done:
   return (lRetval);
}

}; // namespace Detail

// MARK: Con/destructor(s)

ClientPreferencesController :: ClientPreferencesController(void) :
    mControllerIdentifier(nullptr),
    mGroupsPreferences(),
    mZonesPreferences(),
    mDelegate(nullptr)
{
    return;
}

ClientPreferencesController :: ~ClientPreferencesController(void)
{
    return;
}

// MARK: Initializers

Status
ClientPreferencesController :: Init(void)
{
    Status lRetval = kStatus_Success;

    return (lRetval);
}

// MARK: Delegate Management

ClientPreferencesControllerDelegate *
ClientPreferencesController :: GetDelegate(void) const
{
    return (mDelegate);
}

Status
ClientPreferencesController :: SetDelegate(ClientPreferencesControllerDelegate *aDelegate)
{
    Status lRetval = kStatus_Success;

    if (aDelegate == mDelegate)
    {
        lRetval = kStatus_ValueAlreadySet;
        goto done;
    }

    mDelegate = aDelegate;

done:
    return (lRetval);
}

Status
ClientPreferencesController :: Bind(const HLX::Client::Application::Controller &aController)
{
    NSString *                       lControllerIdentifier;
    NetworkModel::EthernetEUI48Type  lEthernetEUI48;
    Status                           lRetval = kStatus_Success;


    lRetval = aController.NetworkGetEthernetEUI48(lEthernetEUI48);
    nlREQUIRE_SUCCESS(lRetval, done);

    lControllerIdentifier = Detail::CreateControllerIdentifier(lEthernetEUI48);
    nlREQUIRE(lControllerIdentifier != nullptr, done);

    mControllerIdentifier = lControllerIdentifier;

    lRetval = LoadPreferences();
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: Unbind(void)
{
    Status lRetval = kStatus_Success;

    mControllerIdentifier = nullptr;

    return (lRetval);
}

// MARK: Mutators

Status
ClientPreferencesController :: Reset(void)
{
    Status lRetval = kStatus_Success;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey: mControllerIdentifier];

    return (lRetval);
}

Status
ClientPreferencesController :: GroupReset(const GroupModel::IdentifierType &aGroupIdentifier)
{
    Status  lRetval = kStatus_Success;

    lRetval = ObjectReset(mGroupsPreferences, aGroupIdentifier);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneReset(const ZoneModel::IdentifierType &aZoneIdentifier)
{
    Status  lRetval = kStatus_Success;

    lRetval = ObjectReset(mZonesPreferences, aZoneIdentifier);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

// MARK: Observers

bool
ClientPreferencesController :: GroupHasPreferences(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier) const
{
    const bool lRetval = Detail::ObjectHasPreferences(mGroupsPreferences, aGroupIdentifier);

    return (lRetval);
}

bool
ClientPreferencesController :: ZoneHasPreferences(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier) const
{
    const bool lRetval = Detail::ObjectHasPreferences(mZonesPreferences, aZoneIdentifier);

    return (lRetval);
}

// MARK: Getters

Status
ClientPreferencesController :: GroupGetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                                FavoriteType &aFavorite) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetFavorite(mGroupsPreferences, aGroupIdentifier, aFavorite);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: GroupGetLastUsedDate(const GroupModel::IdentifierType &aGroupIdentifier,
                                                    NSDate **aLastUsedDate) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetLastUsedDate(mGroupsPreferences, aGroupIdentifier, aLastUsedDate);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: GroupGetUseCount(const GroupModel::IdentifierType &aGroupIdentifier,
                                                UseCountType &aUseCount) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetUseCount(mGroupsPreferences, aGroupIdentifier, aUseCount);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneGetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               FavoriteType &aFavorite) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetFavorite(mZonesPreferences, aZoneIdentifier, aFavorite);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneGetLastUsedDate(const ZoneModel::IdentifierType &aZoneIdentifier,
                                                   NSDate **aLastUsedDate) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetLastUsedDate(mZonesPreferences, aZoneIdentifier, aLastUsedDate);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneGetUseCount(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               UseCountType &aUseCount) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectGetUseCount(mZonesPreferences, aZoneIdentifier, aUseCount);
    nlEXPECT_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

// MARK: Setters

// MARK: Setters with implicit date

Status
ClientPreferencesController :: GroupSetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite)
{
    NSDate * lNow    = [NSDate date];
    Status   lRetval = kStatus_Success;

    lRetval = GroupSetFavorite(aGroupIdentifier, aFavorite, lNow);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: GroupSetLastUsedDate(const GroupModel::IdentifierType &aGroupIdentifier,
                                                    NSDate *aLastUsedDate)
{
    Status   lRetval = kStatus_Success;

    lRetval = Detail::ObjectSetLastUsedDate(mGroupsPreferences,
                                            aGroupIdentifier,
                                            aLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneSetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite)
{
    NSDate * lNow    = [NSDate date];
    Status   lRetval = kStatus_Success;

    lRetval = ZoneSetFavorite(aZoneIdentifier, aFavorite, lNow);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneSetLastUsedDate(const ZoneModel::IdentifierType &aZoneIdentifier,
                                                   NSDate *aLastUsedDate)
{
    Status   lRetval = kStatus_Success;

    lRetval = Detail::ObjectSetLastUsedDate(mZonesPreferences,
                                            aZoneIdentifier,
                                            aLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

// MARK: Setters with explicit date

Status
ClientPreferencesController :: GroupSetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite,
                                                NSDate *aDate)
{
    Status lRetval = kStatus_Success;

    lRetval = Detail::ObjectSetFavorite(mGroupsPreferences,
                                        aGroupIdentifier,
                                        aFavorite,
                                        aDate);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = StorePreferences();
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: ZoneSetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite,
                                               NSDate *aDate)
{
    Status lRetval = kStatus_Success;

    lRetval = Detail::ObjectSetFavorite(mZonesPreferences,
                                        aZoneIdentifier,
                                        aFavorite,
                                        aDate);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = StorePreferences();
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

// MARK: TBD

Status
ClientPreferencesController :: ObjectReset(ClientObjectsPreferencesModel &aObjectsPreferencesModel,
                                           const IdentifierModel::IdentifierType &aObjectIdentifier)
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::ObjectReset(aObjectsPreferencesModel,
                                  aObjectIdentifier);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = StorePreferences();
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

// MARK: TBD

Status
ClientPreferencesController :: LoadPreferences(void)
{
    NSDictionary *  lControllerDictionary;
    Status          lRetval = kStatus_Success;

    lControllerDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey: mControllerIdentifier];
    nlEXPECT(lControllerDictionary != nullptr, done);

    Log::Debug().Write("lControllerDictionary: %s\n",
                       [[lControllerDictionary description] UTF8String]);

    lRetval = LoadPreferences(lControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: LoadPreferences(NSDictionary *aControllerDictionary)
{
    Status  lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aControllerDictionary != nullptr, done, lRetval = -EINVAL);

    lRetval = LoadGroupsPreferences(aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = LoadZonesPreferences(aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: LoadGroupsPreferences(NSDictionary *aControllerDictionary)
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::LoadObjectsPreferences(mGroupsPreferences,
                                             kGroupsKey,
                                             aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: LoadZonesPreferences(NSDictionary *aControllerDictionary)
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::LoadObjectsPreferences(mZonesPreferences,
                                             kZonesKey,
                                             aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: StorePreferences(void) const
{
    NSMutableDictionary *  lControllerDictionary;
    Status                 lRetval = kStatus_Success;


    lControllerDictionary = [[NSMutableDictionary alloc] init];
    nlREQUIRE_ACTION(lControllerDictionary != nullptr, done, lRetval = -ENOMEM);

    lRetval = StorePreferences(lControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    Log::Debug().Write("Storing lControllerDictionary %p for controller %s\n", lControllerDictionary, [mControllerIdentifier UTF8String]);

    Log::Debug().Write("lControllerDictionary: %s\n",
                       [[lControllerDictionary description] UTF8String]);

    [[NSUserDefaults standardUserDefaults] setObject: lControllerDictionary
                                              forKey: mControllerIdentifier];

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: StorePreferences(NSMutableDictionary *aControllerDictionary) const
{
    Status  lRetval = kStatus_Success;


    nlREQUIRE_ACTION(aControllerDictionary != nullptr, done, lRetval = -EINVAL);

    lRetval = StoreGroupsPreferences(aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = StoreZonesPreferences(aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: StoreGroupsPreferences(NSMutableDictionary *aControllerDictionary) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::StoreObjectsPreferences(mGroupsPreferences,
                                              kGroupsKey,
                                              aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientPreferencesController :: StoreZonesPreferences(NSMutableDictionary *aControllerDictionary) const
{
    Status  lRetval = kStatus_Success;

    lRetval = Detail::StoreObjectsPreferences(mZonesPreferences,
                                              kZonesKey,
                                              aControllerDictionary);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}
