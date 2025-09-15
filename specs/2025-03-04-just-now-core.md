# Feature: Just Now Core Application

## Overview

### Problem Statement
Meditation practitioners need a way to take brief mindful breaks throughout their day, but most meditation apps are designed for longer formal sessions and have complex interfaces that create friction for quick use.

### Intended Impact
Just Now simplifies the meditation experience by providing a minimalist interface that allows users to quickly start a meditation timer, choose a duration, and record their practice to Apple Health. This encourages the practice of "small glimpses, many times" throughout the day.

### Background Context
Many meditation practitioners want to extend their practice "off the cushion" by incorporating brief mindful moments into their daily activities. These short meditations, ranging from 30 seconds to 20 minutes, can help reset attention and maintain mindfulness throughout the day. The app is inspired by contemplative traditions that emphasize brief "glimpses" of awareness, particularly influenced by the teachings of Loch Kelly.

## Goals and Success Metrics

### Primary Goal
Create a friction-free way for users to time brief meditation sessions without distractions or complexity.

### Success Metrics
- Regular usage patterns showing multiple short sessions per day
- Positive user feedback on the simplicity of the interface
- Increased total meditation time per user compared to before using the app

### Non-goals
- Guided meditations or content
- Complex meditation tracking analytics
- Community features
- Subscription model
- Complex customization options

## Requirements

### Functional Requirements
- Allow users to start a meditation timer with a single tap
- Provide preset timer durations (1, 5, 10, 15, 20, 30, 45, 60 minutes)
- Play a bell sound at the start of a session (configurable)
- Play a bell sound at the end of a timed session
- Record completed meditation sessions to Apple Health
- Support Shortcuts integration for starting a session
- Display the elapsed time during meditation sessions
- Allow users to complete or cancel a session at any time
- Keep the screen on during meditation sessions
- Maintain timer functionality when the app is in the background

### Non-functional Requirements
- Minimalist, distraction-free interface
- Work reliably in background mode
- Support landscape and portrait orientations
- Accessible to users with disabilities

### Constraints
- iOS/iPadOS only (no Android support)
- No server backend needed
- Open-source development

## User Experience

### User Flows

#### Starting a Meditation Session
1. User opens the app
2. Home screen displays a simple interface with a start button and a mindfulness prompt
3. User taps the "Start session" button
4. Timer screen appears and meditation timer starts immediately
5. Optional: User selects a duration for the session

#### During a Meditation Session
1. Timer displays elapsed time in minutes (and optionally seconds)
2. Progress circle fills as time progresses toward the target (if set)
3. User can cancel or complete the session at any time

#### Ending a Meditation Session
1. When timer completes, a bell sound plays
2. User can manually end session by tapping "Complete"
3. Session data is saved to Apple Health (if enabled)
4. User returns to home screen

### Key Screens/Interactions
- Home Screen: Simple interface with start button, mindfulness prompt, and settings access
- Timer Running Screen: Displays elapsed time, duration controls, and session controls
- Settings Screen: Allows configuration of app behavior, including Health integration and sound options

### Edge Cases
- If notification permissions are denied, the app will still function but may not alert properly in background mode
- If Health permissions are denied, sessions won't be recorded to Apple Health
- If interrupted by a call or other system event, the timer continues running
- In development/simulator environment, a shorter 5-second timer option is available for testing

## Implementation Considerations

### Dependencies
- HealthKit for recording meditation sessions
- UserNotifications for timer alerts when in background
- AVFoundation for playing bell sounds
- UIKit's background task API for maintaining timer functionality in background

### Phasing
1. Basic timer functionality with bell at end
2. HealthKit integration
3. Shortcuts support
4. Background mode support
5. Widget and lock screen integration (implemented)

### Open Questions
- Should multiple interval bells be supported? (Note: RecurringScheduledBellAlert class exists in the codebase but is not yet exposed in the UI)
- Would users benefit from customizable bell sounds beyond the current meditation bell?
- Should there be a way to add notes to meditation sessions?
- How can we better integrate with iOS focus modes?
- Would users benefit from haptic feedback as an alternative to sound?

### Credits
- Bell sound downloaded from user fauxpress on freesound.org
- The prompt on the main screen was heavily influenced by the teachings of Loch Kelly
- Development assisted by AI tools including ChatGPT and GitHub Copilot 