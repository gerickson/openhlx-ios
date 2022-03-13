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


#import <Foundation/NSDate.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

#import <OpenHLX/Client/ApplicationController.hpp>
#import <OpenHLX/Common/Errors.hpp>
#import <OpenHLX/Model/GroupModel.hpp>
#import <OpenHLX/Model/ZoneModel.hpp>

#import "ClientObjectsPreferencesModel.hpp"
#import "ClientPreferencesControllerDelegate.hpp"


class ClientPreferencesController
{
public:
    typedef bool FavoriteType;

public:
    ClientPreferencesController(void);
    ~ClientPreferencesController(void);

    // Initializers

    HLX::Common::Status Init(void);

    // Delegate Management

    ClientPreferencesControllerDelegate *GetDelegate(void) const;
    HLX::Common::Status SetDelegate(ClientPreferencesControllerDelegate *aDelegate);

    // Bind/unbind

    HLX::Common::Status Bind(const HLX::Client::Application::Controller &aController);
    HLX::Common::Status Unbind(void);

    // Mutators

    HLX::Common::Status Reset(void);
    HLX::Common::Status GroupReset(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier);
    HLX::Common::Status ZoneReset(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier);

    // Observers

    bool GroupHasPreferences(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier) const;
    bool ZoneHasPreferences(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier) const;

    // Getters

    HLX::Common::Status GroupGetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                         FavoriteType &aFavorite) const;
    HLX::Common::Status GroupGetLastUsedDate(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                             NSDate **aDate) const;
    HLX::Common::Status ZoneGetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                        FavoriteType &aFavorite) const;
    HLX::Common::Status ZoneGetLastUsedDate(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                            NSDate **aDate) const;

    // Setters

    // With implicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                         const FavoriteType &aFavorite);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                        const FavoriteType &aFavorite);

    // With explicit date

    HLX::Common::Status GroupSetFavorite(const HLX::Model::GroupModel::IdentifierType &aGroupIdentifier,
                                         const FavoriteType &aFavorite,
                                         NSDate *aDate);
    HLX::Common::Status ZoneSetFavorite(const HLX::Model::ZoneModel::IdentifierType &aZoneIdentifier,
                                        const FavoriteType &aFavorite,
                                        NSDate *aDate);

private:
    HLX::Common::Status LoadPreferences(void);
    HLX::Common::Status LoadPreferences(NSDictionary *aControllerDictionary);
    HLX::Common::Status LoadGroupsPreferences(NSDictionary *aControllerDictionary);
    HLX::Common::Status LoadZonesPreferences(NSDictionary *aControllerDictionary);

    HLX::Common::Status StorePreferences(void) const;
    HLX::Common::Status StorePreferences(NSMutableDictionary *aControllerDictionary) const;
    HLX::Common::Status StoreGroupsPreferences(NSMutableDictionary *aControllerDictionary) const;
    HLX::Common::Status StoreZonesPreferences(NSMutableDictionary *aControllerDictionary) const;

private:
    typedef ClientObjectsPreferencesModel ClientGroupsPreferencesModel;
    typedef ClientObjectsPreferencesModel ClientZonesPreferencesModel;

    NSString *                            mControllerIdentifier;
    ClientGroupsPreferencesModel          mGroupsPreferences;
    ClientGroupsPreferencesModel          mZonesPreferences;
    ClientPreferencesControllerDelegate*  mDelegate;
};
