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


using namespace HLX;
using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;


ClientPreferencesController :: ClientPreferencesController(void) :
    mControllerIdentifier(nullptr)
{
    return;
}

ClientPreferencesController :: ~ClientPreferencesController(void)
{
    return;
}

// Initializers

Status
ClientPreferencesController :: Init(void)
{
    Status lRetval = kStatus_Success;

    return (lRetval);
}

#if 0
Status
ClientPreferencesController :: Init(const Client::Application::Controller &aController)
{

}

Status
ClientPreferencesController :: Init(const NetworkModel::EthernetEUI48Type &aControllerIdentifier)
{

}

Status
ClientPreferencesController :: Init(NSString *aControllerIdentifier)
{
    mControllerIdentifier = [aControllerIdentifier retain];
}

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

// Getters

Status
ClientPreferencesController :: GroupGetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                bool &aFavorite) const;
Status
ClientPreferencesController :: GroupGetLastUsedDate(const GroupModel::IdentifierType &aGroupIdentifier,
                                    NSDate *&aDate) const;
Status
ClientPreferencesController :: ZoneGetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                               bool &aFavorite) const;
Status
ClientPreferencesController :: ZoneGetLastUsedDate(const ZoneModel::IdentifierType &aZoneIdentifier,
                                   NSDate *&aDate) const;

// Setters

// With controller identifier

// With implicit date

Status
ClientPreferencesController :: GroupSetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                const bool &aFavorite)
{

}

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

Status
ClientPreferencesController :: ZoneSetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                               const bool &aFavorite)
{

}

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


// With explicit date

Status
ClientPreferencesController :: GroupSetFavorite(const GroupModel::IdentifierType &aGroupIdentifier,
                                const bool &aFavorite,
                                NSDate *aDate)
{

}

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

Status
ClientPreferencesController :: ZoneSetFavorite(const ZoneModel::IdentifierType &aZoneIdentifier,
                               const bool &aFavorite,
                               NSDate *aDate)
{

}

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
                                bool &aFavorite) const;
Status
ClientPreferencesController :: GroupGetLastUsedDate(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                    const GroupModel::IdentifierType &aGroupIdentifier,
                                    NSDate *&aDate) const;
Status
ClientPreferencesController :: ZoneGetFavorite(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                               const ZoneModel::IdentifierType &aZoneIdentifier,
                               bool &aFavorite) const;
Status
ClientPreferencesController :: ZoneGetLastUsedDate(const NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const ZoneModel::IdentifierType &aZoneIdentifier,
                                   NSDate *&aDate) const;

// With controller identifier string

Status
ClientPreferencesController :: GroupGetFavorite(NSString *aControllerIdentifier,
                                const GroupModel::IdentifierType &aGroupIdentifier,
                                bool &aFavorite) const;
Status
ClientPreferencesController :: GroupGetLastUsedDate(NSString *aControllerIdentifier,
                                    const GroupModel::IdentifierType &aGroupIdentifier,
                                    NSDate *&aDate) const;
Status
ClientPreferencesController :: ZoneGetFavorite(NSString *aControllerIdentifier,
                               const ZoneModel::IdentifierType &aZoneIdentifier,
                               bool &aFavorite) const;
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
                                const bool &aFavorite)
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
                               const bool &aFavorite)
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
                                const bool &aFavorite,
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
                               const bool &aFavorite,
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
                                const bool &aFavorite)
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
                               const bool &aFavorite)
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
                                const bool &aFavorite,
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
                               const bool &aFavorite,
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

