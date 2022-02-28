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
 *    This file implements a view controller for connecting to a HLX
 *    server and for navigating to a history of
 *    previously-successfully connected HLX servers.
 *
 */

#import "ConnectViewController.h"

#include <errno.h>
#include <string.h>

#include <Foundation/Foundation.h>

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>
#include <OpenHLX/Utilities/Assert.hpp>

#import "AppDelegate.h"
#import "ConnectHistoryController.h"
#import "ConnectHistoryViewController.h"
#import "GroupsAndZonesTableViewController.h"
#import "RefreshViewController.h"
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

@interface ConnectViewController ()
{
    UIAlertController *      mAlertController;
    RefreshViewController *  mRefreshController;
}

@end

@implementation ConnectViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    AppDelegate *lDelegate = static_cast<AppDelegate *>([[UIApplication sharedApplication] delegate]);

    [super viewDidLoad];

#if OPENHLX_INSTALLER
    self.mAppVariantLabel.hidden = NO;
#endif

    mClientController = &[lDelegate hlxClientController];
    nlREQUIRE(mClientController != nullptr, done);

    // Set ourselves as the delegate for the network address or name
    // text field such that we can respond to a return / go keyboard
    // event.

    [self.mNetworkAddressOrNameTextField setDelegate: self];

 done:
    return;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    ConnectHistoryController *  lSharedConnectHistoryController;


    [super viewWillAppear: aAnimated];

    lSharedConnectHistoryController = [ConnectHistoryController sharedController];
    nlEXPECT(lSharedConnectHistoryController != nullptr, done);

    if (![lSharedConnectHistoryController empty])
    {
        static const CGFloat  kConnectHistoryOverlayButtonPaddingViewWidth = 28;
        NSDictionary *        lConnectHistoryMostRecentEntry;
        UIView *              lConnectHistoryOverlayButtonPaddingView;
        UIButton *            lConnectHistoryOverlayButton;
        UIImage *             lConnectHistoryOverlayButtonImage;

        // First, attempt to populate the network address or name
        // field with the last connected location string.

        lConnectHistoryMostRecentEntry = [lSharedConnectHistoryController mostRecentEntry];

        if (lConnectHistoryMostRecentEntry)
        {
            NSString *lConnectHistoryMostRecentEntryLocation;

            lConnectHistoryMostRecentEntryLocation = [lConnectHistoryMostRecentEntry objectForKey: kConnectHistoryLocationKey];

            if (((self.mNetworkAddressOrNameTextField.text == nullptr) || ([self.mNetworkAddressOrNameTextField.text length] == 0)) && (lConnectHistoryMostRecentEntryLocation != nullptr))
            {
                self.mNetworkAddressOrNameTextField.text = lConnectHistoryMostRecentEntryLocation;
            }
        }
        
        // Second, generate and enable the network name or address
        // text field history overlay so that the user can explore and
        // manage the connect history and delete entries or choose
        // something other than the last connected location if they
        // wish.
        
        lConnectHistoryOverlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
        nlREQUIRE(lConnectHistoryOverlayButton != nullptr, done);

        lConnectHistoryOverlayButtonImage = [UIImage imageNamed: @"HistoryButton.png"];
        nlREQUIRE(lConnectHistoryOverlayButtonImage != nullptr, done);
        
        lConnectHistoryOverlayButtonPaddingView = [[UIView alloc] initWithFrame: CGRectMake(0,
                                                                                            0,
                                                                                            kConnectHistoryOverlayButtonPaddingViewWidth,
                                                                                            self.mNetworkAddressOrNameTextField.frame.size.height)];
        nlREQUIRE(lConnectHistoryOverlayButtonPaddingView != nullptr, done);

        [lConnectHistoryOverlayButton setImage: lConnectHistoryOverlayButtonImage
                                      forState: UIControlStateNormal];

        [lConnectHistoryOverlayButton setFrame: CGRectMake(0,
                                                           0,
                                                           lConnectHistoryOverlayButtonImage.size.width,
                                                           lConnectHistoryOverlayButtonImage.size.height)];

        [lConnectHistoryOverlayButton addTarget: self
                                      action: @selector(onConnectHistoryButtonAction:)
                                      forControlEvents: UIControlEventTouchUpInside];

        [lConnectHistoryOverlayButtonPaddingView addSubview: lConnectHistoryOverlayButton];

        lConnectHistoryOverlayButton.center = lConnectHistoryOverlayButtonPaddingView.center;

        // The clear text overlay button only should appear while editing.

        self.mNetworkAddressOrNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;

        // The alternate connect history overlay button should only appear unless editing.

        self.mNetworkAddressOrNameTextField.rightView       = lConnectHistoryOverlayButtonPaddingView;
        self.mNetworkAddressOrNameTextField.rightViewMode   = UITextFieldViewModeUnlessEditing;
    }

 done:
    // If there is something in the network address or name text field
    // and we are not presently connected, then enable the connect
    // button.
    //
    // The disconnected check is essential since there are times when
    // this controller will temporarily be visible while connected.

    if (((self.mNetworkAddressOrNameTextField.text != nullptr) && ([self.mNetworkAddressOrNameTextField.text length] > 0)) && !mClientController->GetApplicationController()->IsConnected())
    {
        self.mConnectButton.enabled = YES;
    }

    mClientController->GetApplicationController()->SetDelegate(mApplicationControllerDelegate.get());

    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a connect view controller from data in a
 *    decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized connect view controller, if
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
 *    Creates and initializes a connect view controller with
 *    the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized connect view controller, if
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
    mApplicationControllerDelegate.reset(new ApplicationControllerDelegate(self));
    nlREQUIRE(mApplicationControllerDelegate != nullptr, done);

    mAlertController = nullptr;
    mRefreshController = nullptr;

 done:
    return;
}

// MARK: Text Field Delegation

- (BOOL) textFieldShouldReturn: (UITextField *)aTextField
{
    BOOL lRetval = NO;

    if (aTextField == self.mNetworkAddressOrNameTextField)
    {
        // Hide the keyboard

        [aTextField resignFirstResponder];

        // Initiate the connect button action
        
        [self onConnectButtonAction: aTextField];
    }

done:
    return (lRetval);
}

- (void) prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    if (aSender == self)
    {
        if ([[aSegue identifier] isEqual: @"DidRefresh"])
        {
            UINavigationController *             lNavigationController = [aSegue destinationViewController];
            GroupsAndZonesTableViewController *  lGroupsAndZonesTableViewController = static_cast<GroupsAndZonesTableViewController *>(lNavigationController.topViewController);

            [lGroupsAndZonesTableViewController setClientController: *mClientController];
        }
    }

 done:
    return;
}

// MARK: Actions

/**
 *  @brief
 *    This is the action handler network address, name, or URL text
 *    field editing changed event.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction)onNetworkAddressOrNameTextFieldEditingChanged: (id)aSender
{
    if (aSender == self.mNetworkAddressOrNameTextField)
    {
        // If there is any content in the text field, then enable the
        // connect button. Otherwise, disable the connect button.
        //
        // Validation of the content will happen when a connection is
        // triggered via the onConnectButtonAction: method.

        const BOOL lEmpty = (((UITextField *)(aSender)).text.length == 0);

        self.mConnectButton.enabled = !lEmpty;
    }
}

/**
 *  @brief
 *    This is the action handler for the "Advanced" switch.
 *
 *  @note
 *    This is presently unused.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction)onAdvancedSwitchAction: (id)aSender
{
    if (aSender == self.mAdvancedSwitch)
    {
        const BOOL lOn = ((UISwitch *)(aSender)).on;

        // Enable/disable the advanced fields.

        self.mUserNameTextField.enabled   = lOn;
        self.mRoleTextField.enabled       = lOn;
        self.mCredentialTextField.enabled = lOn;

        // Unhide/hide the advanced fields.

        self.mUserNameTextField.hidden    = !lOn;
        self.mRoleTextField.hidden        = !lOn;
        self.mCredentialTextField.hidden  = !lOn;
    }
}

/**
 *  @brief
 *    This is the action handler for the "Remember Me" switch.
 *
 *  @note
 *    This is presently unused.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction)onRememberMeSwitchAction: (id)aSender
{
    return;
}

/**
 *  @brief
 *    This is the action handler for the "Connect" button.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onConnectButtonAction: (id)aSender
{
    // The user may either click the "Connect" button or hit enter or
    // "go" in the text entry keyboard.

    if ((aSender == self.mConnectButton) || (aSender == self.mNetworkAddressOrNameTextField))
    {
        NSString *lNetworkAddressOrName = nullptr;

        lNetworkAddressOrName = self.mNetworkAddressOrNameTextField.text;
        nlREQUIRE(lNetworkAddressOrName != nullptr, done);

        [self openNetworkAddressOrName: lNetworkAddressOrName];
    }

 done:
    return;
}

/**
 *  @brief
 *    This is the action handler for the connect history overlay
 *    button in the network address, name, or URL text field.
 *
 *  @param[in]  aSender  The entity that triggered this action handler.
 *
 */
- (IBAction) onConnectHistoryButtonAction: (id)aSender
{
    [self performSegueWithIdentifier: @"OnConnectHistory"
          sender: self];

    return;
}

/**
 *  @brief
 *    This is the "will unwind" delegation handler.
 *
 *  This handles a segue from another view controller that is about to
 *  unwind to reveal this view controller.
 *
 *  @param[in]  aSegue  A pointer to the segue that is triggering
 *                      the unwind to reveal this view controller.
 *
 */
- (IBAction) prepareForUnwind: (UIStoryboardSegue *)aSegue
{
    if ([aSegue.identifier isEqualToString: @"OnExitConnectHistory"])
    {
        ConnectHistoryViewController *lConnectHistoryViewController = static_cast<ConnectHistoryViewController *>(aSegue.sourceViewController);

        self.mNetworkAddressOrNameTextField.text = lConnectHistoryViewController.mSelectedNetworkAddressOrName;
    }

    return;
}

/**
 *  @brief
 *    This is the action handler for the connect progress alert
 *    "Cancel" button action.
 *
 *  @param[in]  aAlertAction  A pointer to the "Cancel" button
 *                            alert action that triggered this
 *                            handler.
 *
 */
- (void) onConnectCancelled: (UIAlertAction *)aAlertAction
{
    mClientController->GetApplicationController()->Disconnect();
}

// MARK: Workers

/**
 *  @brief
 *    Attempt to open (that is, connect to) the HLX server with the
 *    specified IP address, host name, IP address and port, host name
 *    and port, or URL.
 *
 *  @param[in]  aNetworkAddressOrName  A pointer to a string containing
 *                                     the IP address, host name, IP
 *                                     address and port, host name
 *                                     and port, or URL of the HLX
 *                                     server to open (that is,
 *                                     connect to).
 *
 */
- (void) openNetworkAddressOrName: (NSString *)aNetworkAddressOrName
{
    Status lStatus;

    nlREQUIRE(aNetworkAddressOrName != nullptr, done);
    nlREQUIRE([aNetworkAddressOrName length] > 0, done);

    // Disable the connect button while connecting.

    self.mConnectButton.enabled = NO;

    lStatus = mClientController->GetApplicationController()->Connect([aNetworkAddressOrName UTF8String]);
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

/**
 *  @brief
 *    Attempt to open (that is, connect to) the HLX server with the
 *    specified URL.
 *
 *  @note
 *    This will close (that is, disconnect) any existing HLX server
 *    connection and will populate the @a
 *    mNetworkAddressOrNameTextField field with the URL.
 *
 *  @param[in]  aURL  A pointer to the URL of the HLX server to open
 *                    (that is, connect to).
 *
 */
- (void) openURL: (NSURL *)aURL
{
    NSString *lNetworkAddressOrNameString = [aURL absoluteString];

    // Disconnect from any existing HLX server that might currently be
    // connected.

    mClientController->GetApplicationController()->Disconnect();

    // Populate the network address or name text field such that the
    // connection history is correctly populated if the connection is
    // successful and such that the user has visibility into what URL
    // is being opened.

    self.mNetworkAddressOrNameTextField.text = lNetworkAddressOrNameString;

    // Peform the actual open (that is, connection).

    [self openNetworkAddressOrName: lNetworkAddressOrNameString];
}

- (void) controllerWillResolve: (HLX::Client::Application::Controller &)aController withHost: (const char *)aHost
{
    Log::Info().Write("Will resolve \"%s\".\n", aHost);
}

- (void) controllerIsResolving: (HLX::Client::Application::Controller &)aController withHost: (const char *)aHost
{
    Log::Info().Write("Is resolving \"%s\".\n", aHost);
}

- (void) controllerDidResolve: (HLX::Client::Application::Controller &)aController withHost: (const char *)aHost andAddress: (const HLX::Common::IPAddress &)aIPAddress
{
    char   lBuffer[INET6_ADDRSTRLEN];
    Status lStatus;

    lStatus = aIPAddress.ToString(lBuffer, sizeof (lBuffer));
    nlREQUIRE_SUCCESS(lStatus, done);

    Log::Info().Write("Did resolve \"%s\" to '%s'.\n", aHost, lBuffer);

 done:
    return;
}

- (void) controllerDidNotResolve: (HLX::Client::Application::Controller &)aController withHost: (const char *)aHost andError: (const HLX::Common::Error &)aError
{
    Log::Error().Write("Did not resolve \"%s\": %d (%s).\n", aHost, aError, strerror(-aError));
}

- (void) controllerWillConnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andTimeout: (const HLX::Common::Timeout &)aTimeout
{
    UIAlertController *lAlertController;
    UIAlertAction     *lCancelAction;


    Log::Info().Write("Will connect to %s with %u ms timeout.\n",
                      [[aURLRef absoluteString] UTF8String],
                      aTimeout.GetMilliseconds());

    // If we are here, then there was something in the network
    // address or name text field that the user wants the app to
    // try to connect to. Start the connection process.

    lAlertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Connecting", @"")
                                          message: [aURLRef absoluteString]
                                          preferredStyle: UIAlertControllerStyleAlert];

    lCancelAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", @"")
                                   style: UIAlertActionStyleCancel
                                   handler: ^(UIAlertAction * aAction) {
        [self onConnectCancelled: aAction];
    }];

    [lAlertController addAction: lCancelAction];

    mAlertController = lAlertController;

    [self.topViewController presentViewController: mAlertController
                                         animated: true
                                       completion: nullptr];

    return;
}

- (void) controllerIsConnecting: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andTimeout: (const HLX::Common::Timeout &)aTimeout
{
    Log::Info().Write("Connecting to %s with %u ms timeout.\n",
                      [[aURLRef absoluteString] UTF8String],
                      aTimeout.GetMilliseconds());
}

- (void) controllerDidConnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef
{
    NSDate *                    lDateNow = [NSDate date];
    ConnectHistoryController *  lSharedConnectHistoryController;
    bool                        lStatus;


    Log::Info().Write("Connected to %s.\n", [[aURLRef absoluteString] UTF8String]);

    // Attempt to retrieve the shared connect history controller.

    lSharedConnectHistoryController = [ConnectHistoryController sharedController];
    nlEXPECT(lSharedConnectHistoryController != nullptr, segue);

    // If there is no connect history, then this will be the first
    // entry. Otherwise, if this location is in the history, update
    // the last connected time. If not, add an entry to the array.
    //
    // Note that we explicitly and intentionally want the history to
    // contain what the user entered ('mNetworkAddressOrNameTextField'),
    // whether an IP address, host name, IP address and port, host
    // name and port, or URL, rather than what the user entered was
    // resolved to, which is what the 'aURLRef' parameter is.

    lStatus = [lSharedConnectHistoryController addOrUpdateEntry: self.mNetworkAddressOrNameTextField.text
                                                        andDate: lDateNow];
    nlREQUIRE(lStatus == true, segue);

 segue:
    // The first thought implementation here might be to simply
    // dismiss the modal connection progress alert that may be present
    // and to initiate a client controller refresh in the completion
    // block. Following that, in controllerWillRefresh, initiating the
    // refresh controller view to handle the refresh progress
    // update. If the client controller is talking to the actual
    // HLX hardware using its character-at-a-time I/O, then the latency
    // of that is sufficiently long (TENS of seconds) that the timing
    // works out.
    //
    // However, if the client controller is talking to a proxy using
    // line- or buffer-at-a-time I/O, then the latency of that is
    // sufficiently short (TENTHS of a second), that the refresh is
    // started and done before the UI even has a chance to react and
    // the application gets into a dead-end state.
    //
    // Consequently, to make both cases work, after dismissing the
    // modal connection progress alert, we FIRST initiate the refresh
    // controller view and THEN we start the client controller
    // refresh in the refresh controller's controllerDidAppear delegate
    // method.

    [mAlertController dismissViewControllerAnimated: NO
                                         completion: ^(void) {
        NSString * const lStoryboardName = @"Main";
        UIStoryboard *lStoryboard;
        NSString *const lViewControllerId = @"Refresh Controller";
        UIViewController *lViewController;


        // Load the refreshing view controller programmatically.

        lStoryboard = [UIStoryboard storyboardWithName: lStoryboardName
                                                bundle: nullptr];
        nlREQUIRE(lStoryboard != nullptr, done);

        lViewController = [lStoryboard instantiateViewControllerWithIdentifier: lViewControllerId];
        nlREQUIRE(lViewController != nullptr, done);

        self->mRefreshController = static_cast<RefreshViewController *>(lViewController);
        self->mRefreshController.mDelegate = self;

        // Present the refreshing view controller modally, consuming
        // the full screen.

        lViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        lViewController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;

        [self.topViewController presentViewController: lViewController
                                             animated: true
                                           completion: nullptr];

    done:
        return;
    }];
}

- (void) controllerDidNotConnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    NSString *    lDescription;

    lDescription = [NSString stringWithUTF8String: strerror(-aError)];

    Log::Error().Write("Did not connect to %s: %d (%s).\n",
                       [[aURLRef absoluteString] UTF8String],
                       aError,
                       [lDescription UTF8String]);

    // At this point, the modal connection progress alert controller
    // posted in controllerWillConnect is still up and needs to be
    // dismissed before another alert controller describing the
    // connect failure can be presented. Dismiss the prior alert
    // controller, triggering presentation of the new alert controller
    // on the completion.

    [mAlertController dismissViewControllerAnimated: NO
                                         completion: ^(void) {
        [self didNotConnectWithURL: aURLRef
              andError: aError
              withDescription: lDescription];

        // At this point, the connect button was disabled to handle
        // the connect; re-enable it.

        self.mConnectButton.enabled = YES;
    }];
}

- (void) controllerWillRefresh: (HLX::Client::Application::ControllerBasis &)aController
{
    DeclareLogIndentWithValue(lLogIndent, 0);
    DeclareLogLevelWithValue(lLogLevel, 1);

    LogDebug(lLogIndent,
             lLogLevel,
             "Waiting for client data...\n");
}

- (void) controllerIsRefreshing: (HLX::Client::Application::ControllerBasis &)aController withProgress: (const uint8_t &)aPercentComplete
{
    DeclareLogIndentWithValue(lLogIndent, 0);
    DeclareLogLevelWithValue(lLogLevel, 1);
    const float lPercentComplete = aPercentComplete / 100.0f;

    LogDebug(lLogIndent,
             lLogLevel,
             "%hhu%% of client data received.\n", aPercentComplete);

    [mRefreshController updateRefreshProgress: lPercentComplete];
}

- (void) controllerDidRefresh: (HLX::Client::Application::ControllerBasis &)aController
{
    DeclareLogIndentWithValue(lLogIndent, 0);
    DeclareLogLevelWithValue(lLogLevel, 1);
    AppDelegate *  lDelegate = static_cast<AppDelegate *>([[UIApplication sharedApplication] delegate]);
    Status         lStatus;

    LogDebug(lLogIndent,
             lLogLevel,
             "Client data received...\n");

    // Stop the refresh view controller activity.

    [mRefreshController stopRefreshActivity];

    // Bind the preferences controller to the application controller
    // identifier for the connection.

    lStatus = [lDelegate hlxPreferencesController].Bind(*mClientController->GetApplicationController());
    nlREQUIRE_SUCCESS(lStatus, dismiss);

 dismiss:
    // Dismiss the refreshing view controller and segue to the 'did
    // refresh' transition on completion of the dismissal.

    [mRefreshController dismissViewControllerAnimated: NO
                                         completion: ^(void) {
        [self performSegueWithIdentifier: @"DidRefresh"
              sender: self];

        self->mRefreshController.mDelegate = nullptr;
        self->mRefreshController = nullptr;
    }];
}

- (void) controllerWillDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef
{
    Log::Info().Write("Will disconnect from %s.\n", [[aURLRef absoluteString] UTF8String]);
}

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    if (self->mRefreshController != nullptr)
    {
        [RefreshViewController viewPresentDidDisconnectAlert: self->mRefreshController
                                withURL: aURLRef
                               andError: aError
                             andHandler: ^(UIAlertAction * aAction) {
            // Stop the refresh view controller activity.

            [self->mRefreshController stopRefreshActivity];

            // Dismiss the refreshing view controller

            [self->mRefreshController dismissViewControllerAnimated: NO
                                                   completion: ^(void) {
                self->mRefreshController.mDelegate = nullptr;
                self->mRefreshController           = nullptr;
            }];
        }];
    }

    // We are now disconnected; re-enable the connect button.
    
    self.mConnectButton.enabled = YES;
}

// MARK: Refresh View Controller Delegations

- (void) controllerDidAppear: (RefreshViewController *)aController
{
    Status lStatus;

    [self->mRefreshController startRefreshActivity];

    lStatus = self->mClientController->GetApplicationController()->Refresh();
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

- (void) controllerShouldDisconnect: (RefreshViewController *)aController
{
    // Stop the refresh view controller activity.

    [aController stopRefreshActivity];

    mClientController->GetApplicationController()->Disconnect();
}

// MARK: Workers

- (void) didNotConnectWithURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError withDescription: (NSString *)aDescription
{
    UIAlertController *lAlertController;
    UIAlertAction     *lOKAction;
    NSString          *lError;

    // Present an alert deescribing the error to the user along with
    // some potentially actionable course correction.

    lError = [NSString stringWithFormat: NSLocalizedString(@"Could not connect to %@: %@", @""), [aURLRef absoluteString], aDescription];
    nlREQUIRE(lError != nullptr, done);

    lAlertController = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Did Not Connect", @"")
                                          message: lError
                                          preferredStyle: UIAlertControllerStyleAlert];
    nlREQUIRE(lAlertController != nullptr, done);

    lOKAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"OK", @"")
                               style: UIAlertActionStyleDefault
                               handler: nullptr];
    nlREQUIRE(lOKAction != nullptr, done);

    [lAlertController addAction: lOKAction];

    mAlertController = lAlertController;

    [self.topViewController presentViewController: mAlertController
                                         animated: true
                                       completion: nullptr];

 done:
    return;
}

@end
