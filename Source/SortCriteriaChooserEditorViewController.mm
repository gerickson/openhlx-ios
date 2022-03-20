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

#import "SortParameter_Detail.hpp"
#import "UIViewController+HLXClientDidDisconnectDelegateDefaultImplementations.h"
#import "UIViewController+TopViewController.h"


using namespace HLX::Common;
using namespace Nuovations;


namespace Detail
{

// MARK: Type Definitions

typedef NS_ENUM(NSUInteger, TableSection)
{
    kTableSection_Min   = 0,

    kTableSection_Key   = kTableSection_Min,
    kTableSection_Order,

    kTableSection_Max,
    kTableSection_Count = kTableSection_Max
};

}; // namespace Detail

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
    
    NSInteger                                       mInitiallySelectedSortKey;
    NSInteger                                       mCurrentlySelectedSortKey;
    NSInteger                                       mInitiallySelectedSortOrder;
    NSInteger                                       mCurrentlySelectedSortOrder;
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
    mInitiallySelectedSortKey   = NSNotFound;
    mCurrentlySelectedSortKey   = NSNotFound;
    mInitiallySelectedSortOrder = NSNotFound;
    mCurrentlySelectedSortOrder = NSNotFound;

done:
    return;
}

- (void)prepareForSegue: (UIStoryboardSegue *)aSegue sender: (id)aSender
{
    DeclareScopedFunctionTracer(lTracer);
    Status lStatus;

    Log::Debug().Write("aSegue %p (%s) aSender %p (%s)\n",
                       aSegue, [[aSegue identifier] UTF8String],
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

- (NSInteger) numberOfSectionsInTableView: (UITableView *)aTableView
{
    return (Detail::TableSection::kTableSection_Count);
}

- (NSString *) tableView: (UITableView *)aTableView titleForHeaderInSection: (NSInteger)aSection
{
    NSString * lRetval = nullptr;

    if (aSection == Detail::TableSection::kTableSection_Key)
    {
        lRetval = NSLocalizedString(@"SortCriteriaChooserEditorTableViewSortKeySectionTitleKey" , @"");
    }
    else if (aSection == Detail::TableSection::kTableSection_Order)
    {
        lRetval = NSLocalizedString(@"SortCriteriaChooserEditorTableViewSortOrderSectionTitleKey" , @"");
    }

    return (lRetval);
}

- (NSInteger) tableViewKeySectionNumberOfRows: (UITableView *)aTableView 
{
    return (Detail::SortKey::kSortKey_Count);
}

- (NSInteger) tableViewOrderSectionNumberOfRows: (UITableView *)aTableView
{
    return (Detail::SortOrder::kSortOrder_Count);
}

- (NSInteger) tableView: (UITableView *)aTableView numberOfRowsInSection: (NSInteger)aSection
{
    NSInteger lRetval = 0;

    if (aSection == Detail::TableSection::kTableSection_Key)
    {
        lRetval = [self tableViewKeySectionNumberOfRows: aTableView];
    }
    else if (aSection == Detail::TableSection::kTableSection_Order)
    {
        lRetval = [self tableViewOrderSectionNumberOfRows: aTableView];
    }
    
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView
                  keyCellForRow: (const NSUInteger &)aRow
{
    static NSString * const kCellIdentifier = @"Sort Key Prototype Cell";
    UITableViewCell *       lRetval         = nullptr;

    lRetval = [aTableView dequeueReusableCellWithIdentifier: kCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableKeyCell: lRetval
                            forRow: aRow];

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView
                orderCellForRow: (const NSUInteger &)aRow
{
    static NSString * const kCellIdentifier = @"Sort Order Prototype Cell";
    UITableViewCell *       lRetval         = nullptr;

    lRetval = [aTableView dequeueReusableCellWithIdentifier: kCellIdentifier];
    nlREQUIRE(lRetval != nullptr, done);

    [self configureReusableOrderCell: lRetval
                              forRow: aRow];

 done:
    return (lRetval);
}

- (UITableViewCell *) tableView: (UITableView *)aTableView cellForRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger  lSection = aIndexPath.section;
    const NSUInteger  lRow     = aIndexPath.row;
    UITableViewCell * lRetval  = nullptr;


    if (lSection == Detail::TableSection::kTableSection_Key)
    {
        lRetval = [self     tableView: aTableView
                        keyCellForRow: lRow];
    }
    else if (lSection == Detail::TableSection::kTableSection_Order)
    {
        lRetval = [self       tableView: aTableView
                        orderCellForRow: lRow];
    }

    return (lRetval);
}

- (void) tableView: (UITableView *)aTableView keySectionDidSelectRow: (const NSUInteger &)aRow
{
    const NSInteger   lCurrentlySelectedSortKey = aRow;
    
    if (lCurrentlySelectedSortKey != mCurrentlySelectedSortKey)
    {
        NSMutableSet *    lReloadIndexPaths;
        NSIndexPath *     lOldIndexPath;
        NSIndexPath *     lNewIndexPath;

        lReloadIndexPaths = [[NSMutableSet setWithCapacity: 2] init];
        nlREQUIRE(lReloadIndexPaths != nullptr, done);

        if (mCurrentlySelectedSortKey != NSNotFound)
        {
            lOldIndexPath = [NSIndexPath indexPathForRow: mCurrentlySelectedSortKey
                                               inSection: Detail::TableSection::kTableSection_Key];
            nlREQUIRE(lOldIndexPath != nullptr, done);
            
            [lReloadIndexPaths addObject: lOldIndexPath];
        }
        
        lNewIndexPath = [NSIndexPath indexPathForRow: lCurrentlySelectedSortKey
                                           inSection: Detail::TableSection::kTableSection_Key];
        nlREQUIRE(lNewIndexPath != nullptr, done);
        
        [lReloadIndexPaths addObject: lNewIndexPath];
        
        mCurrentlySelectedSortKey = lCurrentlySelectedSortKey;
        
        // Refresh the cells for the previously- and newly-selected rows.

        [self.tableView reloadRowsAtIndexPaths: [lReloadIndexPaths allObjects]
                              withRowAnimation: UITableViewRowAnimationNone];

        // Always refresh the entirety of the order section. The detail description changes per
        // selected sort key.
        
        [self.tableView reloadSections: [NSIndexSet indexSetWithIndex: Detail::TableSection::kTableSection_Order]
                      withRowAnimation: UITableViewRowAnimationNone];
    }

done:
    return;
}

- (void) tableView: (UITableView *)aTableView orderSectionDidSelectRow: (const NSUInteger &)aRow
{
    const NSInteger   lCurrentlySelectedSortOrder = aRow;
    
    if (lCurrentlySelectedSortOrder != mCurrentlySelectedSortOrder)
    {
        NSMutableSet *    lReloadIndexPaths;
        NSIndexPath *     lOldIndexPath;
        NSIndexPath *     lNewIndexPath;

        lReloadIndexPaths = [[NSMutableSet setWithCapacity: 2] init];
        nlREQUIRE(lReloadIndexPaths != nullptr, done);

        if (mCurrentlySelectedSortOrder != NSNotFound)
        {
            lOldIndexPath = [NSIndexPath indexPathForRow: mCurrentlySelectedSortOrder
                                               inSection: Detail::TableSection::kTableSection_Order];
            nlREQUIRE(lOldIndexPath != nullptr, done);
            
            [lReloadIndexPaths addObject: lOldIndexPath];
        }
        
        lNewIndexPath = [NSIndexPath indexPathForRow: lCurrentlySelectedSortOrder
                                           inSection: Detail::TableSection::kTableSection_Order];
        nlREQUIRE(lNewIndexPath != nullptr, done);
        
        [lReloadIndexPaths addObject: lNewIndexPath];
        
        mCurrentlySelectedSortOrder = lCurrentlySelectedSortOrder;
        
        // Refresh the cells for the previously- and newly-selected rows.

        [self.tableView reloadRowsAtIndexPaths: [lReloadIndexPaths allObjects]
                              withRowAnimation: UITableViewRowAnimationNone];
    }

done:
    return;
}

- (void) tableView: (UITableView *)aTableView didSelectRowAtIndexPath: (NSIndexPath *)aIndexPath
{
    const NSUInteger  lSection = aIndexPath.section;
    const NSUInteger  lRow     = aIndexPath.row;

    if (lSection == Detail::TableSection::kTableSection_Key)
    {
        [self              tableView: aTableView
              keySectionDidSelectRow: lRow];
    }
    else if (lSection == Detail::TableSection::kTableSection_Order)
    {
        [self                tableView: aTableView
              orderSectionDidSelectRow: lRow];

    }
}

// MARK: Workers

- (void) configureReusableKeyCell: (UITableViewCell *)aCell
                           forRow: (const NSUInteger &)aRow
{
    const Detail::SortKey  lSortKey = static_cast<Detail::SortKey>(aRow);
    bool                   lIsDisabled;

    aCell.textLabel.text       = Detail::SortKeyDescription(lSortKey);
    aCell.tag                  = static_cast<NSInteger>(lSortKey);
    
    // A key cell is either selected or not but is additionally disabled depending on the
    // collection of sort parameters already configured in the sort criteria controller.
    
    lIsDisabled = [mSortCriteriaController hasSortKey: lSortKey];
    
    if (lIsDisabled)
    {
        aCell.alpha                  = 0.5f;
        aCell.textLabel.alpha        = 0.5f;
        aCell.userInteractionEnabled = false;
    }
    else
    {
        aCell.alpha                  = 1.0f;
        aCell.textLabel.alpha        = 1.0f;
        aCell.userInteractionEnabled = true;
    }
    
    if (aRow == mCurrentlySelectedSortKey)
    {
        aCell.accessoryType        = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        aCell.accessoryType        = UITableViewCellAccessoryNone;
    }
}

- (void) configureReusableOrderCell: (UITableViewCell *)aCell
                             forRow: (const NSUInteger &)aRow
{
    const Detail::SortOrder  lSortOrder = static_cast<Detail::SortOrder>(aRow);


    aCell.textLabel.text       = Detail::SortOrderDescription(lSortOrder);
    aCell.tag                  = static_cast<NSInteger>(lSortOrder);

    if (mCurrentlySelectedSortKey   != NSNotFound)
    {
        const Detail::SortKey   lSortKey = static_cast<Detail::SortKey>(mCurrentlySelectedSortKey);
        
        aCell.detailTextLabel.text = Detail::SortOrderForKeyDescription(lSortOrder, lSortKey);
    }
    else
    {
        aCell.detailTextLabel.text = nullptr;
    }
    
    // An order cell is either selected or not but is never disabled.
    
    if (aRow == mCurrentlySelectedSortOrder)
    {
        aCell.accessoryType        = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        aCell.accessoryType        = UITableViewCellAccessoryNone;
    }
}

// MARK: Controller Delegations

- (void) controllerDidDisconnect: (HLX::Client::Application::Controller &)aController withURL: (NSURL *)aURLRef andError: (const HLX::Common::Error &)aError
{
    [self presentDidDisconnectAlert: aURLRef
                          withError: aError
                      andNamedSegue: @"DidDisconnect"];
}

@end
