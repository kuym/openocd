# OpenOCD
The open-source on-chip debugger

## Overview

OpenOCD has historically been quite a mess.  While the codebase and the build process are getting better,
it's still based on an unmaintainable GNU ./configure -> make autoconf/automake design. To enable building
on modern systems like OS X, I have streamlined the build process with the `./build.sh` script.

## Building

- Ensure Xcode is installed. No other dependencies are required (hallelujah!)
- Run `./build.sh`.

## Using

Same as regular OpenOCD, which is to say "not the nicest experience."
