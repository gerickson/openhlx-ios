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


#import <OpenHLX/Common/Errors.hpp>

#import "ApplicationControllerPointer.hpp"
#import "ClientPreferencesController.hpp"


class ClientController
{
public:
    ClientController(void) = default;
    ~ClientController(void) = default;

    HLX::Common::Status                 Init(void);

    MutableApplicationControllerPointer GetApplicationController(void);
    ClientPreferencesController &       GetPreferencesController(void);
    const ClientPreferencesController & GetPreferencesController(void) const;

private:
    MutableApplicationControllerPointer  mApplicationController;
    ClientPreferencesController          mPreferencesController;
};
