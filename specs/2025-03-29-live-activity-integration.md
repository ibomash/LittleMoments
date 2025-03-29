# Feature: Live Activity Integration

## Overview

### Problem Statement
Users need a way to stay connected to their ongoing meditation session when their phone is locked or when using other apps, but currently they must return to the app to check their progress or see how much time remains.

### Intended Impact
By implementing Live Activities, the app will provide real-time session information on the Lock Screen and in Dynamic Island, increasing session awareness and reducing the urge to check the app, which can disrupt the meditative state.

### Background Context
iOS 16 introduced Live Activities, which allow apps to display real-time information on the Lock Screen and in Dynamic Island (on iPhone 14 Pro and newer models). This feature is ideal for meditation sessions, as it can display session progress without requiring users to unlock their devices or switch apps.

## Goals and Success Metrics

### Primary Goal
Enhance the meditation experience by providing glanceable, real-time session information outside the app, reducing distractions and supporting continuous practice.

### Success Metrics
- 70%+ of eligible users (on iOS 16+) enable and use Live Activities
- 25%+ reduction in app re-entries during active sessions
- Increased average session duration
- Positive user feedback regarding reduced anxiety about tracking session progress

### Non-goals
- Complex Live Activity customization options
- Interactive controls within the Live Activity (beyond basic end session)
- Analytics or detailed meditation data in the Live Activity
- Supporting older iOS versions that don't have Live Activity capabilities
- Displaying meditation prompts or quotes in the Live Activity
- Supporting multiple bells in interval sessions within the Live Activity

## Requirements

### Functional Requirements
- Display elapsed time since session start in the Live Activity
- Show progress bar for timed sessions (percentage complete)
- Support both Lock Screen and Dynamic Island presentations
- Update time display in real-time (seconds)
- Allow session end directly from the Live Activity
- Handle session cancellation or completion appropriately
- Persist during device reboots or app terminations
- Provide setting to enable/disable Live Activities
- Provide haptic feedback on session completion

### Non-functional Requirements
- Minimal battery impact
- Consistent visual design with the main app
- Accessible to users with visual impairments
- Respect system settings for notifications and focus modes

### Constraints
- iOS 16+ required for Live Activities
- Dynamic Island only available on iPhone 14 Pro and newer models
- Limited display space, especially in compact Dynamic Island
- Maximum 8-hour runtime for Live Activities (iOS limitation)

## User Experience

### User Flows

#### Starting a Live Activity
1. User starts a meditation session in the app
2. Live Activity appears automatically on Lock Screen and in Dynamic Island (if enabled in settings)
3. No user action required to enable the Live Activity for each session

#### During an Active Session
1. User can glance at Lock Screen to see session progress
2. On supported devices, Dynamic Island shows condensed session information
3. User can press and hold on Dynamic Island to expand and see more details
4. Time updates in real-time, showing elapsed meditation time
5. Time view respects the app's "Show seconds" setting when there is space for it

#### For Timed Sessions
1. Progress bar fills as the session progresses toward target duration
2. Clear indication if the session time is complete (although the timer keeps running)

#### Ending a Session
1. User can tap directly on the Live Activity to end the session, either "cancel" or "complete" like in the current timer running view
2. When session timer finishes, haptic feedback is provided (if device supports it)
3. Live Activity shows completion state briefly, then dismisses
4. If session is ended in the app, Live Activity updates and dismisses accordingly

### Key Screens/Interactions
- Lock Screen Live Activity: Shows elapsed time and progress bar (if applicable)
- Dynamic Island compact view: Shows minimal elapsed time
- Dynamic Island expanded view: Shows full progress information and end button
- Session completion state: Brief celebration or acknowledgment with haptic feedback
- Settings screen: Toggle to enable/disable Live Activities

### Edge Cases
- If session exceeds 8 hours, Live Activity will end due to system limitations
- If battery is critically low, system may terminate Live Activity
- If device restarts during session, Live Activity should resume when device boots
- Handle cases where users toggle Live Activity permissions during an active session
- If haptic feedback is not supported on the device, fall back to visual-only completion indication

## Implementation Considerations

### Dependencies
- ActivityKit framework for Live Activities
- SwiftUI for Live Activity UI components
- WidgetKit for shared UI components with existing widgets
- Background task capabilities to maintain timer accuracy
- CoreHaptics for providing haptic feedback on completion

### Phasing
1. Basic Live Activity showing elapsed time
2. Add progress bar for timed sessions
3. Support for Dynamic Island compact and expanded modes
4. Add end session functionality from Live Activity
5. Add settings toggle for enabling/disabling Live Activities
6. Implement haptic feedback for session completion
7. Add visual refinements and accessibility improvements

### Open Questions
- How should we handle notification permissions if denied?
