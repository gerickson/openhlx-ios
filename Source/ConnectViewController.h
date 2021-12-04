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
 *    This file defines a view controller for connecting to a HLX
 *    server and for navigating to a history of
 *    previously-successfully connected HLX servers.
 *
 */

#ifndef CONNECTVIEWCONTROLLER_H
#define CONNECTVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "ApplicationControllerDelegate.hpp"
#import "ApplicationControllerPointer.hpp"
#import "RefreshViewController.h"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class ApplicationControllerDelegate;

@interface ConnectViewController : UIViewController <ApplicationControllerDelegate, UITextFieldDelegate, RefreshViewControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer             mApplicationController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;
}

// MARK: Properties

/**
 *  A pointer to the text label containing an optional app variant
 *  name, such as "Installer".
 *
 */
@property (weak, nonatomic) IBOutlet UILabel *      mAppVariantLabel;

/**
 *  A pointer to the text field containing a representation of the
 *  network location IP address, host name, or URL corresponding to
 *  the HLX server to connect to.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *  mNetworkAddressOrNameTextField;

/**
 *  A pointer to the user name text field. This is not used at
 *  present, but in the future is intended to contain a user name
 *  which would/might be used when an authenticated HLX server
 *  protocol other than telnet/hlxp are supported.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *  mUserNameTextField;

/**
 *  A pointer to the role text field. This is not used at present, but
 *  in the future is potentially intended to contain a role name (such
 *  as, installer, owner, resident, user, etc.) which would/might be
 *  used when an authenticated HLX server protocol other than
 *  telnet/hlxp are supported.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *  mRoleTextField;

/**
 *  A pointer to the user name credential text field. This is not used
 *  at present, but in the future is intended to contain a user name
 *  credential fields which would/might be used when an authenticated
 *  HLX server protocol other than telnet/hlxp are supported.
 *
 */
@property (weak, nonatomic) IBOutlet UITextField *  mCredentialTextField;

/**
 *  A pointer to the "Advanced" options switch. This is not used at
 *  present, but in the future is intended to reveal the name, role,
 *  and credential fields which would/might be used when an
 *  authenticated HLX server protocol other than telnet/hlxp are
 *  supported.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *     mAdvancedSwitch;

/**
 *  A pointer to the "Remember Me" switch. This is not used at
 *  present, but in the future is intended to signal whether a user
 *  name and credential should be remembered and cached in the
 *  keychain when an authenticated HLX server protocol other than
 *  telnet/hlxp are supported.
 *
 */
@property (weak, nonatomic) IBOutlet UISwitch *     mRememberMeSwitch;

/**
 *  A pointer to the connect button which initiates a connection to
 *  the HLX server described in @a mNetworkAddressOrNameTextField.
 *
 */
@property (weak, nonatomic) IBOutlet UIButton *     mConnectButton;

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

- (IBAction) onNetworkAddressOrNameTextFieldEditingChanged: (id)aSender;
- (IBAction) onAdvancedSwitchAction: (id)aSender;
- (IBAction) onRememberMeSwitchAction: (id)aSender;
- (IBAction) onConnectButtonAction: (id)aSender;
- (IBAction) onConnectHistoryButtonAction: (id)aSender;
- (IBAction) prepareForUnwind: (UIStoryboardSegue *)aSegue;

- (void) onConnectCancelled: (UIAlertAction *)aAlertAction;

// MARK: Workers

- (void) openNetworkAddressOrName: (NSString *)aNetworkAddressOrName;

@end

#endif // CONNECTVIEWCONTROLLER_H
