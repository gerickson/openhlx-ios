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

#import <Foundation/NSUserDefaults.h>

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace Detail
{

static NSString *
CreateControllerIdentifier(const HLX::Model::NetworkModel::EthernetEUI48Type &aEthernetEUI48)
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

}; // namespace Detail

ClientPreferencesController :: ClientPreferencesController(void) :
    mControllerIdentifier(nullptr)
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

Status
ClientPreferencesController :: Bind(const HLX::Client::Application::Controller &aController)
{
    DeclareScopedFunctionTracer(lTracer);
    NSString *                       lControllerIdentifier;
    NSDictionary *                   lControllerPreferences;
    NetworkModel::EthernetEUI48Type  lEthernetEUI48;
    Status                           lRetval = kStatus_Success;


    lRetval = aController.NetworkGetEthernetEUI48(lEthernetEUI48);
    nlREQUIRE_SUCCESS(lRetval, done);

    lControllerIdentifier = Detail::CreateControllerIdentifier(lEthernetEUI48);
    nlREQUIRE(lControllerIdentifier != nullptr, done);

    lControllerPreferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey: lControllerIdentifier];

    Log::Debug().Write("lControllerPreferences for %s is %p\n", [lControllerIdentifier UTF8String], lControllerPreferences);

    mControllerIdentifier = lControllerIdentifier;

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

#if 0
// Mutators

void
ClientPreferencesController :: Reset(void)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults removeObjectForKey: mControllerIdentifier];
}

void
ClientPreferencesController :: GroupReset(const GroupModel::IdentifierType &aGroupIdentifier)
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *controllerDefaults;
    NSString *groupIdentifier;
    NSDictionary *groupDefaults;

    controllerDefaults = [defaults dictionaryForKey: mControllerIdentifier];
    nlEXPECT(controllerDefaults != nullptr, done);



 done:
    return;
}

void
ClientPreferencesController :: ZoneReset(const ZoneModel::IdentifierType &aZoneIdentifier)
{

}
#endif // 0

// Getters

Status
ClientPreferencesController :: GroupGetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                                FavoriteType &aFavorite) const
{
    Status lRetval = kStatus_Success;

    aFavorite = false;

    return (lRetval);
}

Status
ClientPreferencesController :: GroupGetLastUsedDate(const GroupModel::IdentifierType &aGroupIdentifier,
                                                    NSDate **aDate) const
{
    Status lRetval = kStatus_Success;

    *aDate = [NSDate date];

    return (lRetval);
}

Status
ClientPreferencesController :: ZoneGetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               FavoriteType &aFavorite) const
{
    Status lRetval = kStatus_Success;

    aFavorite = false;

    return (lRetval);
}

Status
ClientPreferencesController :: ZoneGetLastUsedDate(const ZoneModel::IdentifierType &aZoneIdentifier,
                                                   NSDate **aDate) const
{
    Status lRetval = kStatus_Success;

    *aDate = [NSDate date];

    return (lRetval);
}

// Setters

// With controller identifier

// With implicit date

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

#if 0
Status
ClientPreferencesController :: GroupSetSource(const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute)
{

}
#endif // 0

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

#if 0
Status
ClientPreferencesController :: ZoneSetSource(const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute)
{

}
#endif // 0

// With explicit date

Status
ClientPreferencesController :: GroupSetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite,
                                                NSDate *aDate)
{
    Status lRetval = kStatus_Success;

    return (lRetval);
}

#if 0
Status
ClientPreferencesController :: GroupSetSource(const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier,
                              NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel,
                                   NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute,
                                  NSDate *aDate)
{

}
#endif // 0

Status
ClientPreferencesController :: ZoneSetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite,
                                               NSDate *aDate)
{
    Status lRetval = kStatus_Success;

    return (lRetval);
}

#if 0
Status
ClientPreferencesController :: ZoneSetSource(const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier,
                             NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel,
                                  NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute,
                                 NSDate *aDate)
{

}


ate:

// Mutators

// With controller identifier

void Reset(const NetworkModel::EthernetEUI48Type &aControllerIdentifier)
{

}

void GroupReset(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                const GroupModel::IdentifierType &aGroupIdentifier)
{

}

void ZoneReset(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
               const ZoneModel::IdentifierType &aZoneIdentifier)
{

}


// With controller identifier string

void Reset(NSString *aControllerIdentifier)
{

}

void GroupReset(NSString *aControllerIdentifier,
                const GroupModel::IdentifierType &aGroupIdentifier)
{

}

void ZoneReset(NSString *aControllerIdentifier,
               const ZoneModel::IdentifierType &aZoneIdentifier)
{

}


// Getters

// With controller identifier

Status
ClientPreferencesController :: GroupGetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                FavoriteType &aFavorite) const;
Status
ClientPreferencesController :: GroupGetLastUsedDate(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                    const GroupModel::IdentifierType &aGroupIdentifier,
                                    NSDate *&aDate) const;
Status
ClientPreferencesController :: ZoneGetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               FavoriteType &aFavorite) const;
Status
ClientPreferencesController :: ZoneGetLastUsedDate(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const ZoneModel::IdentifierType &aZoneIdentifier,
                                   NSDate *&aDate) const;

// With controller identifier string

Status
ClientPreferencesController :: GroupGetFavorite(NSString *aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                FavoriteType &aFavorite) const;
Status
ClientPreferencesController :: GroupGetLastUsedDate(NSString *aControllerIdentifier,
                                    const GroupModel::IdentifierType &aGroupIdentifier,
                                    NSDate *&aDate) const;
Status
ClientPreferencesController :: ZoneGetFavorite(NSString *aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               FavoriteType &aFavorite) const;
Status
ClientPreferencesController :: ZoneGetLastUsedDate(NSString *aControllerIdentifier,
                                   const ZoneModel::IdentifierType &aZoneIdentifier,
                                   NSDate *&aDate) const;

// Setters

// With controller identifier

// With implicit date

Status
ClientPreferencesController :: GroupSetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite)
{

}

Status
ClientPreferencesController :: GroupSetSource(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                              const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute)
{

}

Status
ClientPreferencesController :: ZoneSetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite)
{

}

Status
ClientPreferencesController :: ZoneSetSource(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                             const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                 const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute)
{

}


// With explicit date

Status
ClientPreferencesController :: GroupSetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite,
                                                NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetSource(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                              const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier,
                              NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel,
                                   NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute,
                                  NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite,
                                               NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetSource(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                             const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier,
                             NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel,
                                  NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                 const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute,
                                 NSDate *aDate)
{

}


// With controller identifier string

// With implicit date

Status
ClientPreferencesController :: GroupSetFavorite(NSString *aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite)
{

}

Status
ClientPreferencesController :: GroupSetSource(NSString *aControllerIdentifier,
                              const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(NSString *aControllerIdentifier,
                                   const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(NSString *aControllerIdentifier,
                                  const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute)
{

}

Status
ClientPreferencesController :: ZoneSetFavorite(NSString *aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite)
{

}

Status
ClientPreferencesController :: ZoneSetSource(NSString *aControllerIdentifier,
                             const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(NSString *aControllerIdentifier,
                                  const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(NSString *aControllerIdentifier,
                                 const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute)
{

}


// With explicit date

Status
ClientPreferencesController :: GroupSetFavorite(NSString *aControllerIdentifier,
                                                const GroupModel::IdentifierType &aGroupIdentifier,
                                                const FavoriteType &aFavorite,
                                                NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetSource(NSString *aControllerIdentifier,
                              const GroupModel::IdentifierType &aGroupIdentifier,
                              const SourceModel::IdentifierType &aSourceIdentifier,
                              NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeLevel(NSString *aControllerIdentifier,
                                   const GroupModel::IdentifierType &aGroupIdentifier,
                                   const VolumeModel::LevelType &aLevel,
                                   NSDate *aDate)
{

}

Status
ClientPreferencesController :: GroupSetVolumeMute(NSString *aControllerIdentifier,
                                  const GroupModel::IdentifierType &aGroupIdentifier,
                                  const VolumeModel::MuteType &aMute,
                                  NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetFavorite(NSString *aControllerIdentifier,
                                               const ZoneModel::IdentifierType &aZoneIdentifier,
                                               const FavoriteType &aFavorite,
                                               NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetSource(NSString *aControllerIdentifier,
                             const ZoneModel::IdentifierType &aZoneIdentifier,
                             const SourceModel::IdentifierType &aSourceIdentifier,
                             NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeLevel(NSString *aControllerIdentifier,
                                  const ZoneModel::IdentifierType &aZoneIdentifier,
                                  const VolumeModel::LevelType &aLevel,
                                  NSDate *aDate)
{

}

Status
ClientPreferencesController :: ZoneSetVolumeMute(NSString *aControllerIdentifier,
                                 const ZoneModel::IdentifierType &aZoneIdentifier,
                                 const VolumeModel::MuteType &aMute,
                                 NSDate *aDate)
{

}
#endif // 0
