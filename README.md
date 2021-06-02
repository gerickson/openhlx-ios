[![Build Status][openhlx-ios-travis-svg]][openhlx-ios-travis]
[OpenHLX-ios-travis]: https://travis-ci.com/gerickson/openhlx-ios
[OpenHLX-ios-travis-svg]: https://travis-ci.com/gerickson/openhlx-ios.svg?branch=main

Open HLX
========

# Introduction

Open HLX provides a set of iOS apps for setting up and/or interacting
with the Audio Authority HLX Series Modular Matrix System High
Definition Audio/Video Switching System, which has gone end-of-life
and, as a result, is no longer manufacturered or sold by Audio
Authority.

However, thousands of such systems have been sold worldwide and there
remains a need to set up, interact with, and control such systems.

With that in mind, Open HLX provides the following iOS apps:

  <dl>
      <dt><strong>Open HLX</strong></dt>
      <dd>A user-centric app, with the ability to change the volume
          level, volume mute state, and source (input) for any group
          or zone.</dd>
      <dt><strong>Open HLX Installer</strong></dt>
      <dd>An installer-centric app, with all of the features of
          <em>Open HLX</em>, that adds additional installer-centric
          functionality such as modifying zone stereophonic channel
          balance and zone equalizer sound modes and sound mode
          settings including: zone equalizer band levels, zone
          equalizer presets, zone tone bass and treble levels, and
          zone high- and lowpass crossover filter frequencies.</dd>
  </dl>

## Background

Despite its end-of-life status, the HLX Series remains a high-value
and high-function audio/video matrix unrivaled and unparalled even
among actively-sold and -produced competitive products.

In most situations, an HLX system will find itself with its
telnet-based Ethernet network interface disabled and tethered, via a
serial cable to an AMX, Crestron, Control4, or other controller where
those systems act as the primary user interface and experience surface
with the HLX acting silently in the background. For such
installations, Open HLX and this package will be of both little use
and interest since AMX, Crestron, Control4, or other controller
already is providing the functionality of the Open HLX mobile apps.

However, despite its strong performance and value, whether using its
serial interface or the aforementioned network interface, the
implementation of the HLX Series control protocol has two notable
limitations that severely limit its use as a general audio/video
matrix without an intervening controller.

First, the HLX is limited to no more than two active telnet-based
network connections. This means in a consumer/residential or
commercial/enterprise environment, no more than two Open HLX mobile app
users may be active at a time. Given the short background time out of
the Open HLX mobile app on iOS, this may not be a practical day-to-day
limitation, depending on the number of concurrent users for your
installation.

Second, and perhaps more limiting, is the fact that the HLX Series
control protocol does *character* rather than *line* or *buffer* at a
time input/output and multiplexes across multiple connections at that
granularity. There are two implications of this. First, the response
is incredibly slow. This can be seen in the Open HLX mobile apps after
connecting while the app is gathering the latest HLX state from the
HLX hardware. This operation can take a frustratingly-long 15-20
seconds. Second, particularly when more than one connection to the HLX
is active, the output among any client is interleaved, resulting in
unparseable and, by extension, corrupt output. This renders concurrent
mobile app usage all but unusable when more than one command request
and/or response is in flight. However, like the first limitation, this
may tend be either more theoretical or more practical, depending on
the number of concurrent users for your installation. If you note very
strange behavior in the mobile app, including nonsensical group,
source (input), or zone names, your mobile app may be getting its
command request/response stream intermingled with another mobile app
user.

Despite these two limitations, the Open HLX mobile apps represent a
highly-effective way to directly interact with HLX hardware without
the need for an intervening controller.

# Getting Started with Open HLX

## Building Open HLX

Open HLX is an [Xcode](https://developer.apple.com/documentation/xcode)-based
project and, as a result, those interested in building Open HLX from source
are expected to have a practical knowledge of using
[Xcode](https://developer.apple.com/documentation/xcode).

### Dependencies

In addition to depending on C, C++, Objective-C, and Objective-C++
languages; the C and C++ Standard Libraries; and the C++ Standard
Template Library (STL), Open HLX depends on:

  * [CoreFoundation](https://developer.apple.com/documentation/corefoundation)
  * [Foundation](https://developer.apple.com/documentation/foundation)
  * [LogUtilities](https://github.com/Nuovations/LogUtilities)
  * [UIKit](https://developer.apple.com/documentation/uikit)
  * [nlassert](https://github.com/nestlabs/nlassert)
  * [openhlx](https://github.com/gerickson/openhlx)
    - [CFUtilities](https://github.com/Nuovations/CFUtilities)
    - [libtelnet](https://github.com/seanmiddleditch/libtelnet)

For [openhlx](https://github.com/gerickson/openhlx) in particular,
Open HLX builds the package natively within Xcode, relying upon an
expanded archive distribution or source code control clone of it from
which to build it. [openhlx](https://github.com/gerickson/openhlx)
uniquely depends on:

  * [CFUtilities](https://github.com/Nuovations/CFUtilities)
  * [LogUtilities](https://github.com/Nuovations/LogUtilities)
  * [libtelnet](https://github.com/seanmiddleditch/libtelnet)
  * [nlassert](https://github.com/nestlabs/nlassert)

and Open HLX shares both the _LogUtilities_ and _nlassert_ dependencies.
However, all four of these dependencies are satisfied for both by the
[openhlx](https://github.com/gerickson/openhlx) package itself.

#### Setting OPENHLX_ROOT

Satisfying the [openhlx](https://github.com/gerickson/openhlx) dependency and
its sub-dependencies may be accomplished by setting the _OPENHLX_ROOT_ build
setting to the absolute path to a
[openhlx](https://github.com/gerickson/openhlx) source distribution--either an
expanded archive or a source code control clone. This may be done either
in Xcode itself or on the command line with _xcodebuild_:

##### Using Xcode

To set OPENHLX_ROOT using Xcode itself:

  1. In the leftmost project inspector, click on the "openhlx-ios"
     project.
  2. In the editing window that appears for "openhlx-ios.xcodeproj",
     select the PROJECT > "openhlx-ios", just above the list of targets
     in TARGETS.
  3. Click on "Build Settings".
  4. Search for or navigate to "OPENHLX_ROOT", which should be under
     "User-Defined", likely at the bottom of the settings list.
  5. Enter an absolute path value for OPENHLX_ROOT, such as
     "/Users/gerickson/git/github.com/gerickson/openhlx".

##### Using xcodebuild

When building the project targets from the command line using _xcodebuild_,
simply set _OPENHLX_ROOT_ with a key/value pair option such as:

```
% xcodebuild ... OPENHLX_ROOT="/Users/gerickson/git/github.com/gerickson/openhlx" ...
```

# FAQ

Q: I do not have Audio Authority HLX hardware; however, I would like to
   try out Open HLX. How can I do that?

A: The core package on which Open HLX is based,
   [openhlx](https://github.com/gerickson/openhlx), contains an executable,
   _hlxsimd_, that fully emulates the protocol and virtual behavior of
   real HLX hardware. An instance of _hlxsimd_ can be built, launched,
   and Open HLX can be targeted against that using whatever IPv4 or IPv6
   address _hlxsimd_ has been configured to bind against and listen on.

Q: What features of HLX hardware are not supported?

A: There is no support at this time for favorites, restrictions, or
   audio/video breakaway switching.

# Interact

There are numerous avenues for Open HLX support:

  * Bugs and feature requests - [submit to the Issue Tracker](https://github.com/gerickson/openhlx-ios/issues)

# Versioning

Open HLX follows the [Semantic Versioning guidelines](http://semver.org/)
for release cycle transparency and to maintain backwards compatibility.

# License

Open HLX is released under the [Apache License, Version 2.0 license](https://opensource.org/licenses/Apache-2.0).
See the `LICENSE` file for more information.
