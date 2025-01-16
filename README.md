# Little Moments app

Copyright © 2023-2024 Illya Bomash, licensed under a BSD-3 license.

## Why?

Beyond longer sessions of formal meditation practice, many practitioners want to continue their journey "off the cushion" by (among other things) sprinkling short mindful glimpses throughout the day. Some will be brief recognitions of your "true self" in the middle of activity, but others may be brief meditations of a few minutes or less.

This app is specifically for encouraging and supporting "small glimpses, many times" throughout the day — for using free moments during the day, from 30 seconds to a few minutes, to close your eyes and reset in a way that fits your practice. Encouraging means creating touch points for prompting the user to close their eyes instead of check their email. Supporting means having a simple interface to jump right into a brief meditation session with or without some orientation or prompting set up by you.

## How?

I envision a very simple and open-source iOS app with some basic widget and Shortcut support (and logging to HealthKit) to do meditation session timing and not much else.

## What now

The app's current state is beta. There are basic capabilities to start a session, set a bell, and log the results to Apple Health. It's usable as a basic meditation timer.

## Looking into the future

There are many possible directions to take this work. Below are some ideas, with an attempt to mark with check boxes goals for a 1.0 release.

### ✅ Basic session triggering and timing

### Project infrastructure

- [x] Pick an open source license and set up a Github repo
- [x] Set up an Apple Developer account to release the app
- [x] Make a simple "About" screen / update it for the source code location
- [x] Share via TestFlight
- [ ] Get a real app icon
- [x] Change the launch page text
- Set up a web page? (Privacy policy?)
- [ ] Go through the app submission process

### Better session triggering and timing

- [x] Do a better job with duration buttons being toggles or showing which duration is selected
- [x] Make timers work even when the app is in the background. Current plan is to use notifications (downside: won't make a sound if phone is on vibrate - perhaps a feature).
  - [x] If we trigger the sound through the notification, don't also ring the in-app bell.
- [x] Cancel the running timer when the timer running screen is dismissed
- [x] Add some capability for longer session times (over 20 minutes)

### Widgets

- Design and implement a home screen widget with a prompt for starting meditation
  - A rotating prompt phrase?
  - Time since last meditation?
- Design and implement a lock screen widget with a prompt for starting meditation

### Prompting

- Explore what kinds of "prompts" for brief glimpses are desired (e.g. a reminder phrase on the launch screen)
- Allow users to customize one or more sets of "prompts" to help enter the right space for a glimpse?

### Shortcuts

- [x] Add support for a shortcut action to start a meditation without a duration
- [ ] Add support for a shortcut action with a pre-specified duration?

### Multi-device

- This app runs on iPad and macOS, but can't write to HealthKit on those devices, I think. We could add a simple database of past sessions to the app and sync it across devices using CloudKit, and write to HealthKit from iPhones.

### Live Activities for mindfulness reminders

- Ability to start a Mindful Reminders live activity with periodic alerts, e.g. a chime / haptic feedback every 15 min, or every 15 sec. Maybe this is a different "kind" of session? Maybe it's a different app?

## Credits

- The initial alpha app icon is from DALL-E. I think it would be great to commission a human artist for a final app icon.
- I used ChatGPT Plus to help create this (given no prior experience with Swift and SwiftUI).
- Sound file downloaded from https://freesound.org/people/fauxpress/sounds/42095/
