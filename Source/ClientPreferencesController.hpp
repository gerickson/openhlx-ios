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


#import <Foundation/NSString.h>

#import <OpenHLX/Client/ApplicationController.hpp>
#import <OpenHLX/Common/Errors.hpp>


class ClientPreferencesController
{
public:
    ClientPreferencesController(void);
    ~ClientPreferencesController(void);

    // Initializers

    HLX::Common::Status Init(void);

    // Bind/unbind

    HLX::Common::Status Bind(const HLX::Client::Application::Controller &aController);
    HLX::Common::Status Unbind(void);

#if 0
    HLX::Common::Status Init(const HLX::Client::Application::Controller &aController);
    HLX::Common::Status Init(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier);
    HLX::Common::Status Init(NSString *aControllerIdentifier);

    // Mutators

    HLX::Common::Status Reset(void);
    HLX::Common::Status GroupReset(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier);
    HLX::Common::Status ZoneReset(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier);

    // Getters

    HLX::Common::Status GroupGetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    bool &aFavorite) const;
    HLX::Common::Status GroupGetLastUsedDate(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                        NSDate *&aDate) const;
    HLX::Common::Status ZoneGetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   bool &aFavorite) const;
    HLX::Common::Status ZoneGetLastUsedDate(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                       NSDate *&aDate) const;

    // Setters

    // With controller identifier

    // With implicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite);
    HLX::Common::Status GroupSetSource(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status GroupSetVolumeLevel(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status GroupSetVolumeMute(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite);
    HLX::Common::Status ZoneSetSource(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status ZoneSetVolumeLevel(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status ZoneSetVolumeMute(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute);

    // With explicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite,
                                    NSDate *aDate);
    HLX::Common::Status GroupSetSource(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                  NSDate *aDate);
    HLX::Common::Status GroupSetVolumeLevel(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel,
                                       NSDate *aDate);
    HLX::Common::Status GroupSetVolumeMute(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite,
                                   NSDate *aDate);
    HLX::Common::Status ZoneSetSource(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                 NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeLevel(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeMute(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute,
                                     NSDate *aDate);

private:

    // Mutators

    // With controller identifier

    HLX::Common::Status Reset(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier);
    HLX::Common::Status GroupReset(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier);
    HLX::Common::Status ZoneReset(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier);

    // With controller identifier string

    HLX::Common::Status Reset(NSString *aControllerIdentifier);
    HLX::Common::Status GroupReset(NSString *aControllerIdentifier,
                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier);
    HLX::Common::Status ZoneReset(NSString *aControllerIdentifier,
                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier);

    // Getters

    // With controller identifier

    HLX::Common::Status GroupGetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    bool &aFavorite) const;
    HLX::Common::Status GroupGetLastUsedDate(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                        const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                        NSDate *&aDate) const;
    HLX::Common::Status ZoneGetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   bool &aFavorite) const;
    HLX::Common::Status ZoneGetLastUsedDate(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                       const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                       NSDate *&aDate) const;
    
    // With controller identifier string
    
    HLX::Common::Status GroupGetFavorite(NSString *aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    bool &aFavorite) const;
    HLX::Common::Status GroupGetLastUsedDate(NSString *aControllerIdentifier,
                                        const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                        NSDate *&aDate) const;
    HLX::Common::Status ZoneGetFavorite(NSString *aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   bool &aFavorite) const;
    HLX::Common::Status ZoneGetLastUsedDate(NSString *aControllerIdentifier,
                                       const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                       NSDate *&aDate) const;

    // Setters

    // With controller identifier

    // With implicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite);
    HLX::Common::Status GroupSetSource(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status GroupSetVolumeLevel(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                       const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status GroupSetVolumeMute(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                      const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite);
    HLX::Common::Status ZoneSetSource(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                 const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status ZoneSetVolumeLevel(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                      const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status ZoneSetVolumeMute(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                     const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute);

    // With explicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite,
                                    NSDate *aDate);
    HLX::Common::Status GroupSetSource(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                  const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                  NSDate *aDate);
    HLX::Common::Status GroupSetVolumeLevel(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                       const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel,
                                       NSDate *aDate);
    HLX::Common::Status GroupSetVolumeMute(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                      const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite,
                                   NSDate *aDate);
    HLX::Common::Status ZoneSetSource(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                 const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                 NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeLevel(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                      const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeMute(const HLX::Model::NetworkModel::EthernetEUI48Type &aControllerIdentifier,
                                     const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute,
                                     NSDate *aDate);
    
    // With controller identifier string

    // With implicit date

    HLX::Common::Status GroupSetFavorite(NSString *aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite);
    HLX::Common::Status GroupSetSource(NSString *aControllerIdentifier,
                                  const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status GroupSetVolumeLevel(NSString *aControllerIdentifier,
                                       const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status GroupSetVolumeMute(NSString *aControllerIdentifier,
                                      const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute);
    HLX::Common::Status ZoneSetFavorite(NSString *aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite);
    HLX::Common::Status ZoneSetSource(NSString *aControllerIdentifier,
                                 const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier);
    HLX::Common::Status ZoneSetVolumeLevel(NSString *aControllerIdentifier,
                                      const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel);
    HLX::Common::Status ZoneSetVolumeMute(NSString *aControllerIdentifier,
                                     const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute);

    // With explicit date

    HLX::Common::Status GroupSetFavorite(NSString *aControllerIdentifier,
                                    const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                    const bool &aFavorite,
                                    NSDate *aDate);
    HLX::Common::Status GroupSetSource(NSString *aControllerIdentifier,
                                  const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                  const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                  NSDate *aDate);
    HLX::Common::Status GroupSetVolumeLevel(NSString *aControllerIdentifier,
                                       const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                       const HLX::Model::VolumeModel::LevelType &aLevel,
                                       NSDate *aDate);
    HLX::Common::Status GroupSetVolumeMute(NSString *aControllerIdentifier,
                                      const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                      const HLX::Model::VolumeModel::MuteType &aMute,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetFavorite(NSString *aControllerIdentifier,
                                   const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                   const bool &aFavorite,
                                   NSDate *aDate);
    HLX::Common::Status ZoneSetSource(NSString *aControllerIdentifier,
                                 const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                 const HLX::Model::SourceModel::IdentifierType &aSourceIdentifier,
                                 NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeLevel(NSString *aControllerIdentifier,
                                      const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                      const HLX::Model::VolumeModel::LevelType &aLevel,
                                      NSDate *aDate);
    HLX::Common::Status ZoneSetVolumeMute(NSString *aControllerIdentifier,
                                     const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                     const HLX::Model::VolumeModel::MuteType &aMute,
                                     NSDate *aDate);
#endif // 0

private:
    NSString * mControllerIdentifier;
};
