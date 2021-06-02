/*
 *    Copyright (c) 2021 Grant Erickson
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
 *    This file defines a smart or shared pointer to a mutable @a
 *    HLX::Client::Controller instance.
 *
 */

#include <memory>

#include <OpenHLX/Client/HLXController.hpp>

/**
 *  Smart or shared pointer to a mutable @a HLX::Client::Controller
 *  instance in which the associated memory is released when there are
 *  no further owners of the underlying pointer.
 *
 */
typedef std::shared_ptr<HLX::Client::Controller> MutableHLXClientControllerPointer;