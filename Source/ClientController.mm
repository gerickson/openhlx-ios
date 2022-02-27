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

#import <Foundation/NSRunLoop.h>

#import <OpenHLX/Client/ApplicationController.hpp>
#import <OpenHLX/Common/Errors.hpp>
#import <OpenHLX/Utilities/Assert.hpp>

#import "ClientController.hpp"


using namespace HLX;
using namespace HLX::Client;
using namespace HLX::Common;


Common::Status                      
ClientController :: Init(void)
{
    HLX::Common::RunLoopParameters  lRunLoopParameters;
    Status                          lRetval = kStatus_Success;


    lRetval = lRunLoopParameters.Init([[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
    nlREQUIRE_SUCCESS(lRetval, done);

    mApplicationController.reset(new HLX::Client::Application::Controller());
    nlREQUIRE(mApplicationController != nullptr, done);

    lRetval = mApplicationController->Init(lRunLoopParameters);
    nlREQUIRE_SUCCESS(lRetval, done);

    lRetval = mPreferencesController.Init();
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

MutableApplicationControllerPointer
ClientController :: GetApplicationController(void)
{
    return (mApplicationController);
}

ClientPreferencesController &
ClientController :: GetPreferencesController(void)
{
    return (mPreferencesController);
}

const ClientPreferencesController &
ClientController :: GetPreferencesController(void) const
{
    return (mPreferencesController);
}

