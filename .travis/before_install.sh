#!/bin/sh

#
#    Copyright (c) 2021 Grant Erickson. All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

#
#    Description:
#      This file is the script for Travis CI hosted, distributed continuous 
#      integration 'before_install' trigger of the 'install' step.
#

die()
{
    echo " *** ERROR: " ${*}
    exit 1
}

# Package build machine OS-specific configuration and setup

case "${TRAVIS_OS_NAME}" in

    osx)
        # Use Brew to install any source code dependencies.

        HOMEBREW_NO_AUTO_UPDATE=1 brew install autoconf automake libtool boost

		# Clone a copy of the openhlx project on which this one depends, only
		# configuring it, pulling dependent repos, and setting up symbolic
		# links in the public include directory. The source itself will be
		# built by this project rather than by openhlx.
		
        git -C "${HOME}" clone -b release/1.0 -- https://github.com/gerickson/openhlx.git openhlx
        cd ${HOME}/openhlx
        ./bootstrap-configure -C --with-boost=/usr/local
        make -C src/include
        
        ;;

    *)
        die "Unknown OS name \"${TRAVIS_OS_NAME}\"."

        ;;

esac
