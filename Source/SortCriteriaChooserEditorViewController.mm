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

#import "SortCriteriaChooserEditorViewController.h"

#include <LogUtilities/LogUtilities.hpp>

#include <OpenHLX/Utilities/Assert.hpp>

#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"


using namespace HLX::Common;
using namespace Nuovations;


@interface SortCriteriaChooserEditorViewController ()
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableApplicationControllerPointer             mApplicationController;

    SortCriteriaController *                        mSortCriteriaController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<ApplicationControllerDelegate>  mApplicationControllerDelegate;

    SortCriteriaControllerMode                      mSortCriteriaControllerMode;                  
}

@end

@implementation SortCriteriaChooserEditorViewController

// MARK: View Delegation

- (void) viewDidLoad
{
    NSString * lNavigationTitle = nullptr;

    [super viewDidLoad];

    switch (mSortCriteriaControllerMode)
    {

    case SortCriteriaControllerModeAdd:
        lNavigationTitle = NSLocalizedString(@"SortCriteriaChooserEditorTableViewControllerModeAddTitleKey", @"");
        break;

    case SortCriteriaControllerModeEdit:
        lNavigationTitle = NSLocalizedString(@"SortCriteriaChooserEditorTableViewControllerModeEditTitleKey", @"");
        break;

    default:
        break;
    };

    self.navigationItem.title = lNavigationTitle;
}

- (void) viewWillAppear: (BOOL)aAnimated
{
    Status     lStatus;


    [super viewWillAppear: aAnimated];

    lStatus = mApplicationController->SetDelegate(mApplicationControllerDelegate.get());
    nlREQUIRE_SUCCESS(lStatus, done);

done:
    return;
}

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder
{
    if (self = [super initWithCoder: aDecoder])
    {
        [self initCommon];
    }

    return (self);
}

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

    mSortCriteriaControllerMode = SortCriteriaControllerModeAdd;

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

    lStatus = mApplicationController->SetDelegate(nullptr);
    nlREQUIRE_SUCCESS(lStatus, done);

 done:
    return;
}

// MARK: Actions

// MARK: Setters

/**
 *  @brief
 *    Set the client controller and group for the view.
 *
 *  @param[in]  aApplicationController  A shared pointer
 *                                      to a mutable HLX client
 *                                      controller instance to use for
 *                                      this view controller.
 *
 */
- (void) setApplicationController: (MutableApplicationControllerPointer)aApplicationController;
{
    mApplicationController = aApplicationController;
}

- (void) setSortCriteriaController: (SortCriteriaController *)aSortCriteriaController
{
    mSortCriteriaController = aSortCriteriaController;
}

- (void) setSortCriteriaControllerMode: (const SortCriteriaControllerMode &)aSortCriteriaControllerMode
{
    mSortCriteriaControllerMode = aSortCriteriaControllerMode;
}

// MARK: Table View Data Source Delegation

- (void) tableView: (UITableView *)aTableView didSelectRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger                   lSection = aIndexPath.section;
    const NSUInteger                   lRow = aIndexPath.row;
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

@end
