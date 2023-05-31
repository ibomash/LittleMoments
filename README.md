# Just Now app

Copyright (c) 2023 Illya Bomash, licensed under a BSD-3 license.

## Why?

Beyond longer sessions of formal meditation practice, many practitioners want to continue their journey "off the cushion" by (among other things) sprinkling short mindful glimpses throughout the day. Some will be brief recognitions of your "true self" in the middle of activity, but others may be brief meditations of a few minutes or less.

This app is specifically for encouraging and supporting "small glimpses, many times" throughout the day — for using free moments during the day, from 30 seconds to a few minutes, to close your eyes and reset in a way that fits your practice. Encouraging means creating touch points for prompting the user to close their eyes instead of check their email. Supporting means having a simple interface to jump right into a brief meditation session with or without some orientation or prompting set up by you.

## How?

I envision a very simple and open-source iOS app with some basic widget and Shortcut support (and logging to HealthKit) to do meditation session timing and not much else.

## What now

The app's current state is alpha. There are basic capabilities to start a session, set a bell, and log the results to Apple Health.

## Looking into the future

There are many possible directions to take this work. Below are some ideas, with an attempt to mark with check boxes goals for a 1.0 release.

### Basic session triggering and timing

- [x] Decide how the "launcher" screen should look and implement it
  - Just a prompt and a "start" button?
  - Launch right into a timer session?
  - "Start" button but also some duration options?
  - Ability to set a bell duration when starting
- [x] Implement visual and audio feedback for a timer of a given duration
- [x] Ensure timer runs in the background (or figure out keeping screen on)
  - [x] Count by time deltas, not individual seconds (get rid of pausing?)
- Allow duration to be specified on the timer screen?
- [x] Figure out where to allocate / deallocate sound memory
- [x] Make HealthKit writing configurable (includes making a Settings page…)
- [x] Update HealthKit prompt strings in Info.plist (finalize the language)
- [x] Keep display on while meditating (optionally)
- Fetch start time of next calendar event and start a session up to that start time

### Project infrastructure

- [ ] Pick an open source license and set up a Github repo
- [ ] Set up an Apple Developer account to release the app
- [ ] Make a simple "About" screen / update it for the source code location
- [ ] Get a real app icon
- Set up a web page?
- [ ] Fix the folder structure!

### Widgets

- Design and implement a home screen widget with a prompt for starting meditation
  - A rotating prompt phrase?
  - Time since last meditation or number of sessions so far today?
- Design and implement a lock screen widget with a prompt for starting meditation

### Prompting

- Explore what kinds of "prompts" for brief glimpses are desired
- Allow users to customize one or more sets of "prompts" to help enter the right space for a glimpse

### Shortcuts

- Add support for shortcut actions to start a meditation without a duration or with a pre-specified duration (App Intents)

## Credits

- The initial alpha app icon is from DALL-E. I think it would be great to commission a human artist for a final app icon.
- I used ChatGPT Pro to help create this (given no prior experience with Swift and SwiftUI).
- Sound file downloaded from https://freesound.org/people/fauxpress/sounds/42095/
