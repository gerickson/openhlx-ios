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
 *    This file implements app lifetime management delegate overrides
 *    specific to this app as well as a global getter method.
 *
 */

#import "AppDelegate.h"

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "ConnectViewController.h"
#import "UIViewController+TopViewController.h"


using namespace HLX::Client;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;


@interface AppDelegate ()
{
    UIBackgroundTaskIdentifier mBackgroundTaskIdentifier;
}

@end

@implementation AppDelegate

/**
 *  @brief
 *    Tells the delegate that the launch process is almost done and
 *    the app is almost ready to run.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *  @param[in]  aLaunchOptions  A dictionary indicating the reason the
 *                              app was launched (if any). The contents
 *                              of this dictionary may be empty in
 *                              situations where the user launched the
 *                              app directly.
 *
 *  @retval  YES  If successful.
 *  @retval  NO   If unsuccessful.
 *
 */
- (BOOL) application: (UIApplication *)aApplication didFinishLaunchingWithOptions: (NSDictionary *)aLaunchOptions
{
    NSString *                      lVersion;
    NSUserDefaults *                lUserDefaults;
    HLX::Common::RunLoopParameters  lRunLoopParameters;
    Status                          lStatus = kStatus_Success;


    // Establish the app version from the main app bundle through
    // to the app settings bundle such that it can be found through
    // user navigation to General > <This App> > Version.

    lVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleShortVersionString"];

    if (lVersion != nullptr)
    {
        lUserDefaults = [NSUserDefaults standardUserDefaults];

        if (lUserDefaults != nullptr)
        {
            [lUserDefaults setObject: lVersion forKey: @"Version"];
        }
    }

    // Simply allocate and initialize a global, shared HLX client
    // controller instance.

    lStatus = lRunLoopParameters.Init([[NSRunLoop currentRunLoop] getCFRunLoop], kCFRunLoopCommonModes);
    nlREQUIRE_SUCCESS(lStatus, done);

    mApplicationController.reset(new HLX::Client::Application::Controller());
    nlREQUIRE(mApplicationController != nullptr, done);

    lStatus = mApplicationController->Init(lRunLoopParameters);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return ((lStatus == kStatus_Success) ? YES : NO);
}

/**
 *  @brief
 *    Tells the delegate that the app is about to become inactive.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *
 */
- (void) applicationWillResignActive: (UIApplication *)aApplication
{
    UIApplication *lApplication = [UIApplication sharedApplication];


    // The app is about to become inactive, which means eventually the
    // platform will tear down our connection to the HLX server and
    // reclaim those resources. Start a background task which will
    // proactively and gracefully disconnect from the HLX server when
    // that reclamation occurs.

    mBackgroundTaskIdentifier = [lApplication beginBackgroundTaskWithName: @"openhlx"
                                              expirationHandler: ^{
                                                  [self onBackgroundTaskExpired];
                                              }];
}

/**
 *  @brief
 *    Expiration handler for the background task begun when the app
 *    resigns its active state.
 *
 *  This proactively and gracefully disconnects from the HLX server
 *  before the platform reaps network resources out from under the
 *  application and the user is presented with some more
 *  ominous-sounding error.
 *
 *  @note
 *    In the future, the Disconnect client controller method might be
 *    augmented to take a user-supplied reason or error argument to
 *    which we might pass something akin to "platform terminated app"
 *    or some such thing.
 *
 */
- (void) onBackgroundTaskExpired
{
    UIApplication *lApplication = [UIApplication sharedApplication];


    mApplicationController->Disconnect();

    [lApplication endBackgroundTask: mBackgroundTaskIdentifier];

    mBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

/**
 *  @brief
 *    Tells the delegate that the app is now in the background.
 *
 *  Use this method to release shared resources, save user data,
 *  invalidate timers, and store enough application state information
 *  to restore your application to its current state in case it is
 *  terminated later.  If your application supports background
 *  execution, this method is called instead of
 *  applicationWillTerminate: when the user quits.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *
 *  @sa applicationWillTerminate
 */
- (void) applicationDidEnterBackground: (UIApplication *)aApplication
{
    return;
}

/**
 *  @brief
 *    Tells the delegate that the app is about to enter the
 *    foreground.
 *
 *  Called as part of the transition from the background to the active
 *  state; here you can undo many of the changes made on entering the
 *  background.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *
 */
- (void) applicationWillEnterForeground: (UIApplication *)aApplication
{
    return;
}

/**
 *  @brief
 *    Tells the delegate that the app has become active.
 *
 *  Restart any tasks that were paused (or not yet started) while
 *  the application was inactive. If the application was previously
 *  in the background, optionally refresh the user interface.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *
 */
- (void) applicationDidBecomeActive: (UIApplication *)aApplication
{
    UIApplication *lApplication = [UIApplication sharedApplication];

    // Ensure that the previously-started background task has truly
    // ended.

    [lApplication endBackgroundTask: mBackgroundTaskIdentifier];

    mBackgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

/**
 *  @brief
 *    Tells the delegate when the app is about to terminate.
 *
 *  Called when the application is about to terminate. Save data if
 *  appropriate.
 *
 *  @param[in]  aApplication    A pointer to the singleton applicatio
 *                              object for this app.
 *
 *  @sa applicationDidEnterBackground
 *
 */
- (void)applicationWillTerminate: (UIApplication *)aApplication
{
    return;
}

/**
 *  @brief
 *    Asks the delegate to open a resource specified by a URL, and
 *    provides a dictionary of launch options.
 *
 *  @param[in]  aApplication  A pointer to the application singleton.
 *  @param[in]  aURL          A pointer to the URL to open.
 *  @param[in]  aOptions      A pointer to an immutable dictionary or URL
 *                            handling options. This dictionary may
 *                            contain zero or more of the following
 *                            key/value pairs: @a
 *                            UIApplicationOpenURLOptionsSourceApplicationKey,
 *                            a key to a value that is the string of
 *                            the bundle ID of the app that sent the
 *                            openURL request to this app; @a
 *                            UIApplicationOpenURLOptionsAnnotationKey,
 *                            a key to a value that contains the
 *                            information passed to a document
 *                            interaction controller object's
 *                            annotation property; and
 *                            UIApplicationOpenURLOptionsOpenInPlaceKey,
 *                            a key to a value that is a Boolean
 *                            indicating whether a document must be
 *                            copied before you use it.
 *
 *  @returns
 *     YES if the delegate successfully handled the request or NO if
 *     the attempt to open the URL resource failed.
 *
 */
- (BOOL)application: (UIApplication *)aApplication openURL: (NSURL *)aURL options: (NSDictionary<UIApplicationOpenURLOptionsKey, id> *)aOptions
{
    NSString * lScheme = [aURL scheme];
    BOOL       lRetval = NO;

    if (mApplicationController->SupportsScheme((__bridge CFStringRef)lScheme))
    {
        NSString * const   lStoryboardName = @"Main";
        UIStoryboard *     lStoryboard;
        NSString *const    lViewControllerId = @"Connect View Controller";
        UIViewController * lViewController;


        // Load the connect view controller programmatically.

        lStoryboard = [UIStoryboard storyboardWithName: lStoryboardName
                                                bundle: nullptr];
        nlREQUIRE(lStoryboard != nullptr, done);

        lViewController = [lStoryboard instantiateViewControllerWithIdentifier: lViewControllerId];
        nlREQUIRE(lViewController != nullptr, done);

        // Present the refreshing view controller modally, consuming
        // the full screen.

        lViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        lViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;

        [[UIViewController topViewController] presentViewController: lViewController
                                                           animated: true
                                                         completion: ^(void) {
            [static_cast<ConnectViewController *>(lViewController) openURL: aURL];
        }];

        lRetval = YES;
    }

done:
    return (lRetval);
}

// MARK: Instance Methods

// MARK: Getters

/**
 *  @brief
 *    Get a shared pointer to the global app HLX client controller
 *    instance.
 *
 *  @returns
 *    A shared pointer to the global app HLX client controller
 *    instance.
 *
 */
- (MutableApplicationControllerPointer) hlxClientController
{
    return (mApplicationController);
}

@end
