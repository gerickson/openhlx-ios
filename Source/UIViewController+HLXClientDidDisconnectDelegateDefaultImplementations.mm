/*
 *    Copyright (c) 2020-2021 Grant Erickson
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
 *    This file implements extension class and instance methods to
 *    UIViewController for handling and presenting HLX client
 *    controller disconnect alerts in a consistent and common way.
 *
 */

#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>

#import "UIViewController+TopViewController.h"


using namespace HLX::Common;
using namespace Nuovations;


@implementation UIViewController (HLXClientDidDisconnectDelegateDefaultImplementations)

// MARK: HLX Client Controller Did Disconnect Delegate Default Implementations

/**
 *  @brief
 *    This logs a message and presents an alert dialog describing a HLX
 *    client disconnection from a HLX server.
 *
 *  This logs an error or informational message, depending on the
 *  value of @a aError, and presents an alert dialog with a single
 *  action, "OK", for the specified view controller regarding the HLX
 *  client disconnection from the HLX server associated with the
 *  specified URL. When the alert has been dismissed, the specified
 *  handler block is run.
 *
 *  @param[in]  aViewController  A pointer to the view controller
 *                               whose top-most view controller should
 *                               present the HLX client disconnection
 *                               alert.
 *  @param[in]  aURLRef          A pointer to the URL associated with
 *                               the HLX server that the client
 *                               disconnected from.
 *  @param[in]  aError           An immutable reference to the error
 *                               associated with the disconnection.
 *  @param[in]  aHandler         A block to execute when the user
 *                               selects the "OK" action for the
 *                               presented alert.
 *
 */
+ (void) viewPresentDidDisconnectAlert: (UIViewController *)aViewController withURL: (NSURL *)aURLRef andError: (const Error &)aError andHandler: (void (^ __nullable)(UIAlertAction *aAction))aHandler
{
    NSString *           lDescription;
    NSString *           lMessage;
    UIAlertAction *      lOKAction;
    UIAlertController *  lAlertController;

    if (aError < 0)
    {
        lDescription = [NSString stringWithUTF8String: strerror(-aError)];
        nlVERIFY(lDescription != nullptr);
    
        if (lDescription != nullptr)
        {
            Log::Error().Write("Disconnected from %s: %d (%s).\n",
                               [[aURLRef absoluteString] UTF8String],
                               aError,
                               [lDescription UTF8String]);


            lMessage = [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@: %@", @""), [aURLRef absoluteString], lDescription];
            nlVERIFY(lMessage != nullptr);
        }
    }
    else
    {
        Log::Info().Write("Disconnected from %s:\n",
                          [[aURLRef absoluteString] UTF8String]);


        lMessage = [NSString stringWithFormat: NSLocalizedString(@"Disconnected from %@", @""), [aURLRef absoluteString]];
        nlVERIFY(lMessage != nullptr);
    }

    // Present an alert describing, if appropriate, the error to the user.

    if (lMessage != nullptr)
    {
        lAlertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Disconnected", @"")
                                                               message: lMessage
                                                        preferredStyle: UIAlertControllerStyleAlert];
        nlVERIFY(lAlertController != nullptr);

        lOKAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"OK", @"")
                                             style: UIAlertActionStyleDefault
                                           handler: aHandler];
        nlVERIFY(lOKAction != nullptr);

        [lAlertController addAction: lOKAction];
            
        [[aViewController topViewController] presentViewController: lAlertController
                                                          animated: true
                                                        completion: nullptr];
    }
}

/**
 *  @brief
 *    This logs a message and presents an alert dialog describing a HLX
 *    client disconnection from a HLX server.
 *
 *  This logs an error or informational message, depending on the
 *  value of @a aError, and presents an alert dialog with a single
 *  action, "OK", for the specified view controller regarding the HLX
 *  client disconnection from the HLX server associated with the
 *  specified URL. When the alert has been dismissed, the specified
 *  segue is performed.
 *
 *  @param[in]  aViewController  A pointer to the view controller
 *                               whose top-most view controller should
 *                               present the HLX client disconnection
 *                               alert.
 *  @param[in]  aURLRef          A pointer to the URL associated with
 *                               the HLX server that the client
 *                               disconnected from.
 *  @param[in]  aError           An immutable reference to the error
 *                               associated with the disconnection.
 *  @param[in]  aNamedSegue      A string for segue identifier to
 *                               perform after the presented alert is
 *                               dismissed.
 *
 */
+ (void) viewPresentDidDisconnectAlert: (UIViewController *)aViewController withURL: (NSURL *)aURLRef andError: (const Error &)aError andNamedSegue: (NSString *)aNamedSegue
{
    [UIViewController viewPresentDidDisconnectAlert: aViewController
                                            withURL: aURLRef
                                           andError: aError
                                         andHandler: ^(UIAlertAction * aAction) {
        [aViewController performSegueWithIdentifier: aNamedSegue
                                             sender: aViewController];
    }];
}

/**
 *  @brief
 *    This logs a message and presents an alert dialog describing a HLX
 *    client disconnection from a HLX server.
 *
 *  This logs an error or informational message, depending on the
 *  value of @a aError, and presents an alert dialog with a single
 *  action, "OK", for the current view controller regarding the HLX
 *  client disconnection from the HLX server associated with the
 *  specified URL. When the alert has been dismissed, the specified
 *  handler block is run.
 *
 *  @param[in]  aURLRef          A pointer to the URL associated with
 *                               the HLX server that the client
 *                               disconnected from.
 *  @param[in]  aError           An immutable reference to the error
 *                               associated with the disconnection.
 *  @param[in]  aHandler         A block to execute when the user
 *                               selects the "OK" action for the
 *                               presented alert.
 *
 */
- (void) presentDidDisconnectAlert: (NSURL *)aURLRef withError: (const Error &)aError andHandler: (void (^ __nullable)(UIAlertAction *aAction))aHandler
{
    [UIViewController viewPresentDidDisconnectAlert: self
                                            withURL: aURLRef
                                           andError: aError
                                         andHandler: aHandler];
}

/**
 *  @brief
 *    This logs a message and presents an alert dialog describing a HLX
 *    client disconnection from a HLX server.
 *
 *  This logs an error or informational message, depending on the
 *  value of @a aError, and presents an alert dialog with a single
 *  action, "OK", for the current view controller regarding the HLX
 *  client disconnection from the HLX server associated with the
 *  specified URL. When the alert has been dismissed, the specified
 *  segue is performed.
 *
 *  @param[in]  aURLRef          A pointer to the URL associated with
 *                               the HLX server that the client
 *                               disconnected from.
 *  @param[in]  aError           An immutable reference to the error
 *                               associated with the disconnection.
 *  @param[in]  aNamedSegue      A string for segue identifier to
 *                               perform after the presented alert is
 *                               dismissed.
 *
 */
- (void) presentDidDisconnectAlert: (NSURL *)aURLRef withError: (const Error &)aError andNamedSegue: (NSString *)aNamedSegue
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                         andHandler: ^(UIAlertAction * aAction) {
        [self performSegueWithIdentifier: aNamedSegue
                                  sender: self];
    }];
}

@end
