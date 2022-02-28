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
 *    This file defines a view controller for refreshing the current
 *    state from a HLX server and indicating the activity and progress
 *    of that refresh.
 *
 */

#include <memory>

#include <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ClientController.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

@protocol RefreshViewControllerDelegate;

@interface RefreshViewController : UIViewController <ApplicationControllerDelegate>
{
    /**
     *  A pointer to the global app HLX client controller instance.
     *
     */
    ClientController *                              mClientController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;
}

// MARK: Properties

/**
 *  A pointer to the disconnect button which initiates a disconnection
 *  from the connected HLX server.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *                 mDisconnectButton;

/**
 *  A pointer to the indefinite activity indicator that indicates
 *  server refresh activity is in progress.
 *
 *  @note
 *    The default telnet/hlxp protocol is sufficiently slow (that is,
 *    a complete state refresh takes on the order of 17 seconds) such
 *    that this indicator alone is insufficient to help the user
 *    anticipate progress and completion. Consequently, this is paired
 *    with a definite progress indicator.
 *
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *  mRefreshActivityIndicator;

/**
 *  A pointer to the definite progress indicator that indicates server
 *  refresh activity is in progress and how much of it is complete.
 *
 */
@property (weak, nonatomic) IBOutlet UIProgressView *           mRefreshProgressIndicator;

/**
 *  A pointer to the view controller delegate, observing the
 *  #RefreshViewControllerDelegate protocol.
 *
 */
@property (weak, nonatomic) id <RefreshViewControllerDelegate>  mDelegate;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onDisconnectButtonAction: (id)aSender;

// MARK: Workers

- (void) startRefreshActivity;
- (void) stopRefreshActivity;
- (void) updateRefreshProgress: (const float &)aPercentComplete;

@end

@protocol RefreshViewControllerDelegate <NSObject>

@optional

/**
 *  @brief
 *    Notifies the protocol observer that the refresh view is about to
 *    be added to a view hierarchy.
 *
 *  @param[in]  aController  A pointer to the refresh view controller
 *                           that is about to appear.
 *
 */
- (void) controllerWillAppear:        (RefreshViewController *)aController;

/**
 *  @brief
 *    Notifies the protocol observer that the refresh view was added
 *    to a view hierarchy.
 *
 *  @param[in]  aController  A pointer to the refresh view controller
 *                           that did appear.
 *
 */
- (void) controllerDidAppear:         (RefreshViewController *)aController;

/**
 *  @brief
 *    Notifies the protocol observer that the refresh view is about to
 *    be removed from a view hierarchy.
 *
 *  @param[in]  aController  A pointer to the refresh view controller
 *                           that is about to disappear.
 *
 */
- (void) controllerWillDisappear:     (RefreshViewController *)aController;

/**
 *  @brief
 *    Notifies the protocol observer that the refresh view was removed
 *    from a view hierarchy.
 *
 *  @param[in]  aController  A pointer to the refresh view controller
 *                           that did disappear.
 *
 */
- (void) controllerDidDisappear:      (RefreshViewController *)aController;

/**
 *  @brief
 *    Notifies the protocol observer that the refresh view has
 *    processed an intent to disconnect from the currently-connected
 *    HLX server.
 *
 *  The protocol observer should respond by disconnecting from the
 *  currently-connected HLX server.
 *
 *  @param[in]  aController  A pointer to the refresh view controller
 *                           that is indicating an intent to disconnect.
 *
 */
- (void) controllerShouldDisconnect:  (RefreshViewController *)aController;

@end
