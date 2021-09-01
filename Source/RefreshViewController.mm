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
 *    This file implements a view controller for refreshing the
 *    current state from a HLX server and indicating the activity and
 *    progress of that refresh.
 *
 */

#import "RefreshViewController.h"

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "GroupsAndZonesTableViewController.h"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


namespace HLX
{

namespace Client
{

class Controller;

};

};

@interface RefreshViewController ()
{

}

@end

@implementation RefreshViewController

// MARK: View Delegation

- (void) viewWillAppear: (BOOL)aAnimated
{
    const SEL lSelector = @selector(controllerWillAppear:);

    [super viewWillAppear: aAnimated];

    if (_mDelegate != nullptr)
    {
        if ([_mDelegate respondsToSelector: lSelector])
        {
            [_mDelegate controllerWillAppear: self];
        }
    }

    return;
}

- (void) viewDidAppear: (BOOL)aAnimated
{
    const SEL lSelector = @selector(controllerDidAppear:);


    [super viewDidAppear: aAnimated];

    if (_mDelegate != nullptr)
    {
        if ([_mDelegate respondsToSelector: lSelector])
        {
            [_mDelegate controllerDidAppear: self];
        }
    }

    return;
}

- (void) viewWillDisappear: (BOOL)aAnimated
{
    const SEL lSelector = @selector(controllerWillDisappear:);

    [super viewWillDisappear: aAnimated];

    if (_mDelegate != nullptr)
    {
        if ([_mDelegate respondsToSelector: lSelector])
        {
            [_mDelegate controllerWillDisappear: self];
        }
    }

    return;
}

- (void) viewDidDisappear: (BOOL)aAnimated
{
    const SEL lSelector = @selector(controllerDidDisappear:);

    [super viewDidDisappear: aAnimated];

    if (_mDelegate != nullptr)
    {
        if ([_mDelegate respondsToSelector: lSelector])
        {
            [_mDelegate controllerDidDisappear: self];
        }
    }

    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a refresh view controller from data in a
 *    decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized refresh view controller, if
 *    successful; otherwise, null.
 *
 */
- (id) initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [self initCommon];
    }

    return (self);
}

/**
 *  @brief
 *    Creates and initializes a refresh view controller with
 *    the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized refresh view controller, if
 *    successful; otherwise, null.
 *
 */
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle
{
    if (self = [super initWithNibName: aNibName
                               bundle: aNibBundle])
    {
        [self initCommon];
    }

    return (self);
}

/**
 *  @brief
 *    This performs common initialization.
 *
 */
- (void) initCommon
{
    return;
}

- (void) prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if (aSender == self)
    {
        if ([[aSegue identifier] isEqual: @"DidRefresh"])
        {
            UINavigationController *             lNavigationController = [aSegue destinationViewController];
            GroupsAndZonesTableViewController *  lGroupsAndZonesTableViewController = static_cast<GroupsAndZonesTableViewController *>(lNavigationController.topViewController);

            [lGroupsAndZonesTableViewController setApplicationController: mApplicationController];
        }
        else if ([[aSegue identifier] isEqual: @"DidDisconnect"])
        {
            // Nothing to do at this time.
        }
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler for the "Disconnect" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onDisconnectButtonAction: (id)aSender
{
    if (aSender == self.mDisconnectButton)
    {
        if (_mDelegate != nullptr)
        {
            const SEL lSelector = @selector(controllerShouldDisconnect:);

            if ([_mDelegate respondsToSelector: lSelector])
            {
                [_mDelegate controllerShouldDisconnect: self];
            }
        }
    }

    return;
}

// MARK: Workers

/**
 *  @brief
 *    This starts the view controller refresh activity.
 *
 *  This does so by activating both the indefinite activity and
 *  definite progress indicators, the latter with zero (0) percent
 *  progress.
 *
 */
- (void) startRefreshActivity
{
    const float lPercentComplete = 0.0f;

    // Start the activity indicator and set the activity progress
    // indicator to zero.

    [self.mRefreshActivityIndicator startAnimating];

    [self.mRefreshProgressIndicator setProgress: lPercentComplete
                                    animated: NO];
}

/**
 *  @brief
 *    This stops the view controller refresh activity.
 *
 *  This does so by deactivating both the indefinite activity and
 *  definite progress indicators.
 *
 */
- (void) stopRefreshActivity
{
    [self.mRefreshActivityIndicator stopAnimating];
}

/**
 *  @brief
 *    This updates the view controller refresh activity.
 *
 *  This does so by updating the definite progress indicator to the
 *  specified completion percentage.
 *
 *  @param[in]  aPercentComplete  An immutable reference to the percent
 *                                of the refresh activity complete in
 *                                the range [0.0, 1.0], inclusive.
 *
 */
- (void) updateRefreshProgress: (const float &)aPercentComplete
{
    [self.mRefreshProgressIndicator setProgress: aPercentComplete
                                       animated: YES];
}

@end
