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
 *    This file defines a view controller for observing and mutating a
 *    HLX group or zone source(s) (input(s)).
 *
 */

#ifndef SOURCECHOOSERVIEWCONTROLLER_H
#define SOURCECHOOSERVIEWCONTROLLER_H

#include <memory>

#import <UIKit/UIKit.h>

#include <OpenHLX/Client/HLXController.hpp>
#include <OpenHLX/Client/HLXControllerDelegate.hpp>

#import "HLXClientControllerDelegate.hpp"
#import "HLXClientControllerPointer.hpp"


namespace HLX
{

namespace Client
{

class Controller;

};

};

class HLXClientControllerDelegate;

@interface SourceChooserViewController : UITableViewController <HLXClientControllerDelegate>
{
    /**
     *  A shared pointer to the global HLX client controller instance.
     *
     */
    MutableHLXClientControllerPointer             mHLXClientController;

    /**
     *  A scoped pointer to the default HLX client controller
     *  delegate.
     *
     */
    std::unique_ptr<HLXClientControllerDelegate>  mHLXClientControllerDelegate;

    /**
     *  A Boolean indicating whether the source(s) is/are for a
     *  group or zone.
     *
     */
    bool                                          mIsGroup;

    /**
     *  An immutable pointer to the group or zone, depending on the
     *  state of @a mIsGroup.
     *
     */
    union
    {
        /**
         *  An immutable pointer to the group, if @a mIsGroup is true.
         *
         */
        const HLX::Model::GroupModel *            mGroup;

        /**
         *  An immutable pointer to the zone, if @a mIsGroup is false.
         *
         */
        const HLX::Model::ZoneModel *             mZone;
    } mUnion;

    /**
     *  The current source(s) for the group or zone.
     *
     */
    HLX::Model::IdentifiersCollection             mCurrentSourceIdentifiers;
}

// MARK: Properties

// MARK: Instance Methods

// MARK: Initializers

- (id) initWithCoder: (NSCoder *)aDecoder;
- (id) initWithNibName: (NSString *)aNibName bundle: (NSBundle *)aNibBundle;

// MARK: Actions

// MARK: Setters

- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                       forGroup: (const HLX::Model::GroupModel *)aGroup;

- (void) setHLXClientController: (MutableHLXClientControllerPointer &)aHLXClientController
                        forZone: (const HLX::Model::ZoneModel *)aZone;

@end

#endif // SOURCECHOOSERVIEWCONTROLLER_H
