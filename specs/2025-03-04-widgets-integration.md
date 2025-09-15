# Feature: Widget Integration

## Overview

### Problem Statement
Users need more accessible touchpoints to remind and encourage them to practice brief moments of mindfulness throughout their day, but opening an app creates friction that can prevent spontaneous practice.

### Intended Impact
By providing home screen and lock screen widgets, Just Now will make meditation more accessible and visible throughout the day, increasing the frequency of brief mindfulness sessions and helping users maintain consistent practice.

### Background Context
Widgets on iOS provide glanceable information and quick actions directly from the home screen or lock screen. For meditation practice, this immediacy can be a powerful tool to encourage the "small glimpses, many times" approach that Just Now promotes.

## Goals and Success Metrics

### Primary Goal
Reduce friction to start meditation sessions by providing one-tap access from widgets, leading to more frequent brief meditation sessions.

### Success Metrics
- 50%+ of active users install at least one widget
- 30%+ increase in sessions started per user per day
- Increase in very short (1-3 minute) sessions, indicating spontaneous use

### Non-goals
- Complex widget customization options
- Widgets displaying detailed meditation statistics
- Widgets that update frequently (battery conservation)

## Requirements

### Functional Requirements

#### Home Screen Widget
- Widget must allow starting a session with a single tap
- Widget should display time since last meditation
- Widget should display a rotating prompt or quote to inspire practice
- Widget must be available in multiple sizes (small, medium, large)

#### Lock Screen Widget
- Widget must provide one-tap access to start a session
- Widget should show time since last meditation in a compact format
- Widget should be available in circular and rectangular formats

#### Control Center (iOS 18+)
- Provide a Control Center control titled "Start Meditation"
- Tapping the control opens the app into the running timer
- Control uses an App Intent that is hidden from Shortcuts to avoid duplicate actions

### Non-functional Requirements
- Widgets must be visually consistent with app design
- Widgets must be battery-efficient
- Widgets should be accessible
- Widgets should refresh data at appropriate intervals (not continuously)

### Constraints
- iOS 16+ required for lock screen widgets
- iOS 18+ required for Control Center controls
- Limited interactivity based on iOS widget capabilities
- Limited display space, especially for lock screen widgets

## User Experience

### User Flows

#### Adding Home Screen Widget
1. User long-presses on home screen
2. User taps "+" button to add widget
3. User selects Just Now widget
4. User chooses widget size
5. User places widget on home screen

#### Using Home Screen Widget
1. User taps widget
2. App launches directly into timer running mode
3. Meditation session begins immediately

#### Adding Lock Screen Widget
1. User long-presses on lock screen
2. User taps "Customize" button
3. User selects widget area
4. User adds Just Now widget
5. User chooses widget position

#### Using Lock Screen Widget
1. User taps widget on lock screen
2. Face ID/Touch ID authenticates user
3. App launches directly into timer running mode

#### Using Control Center Control (iOS 18+)
1. User adds the Little Moments control to Control Center
2. User taps the "Start Meditation" control tile
3. App opens to the running timer (untimed by default)

### Key Screens/Interactions
- Widget configuration screen (standard iOS interface)
- Home screen widget in multiple sizes
- Lock screen widget in multiple formats
- Immediate transition to timer running screen when widget is tapped

### Edge Cases
- If no meditation history exists, widget shows "No recent sessions"
- If app has been force-quit, widget tap may take slightly longer to start a session
- If device is in Do Not Disturb mode, ensure bell sounds respect system settings

## Implementation Considerations

### Dependencies
- WidgetKit framework
- App Intents framework for interactive widgets and Control Center controls
- Access to meditation history data

### Phasing
1. Basic home screen widget with one-tap session start
2. Enhanced home screen widget with time since last meditation
3. Lock screen widget integration
4. Addition of rotating prompts or quotes
5. iOS 18 Control Center tile: "Start Meditation" (done)

### Open Questions
- Should widgets allow starting sessions with preset durations?
- What rotation frequency is appropriate for prompts/quotes?
- Should we allow for any widget customization?
- How can we make the lock screen widget maximally useful given size constraints?
- Should the widget tap action be configurable (e.g., start session vs. open app)?
- Do we want additional Control tiles (e.g., Start 5‑minute session)?

### Implementation Notes
- Control Center tile is implemented as `StartMeditationControlWidget` with `StartMeditationControlIntent` and a lightweight `StartMeditationOpenIntent` that sets `openAppWhenRun = true`.
- Both control-related intents are marked `isDiscoverable = false` to avoid duplicate actions in Shortcuts (the user‑facing action remains `MeditationSessionIntent`).
