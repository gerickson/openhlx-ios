/*
 *    Copyright (c) 2019-2021 Grant Erickson
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
 *    This file implements an Objective C/C++ protocol and an associated
 *    object that can act as a default HLX client controller delegate
 *    for other objects in the app.
 *
 */


#include "HLXClientControllerDelegate.hpp"


/**
 *  @brief
 *    This is a class constructor.
 *
 *  @param[in]  aObject  A pointer to an object, observing the
 *                       #HLXClientControllerDelegate protocol, to
 *                       initialize the class with.
 *
 */
HLXClientControllerDelegate :: HLXClientControllerDelegate(id<HLXClientControllerDelegate> aObject) :
    HLX::Client::ControllerDelegate(),
    mObject(aObject)
{
    return;
}

/**
 *  @brief
 *    This is the class destructor.
 *
 */
HLXClientControllerDelegate :: ~HLXClientControllerDelegate(void)
{
    return;
}

// MARK: Resolve Delegation Methods

/**
 *  @brief
 *    Delegation from the client controller that a host name will
 *    resolve.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the delegation.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that will resolve.
 *
 */
void
HLXClientControllerDelegate :: ControllerWillResolve(HLX::Client::Controller &aController, const char *aHost)
{
    const SEL lSelector = @selector(controllerWillResolve:withHost:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerWillResolve: aController
                              withHost: aHost];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a host name is
 *    resolving.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the delegation.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that is resolving.
 *
 */
void
HLXClientControllerDelegate :: ControllerIsResolving(HLX::Client::Controller &aController, const char *aHost)
{
    const SEL lSelector = @selector(controllerIsResolving:withHost:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerIsResolving: aController
                              withHost: aHost];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a host name has
 *    resolved to an IP address.
 *
 *  @note
 *    This delegation may be called more than once for a
 *    resolution, once for each IP address the host name resolves
 *    to.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the delegation.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that did resolve.
 *  @param[in]  aIPAddress          An immutable reference to an IP
 *                                  address that the host name
 *                                  resolved to.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidResolve(HLX::Client::Controller &aController, const char *aHost, const HLX::Common::IPAddress &aIPAddress)
{
    const SEL lSelector = @selector(controllerDidResolve:withHost:andAddress:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidResolve: aController
                             withHost: aHost
                           andAddress: aIPAddress];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a host name did
 *    not resolve.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the delegation.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that did not resolve.
 *  @param[in]  aError              An immutable reference to the error
 *                                  associated with the failed
 *                                  resolution.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidNotResolve(HLX::Client::Controller &aController,
                                                            const char *aHost,
                                                            const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerDidNotResolve:withHost:andError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidNotResolve: aController
                                withHost: aHost
                                andError: aError];
    }
}

// MARK: Connect Delegation Methods

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server will connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *  @param[in]  aTimeout     The timeout for the connection.
 *
 */
void
HLXClientControllerDelegate :: ControllerWillConnect(HLX::Client::Controller &aController, CFURLRef aURLRef, const HLX::Common::Timeout &aTimeout)
{
    const SEL lSelector = @selector(controllerWillConnect:withURL:andTimeout:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerWillConnect: aController
                               withURL: (__bridge NSURL *)aURLRef
                            andTimeout: aTimeout];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server is connecting.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *  @param[in]  aTimeout     The timeout for the connection.
 *
 */
void
HLXClientControllerDelegate :: ControllerIsConnecting(HLX::Client::Controller &aController, CFURLRef aURLRef, const HLX::Common::Timeout &aTimeout)
{
    const SEL lSelector = @selector(controllerIsConnecting:withURL:andTimeout:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerIsConnecting: aController
                                withURL: (__bridge NSURL *)aURLRef
                             andTimeout: aTimeout];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server did connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidConnect(HLX::Client::Controller &aController, CFURLRef aURLRef)
{
    const SEL lSelector = @selector(controllerDidConnect:withURL:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidConnect: aController
                              withURL: (__bridge NSURL *)aURLRef];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server did not connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failed connection.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidNotConnect(HLX::Client::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerDidNotConnect:withURL:andError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidNotConnect: aController
                                 withURL: (__bridge NSURL *)aURLRef
                                andError: aError];
    }
}

// MARK: Disconnect Delegation Methods

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server will disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *
 */
void
HLXClientControllerDelegate :: ControllerWillDisconnect(HLX::Client::Controller &aController, CFURLRef aURLRef)
{
    const SEL lSelector = @selector(controllerWillDisconnect:withURL:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerWillDisconnect: aController
                                  withURL: (__bridge NSURL *)aURLRef];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server did disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the disconnection.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidDisconnect(HLX::Client::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerDidDisconnect:withURL:andError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidDisconnect: aController
                                 withURL: (__bridge NSURL *)aURLRef
                                andError: aError];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a connection to a
 *    peer server did not disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aURLRef      The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failed
 *                           disconnection.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidNotDisconnect(HLX::Client::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerDidNotDisconnect:withURL:andError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidNotDisconnect: aController
                                    withURL: (__bridge NSURL *)aURLRef
                                   andError: aError];
    }
}

// MARK: Refresh Delegation Methods

/**
 *  @brief
 *    Delegation from the client controller that a state refresh
 *    with the peer server is about to begin.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *
 */
void
HLXClientControllerDelegate :: ControllerWillRefresh(HLX::Client::Controller &aController)
{
    const SEL lSelector = @selector(controllerWillRefresh:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerWillRefresh: aController];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a state refresh
 *    with the peer server is in progress.
 *
 *  @param[in]  aController       A reference to the client controller
 *                                that issued the delegation.
 *  @param[in]  aPercentComplete  A reference to the percentage
 *                                (0-100) of the refresh operation
 *                                that has completed.
 *
 */
void
HLXClientControllerDelegate :: ControllerIsRefreshing(HLX::Client::Controller &aController, const uint8_t &aPercentComplete)
{
    const SEL lSelector = @selector(controllerIsRefreshing:withProgress:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerIsRefreshing: aController
                           withProgress: aPercentComplete];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a state refresh
 *    with the peer server did complete successfully.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidRefresh(HLX::Client::Controller &aController)
{
    const SEL lSelector = @selector(controllerDidRefresh:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidRefresh: aController];
    }
}

/**
 *  @brief
 *    Delegation from the client controller that a state refresh
 *    with the peer server did not complete successfully.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failure to refresh.
 *
 */
void
HLXClientControllerDelegate :: ControllerDidNotRefresh(HLX::Client::Controller &aController, const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerDidNotRefresh:withError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerDidNotRefresh: aController
                               withError: aError];
    }
}

// MARK: State Change Delegation Method

/**
 *  @brief
 *    Delegation from the client controller that the controller
 *    state has changed in response to a change from the peer
 *    server controller.
 *
 *  @param[in]  aController               A reference to the
 *                                        client controller that
 *                                        issued the delegation.
 *  @param[in]  aStateChangeNotification  An immutable reference
 *                                        to a notification
 *                                        describing the state
 *                                        change.
 *
 */
void
HLXClientControllerDelegate :: ControllerStateDidChange(HLX::Client::Controller &aController, const HLX::Client::StateChange::NotificationBasis &aStateChangeNotification)
{
    const SEL lSelector = @selector(controllerStateDidChange:withNotification:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerStateDidChange: aController
                         withNotification: aStateChangeNotification];
    }
}

// MARK: Error Delegation Method

/**
 *  @brief
 *    Delegation from the client controller that the experienced
 *    an error.
 *
 *  @note
 *    This delegation may occur along with other delegations with
 *    respect to the same underlying event or cause.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the delegation.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the event.
 *
 */
void
HLXClientControllerDelegate :: ControllerError(HLX::Client::Controller &aController, const HLX::Common::Error &aError)
{
    const SEL lSelector = @selector(controllerError:withError:);

    if ([mObject respondsToSelector: lSelector])
    {
        [mObject controllerError: aController
                       withError: aError];
    }
}
