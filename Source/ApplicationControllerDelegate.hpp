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
 *    This file defines an Objective C/C++ protocol and an associated
 *    object that can act as a default HLX client controller delegate
 *    for other objects in the app.
 *
 */

#ifndef OBJC_APPLICATIONCONTROLLERDELEGATE_HPP
#define OBJC_APPLICATIONCONTROLLERDELEGATE_HPP

#include <CoreFoundation/CFURL.h>
#include <Foundation/Foundation.h>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Common/Timeout.hpp>


@protocol ApplicationControllerDelegate <NSObject>

@optional

// Resolve Methods

/**
 *  @brief
 *    Notification to the prtocol observer that a host name will
 *    resolve.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the notification.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that will resolve.
 *
 */
- (void) controllerWillResolve: (HLX::Client::Application::Controller &)aController
                      withHost: (const char *)aHost;

/**
 *  @brief
 *    Notification to the prtocol observer that a host name is
 *    resolving.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the notification.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that is resolving.
 *
 */
- (void) controllerIsResolving: (HLX::Client::Application::Controller &)aController
                      withHost: (const char *)aHost;

/**
 *  @brief
 *    Notification to the prtocol observer that a host name has
 *    resolved to an IP address.
 *
 *  @note
 *    This notification may be called more than once for a
 *    resolution, once for each IP address the host name resolves
 *    to.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the notification.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that did resolve.
 *  @param[in]  aIPAddress          An immutable reference to an IP
 *                                  address that the host name
 *                                  resolved to.
 *
 */
- (void) controllerDidResolve: (HLX::Client::Application::Controller &)aController
                     withHost: (const char *)aHost
                   andAddress: (const HLX::Common::IPAddress &)aIPAddress;

/**
 *  @brief
 *    Notification to the prtocol observer that a host name did
 *    not resolve.
 *
 *  @param[in]  aController         A reference to the client controller
 *                                  that issued the notification.
 *  @param[in]  aHost               A pointer to a null-terminated C
 *                                  string containing the host
 *                                  name that did not resolve.
 *  @param[in]  aError              An immutable reference to the error
 *                                  associated with the failed
 *                                  resolution.
 *
 */
- (void) controllerDidNotResolve: (HLX::Client::Application::Controller &)aController
                        withHost: (const char *)aHost
                        andError: (const HLX::Common::Error &)aError;

// Connect Methods

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server will connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *  @param[in]  aTimeout     The timeout for the connection.
 *
 */
- (void) controllerWillConnect: (HLX::Client::Application::Controller &)aController
                       withURL: (NSURL *)aURL
                    andTimeout: (const HLX::Common::Timeout &)aTimeout;

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server is connecting.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *  @param[in]  aTimeout     The timeout for the connection.
 *
 */
- (void) controllerIsConnecting: (HLX::Client::Application::Controller &)aController
                        withURL: (NSURL *)aURL
                     andTimeout: (const HLX::Common::Timeout &)aTimeout;

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server did connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *
 */
- (void) controllerDidConnect: (HLX::Client::Application::Controller &)aController
                      withURL: (NSURL *)aURL;

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server did not connect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failed connection.
 *
 */
- (void) controllerDidNotConnect: (HLX::Client::Application::Controller &)aController
                         withURL: (NSURL *)aURL
                        andError: (const HLX::Common::Error &)aError;

// Disconnect Methods

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server will disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *
 */
- (void) controllerWillDisconnect: (HLX::Client::Application::Controller &)aController
                          withURL: (NSURL *) aURL;

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server did disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the disconnection.
 *
 */
- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController
                         withURL: (NSURL *) aURL
                        andError: (const HLX::Common::Error &)aError;

/**
 *  @brief
 *    Notification to the prtocol observer that a connection to a
 *    peer server did not disconnect.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aURL         The URL associated with the peer server.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failed
 *                           disconnection.
 *
 */
- (void) controllerDidNotDisconnect: (HLX::Client::Application::Controller &)aController
                            withURL: (NSURL *) aURL
                           andError: (const HLX::Common::Error &) aError;

// Refresh / Reload Methods

/**
 *  @brief
 *    Notification to the prtocol observer that a state refresh
 *    with the peer server is about to begin.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *
 */
- (void) controllerWillRefresh: (HLX::Client::Application::ControllerBasis &)aController;

/**
 *  @brief
 *    Notification to the prtocol observer that a state refresh
 *    with the peer server is in progress.
 *
 *  @param[in]  aController       A reference to the client controller
 *                                that issued the notification.
 *  @param[in]  aPercentComplete  A reference to the percentage
 *                                (0-100) of the refresh operation
 *                                that has completed.
 *
 */
- (void) controllerIsRefreshing: (HLX::Client::Application::ControllerBasis &)aController
                   withProgress: (const uint8_t &)aPercentComplete;

/**
 *  @brief
 *    Notification to the prtocol observer that a state refresh
 *    with the peer server did complete successfully.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *
 */
- (void) controllerDidRefresh: (HLX::Client::Application::ControllerBasis &)aController;

/**
 *  @brief
 *    Notification to the prtocol observer that a state refresh
 *    with the peer server did not complete successfully.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the failure to refresh.
 *
 */
- (void) controllerDidNotRefresh:  (HLX::Client::Application::ControllerBasis &)aController
                       withError: (const HLX::Common::Error &)aError;

// State Change Method

/**
 *  @brief
 *    Notification to the prtocol observer that the controller
 *    state has changed in response to a change from the peer
 *    server controller.
 *
 *  @param[in]  aController               A reference to the
 *                                        client controller that
 *                                        issued the notification.
 *  @param[in]  aStateChangeNotification  An immutable reference
 *                                        to a notification
 *                                        describing the state
 *                                        change.
 *
 */
- (void) controllerStateDidChange: (HLX::Client::Application::Controller &)aController
                 withNotification: (const HLX::Client::StateChange::NotificationBasis &)aStateChangeNotification;

// Error Method

/**
 *  @brief
 *    Notification to the prtocol observer that the experienced
 *    an error.
 *
 *  @note
 *    This notification may occur along with other notifications with
 *    respect to the same underlying event or cause.
 *
 *  @param[in]  aController  A reference to the client controller that
 *                           issued the notification.
 *  @param[in]  aError       An immutable reference to the error
 *                           associated with the event.
 *
 */
- (void) controllerError: (HLX::Common::Application::ControllerBasis &)aController
               withError: (const HLX::Common::Error) aError;

@end

/**
 *  @brief
 *    An object that can act as a default HLX client controller
 *    delegate for other Objective C/C++ objects in the app.
 *
 *  This object can act as a default HLX client controller delegate
 *  for other Objective C/C++ objects in the app by instantiating this
 *  object with a pointer to the Objective C/C++ class object, so long
 *  as that object observes the ApplicationControllerDelegate protocol.
 *
 */
class ApplicationControllerDelegate :
    public HLX::Client::Application::ControllerDelegate
{
 public:
    ApplicationControllerDelegate(id<ApplicationControllerDelegate> aObject);
    virtual ~ApplicationControllerDelegate(void);

    // Resolve

    void ControllerWillResolve(HLX::Client::Application::Controller &aController, const char *aHost) final;
    void ControllerIsResolving(HLX::Client::Application::Controller &aController, const char *aHost) final;
    void ControllerDidResolve(HLX::Client::Application::Controller &aController, const char *aHost, const HLX::Common::IPAddress &aIPAddress) final;
    void ControllerDidNotResolve(HLX::Client::Application::Controller &aController, const char *aHost, const HLX::Common::Error &aError) final;

    // Connect

    void ControllerWillConnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef, const HLX::Common::Timeout &aTimeout) final;
    void ControllerIsConnecting(HLX::Client::Application::Controller &aController, CFURLRef aURLRef, const HLX::Common::Timeout &aTimeout) final;
    void ControllerDidConnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef) final;
    void ControllerDidNotConnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError) final;

    // Disconnect

    void ControllerWillDisconnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef) final;
    void ControllerDidDisconnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError) final;
    void ControllerDidNotDisconnect(HLX::Client::Application::Controller &aController, CFURLRef aURLRef, const HLX::Common::Error &aError) final;

    // Refresh / Reload

    void ControllerWillRefresh(HLX::Client::Application::ControllerBasis &aController) final;
    void ControllerIsRefreshing(HLX::Client::Application::ControllerBasis &aController, const uint8_t &aPercentComplete) final;
    void ControllerDidRefresh(HLX::Client::Application::ControllerBasis &aController) final;
    void ControllerDidNotRefresh(HLX::Client::Application::ControllerBasis &aController, const HLX::Common::Error &aError) final;

    // State Change

    void ControllerStateDidChange(HLX::Client::Application::Controller &aController, const HLX::Client::StateChange::NotificationBasis &aStateChangeNotification) final;

    // Error

    void ControllerError(HLX::Common::Application::ControllerBasis &aController, const HLX::Common::Error &aError) final;

 private:
    id<ApplicationControllerDelegate> mObject;
};

#endif // OBJC_APPLICATIONCONTROLLERDELEGATE_HPP
