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
 *    This file implements...
 *
 */

#import "GroupsOrZonesSortViewController.h"

#import <Foundation/Foundation.h>

#import <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Client/ApplicationController.hpp>
#include <OpenHLX/Client/ApplicationControllerDelegate.hpp>

#import "SortCriteriaController.h"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"


using namespace HLX;
using namespace HLX::Common;
using namespace Nuovations;


@interface GroupsOrZonesSortViewController ()
{
    /**
     *  A pointer to the global app HLX client controller instance.
     *
     */
    ClientController *                              mClientController;

    SortCriteriaController *                        mSortCriteriaController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;
}

@end

@implementation GroupsOrZonesSortViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status  lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mClientController->GetApplicationController()->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

    [self.tableView reloadData];

done:
    return;
}

// MARK: Initializers

/**
 *  @brief
 *    Creates and initializes a group or zone sort view controller
 *    from data in a decoder.
 *
 *  @param[in]  aDecoder  A pointer to the decoder for the archived or
 *                        encoded data to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone sort view controller,
 *    if successful; otherwise, null.
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
 *    Creates and initializes a group or zone sort view controller
 *    with the specified NIB name and bundle.
 *
 *  @param[in]  aNibName    A pointer to the name of the Interface
 *                          Builder NIB file to initialize with.
 *  @param[in]  aNibBundle  A pointer to the bundle containing @a
 *                          aNibName to initialize with.
 *
 *  @returns
 *    A pointer to the initialized group or zone sort view controller,
 *    if successful; otherwise, null.
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

done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
    Status lStatus;

    Log::Debug().Write("aSegue %p (%s) aSender %p (%s)\n",
                       aSegue, [[aSegue description] UTF8String],
                       aSender, [[aSender description] UTF8String]);

    lStatus = mClientController->GetApplicationController()->SetDelegate(nullptr);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

// MARK: Actions

- (IBAction) onEditButtonItemAction: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);

    if (aSender == self.mEditButtonItem)
    {
        const bool lIsEditing  = [self.tableView isEditing];
        const bool lIsAnimated = true;

        if (lIsEditing)
        {
            [self.navigationController setToolbarHidden: lIsEditing
                                               animated: lIsAnimated];

            [self.tableView setEditing: !lIsEditing
                              animated: lIsAnimated];

            [self.mEditButtonItem setTitle: NSLocalizedString(@"EditDoneEditTitleKey", @"")];
        }
        else
        {
            [self.mEditButtonItem setTitle: NSLocalizedString(@"EditDoneDoneTitleKey", @"")];

            [self.tableView setEditing: !lIsEditing
                              animated: lIsAnimated];

            [self.navigationController setToolbarHidden: lIsEditing
                                               animated: lIsAnimated];
        }
    }
}

// MARK: Setters

/**
 *  @brief
 *    Set the client controller for the view.
 *
 *  @param[in]  aClientController  A reference to an app client
 *                                 controller instance to use for
 *                                 this view controller.
 *
 */
- (void) setClientController: (ClientController &)aClientController
{
    mClientController = &aClientController;
}

- (void) setSortCriteriaController: (SortCriteriaController *)aSortCriteriaController
{
    mSortCriteriaController = aSortCriteriaController;
}

// MARK: Table View Data Source Delegation

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    static const NSInteger kNumberOfSections = 1;

    return (kNumberOfSections);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    NSInteger                        lRetval = 0;


    nlREQUIRE(aSection == 0, done);
    nlREQUIRE(mSortCriteriaController != nullptr, done);

    lRetval = [mSortCriteriaController count];

done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    NSString *         lCellIdentifier = @"Sort Criteria Table View Cell";
    UITableViewCell *  lRetval = nullptr;


    lRetval = [aTableView dequeueReusableCellWithIdentifier: lCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableCell: lRetval
                   forIndexPath: aIndexPath];

 done:
    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView moveRowAtIndexPath: (NSIndexPath *)aSourceIndexPath toIndexPath: (NSIndexPath *)aDestinationIndexPath
{
    DeclareScopedFunctionTracer(lTracer);
}

- (void) tableView: (UITableView *)aTableView commitEditingStyle: (UITableViewCellEditingStyle)aEditingStyle forRowAtIndexPath:(NSIndexPath *)aIndexPath
{
    DeclareScopedFunctionTracer(lTracer);
}

// MARK: Workers

- (void) configureReusableCell: (UITableViewCell *)aCell
                  forIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger  lSection = aIndexPath.section;
    const NSUInteger  lRow = aIndexPath.row;


    nlREQUIRE(lSection == 0, done);

    aCell.textLabel.text       = [mSortCriteriaController sortKeyDescriptionAtIndex: lRow];
    aCell.detailTextLabel.text = [mSortCriteriaController sortOrderDetailDescriptionAtIndex: lRow];

 done:
    return;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

@end
