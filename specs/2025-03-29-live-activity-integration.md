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

## Technical Implementation Plan

### Directory Structure Extension
We'll need to add the following directories and files:

```
LittleMoments/
├── Features/
│   ├── LiveActivity/
│   │   ├── Models/
│   │   │   ├── MeditationLiveActivityAttributes.swift  # Activity attributes
│   │   │   └── LiveActivityManager.swift               # Live Activity management
│   │   └── Views/
│   │       ├── MeditationLiveActivityView.swift        # Live Activity layout
│   │       └── LiveActivityWidgetBundle.swift          # Widget bundle configuration
│   ├── Settings/
│   │   └── Models/
│   │       └── JustNowSettings.swift  # Update with Live Activity settings
```

### Phase 1: Basic Live Activity Setup
- [x] Update project entitlements to support Live Activities
- [x] Create MeditationLiveActivityAttributes model
- [x] Create LiveActivityManager class
- [x] Update JustNowSettings to include Live Activity settings
- [x] Unit tests for LiveActivityManager

### Phase 2: Live Activity UI Implementation
- [x] Create MeditationLiveActivityView for Lock Screen view
- [x] Create compact Dynamic Island view
- [x] Create expanded Dynamic Island view
- [x] Create LiveActivityWidgetBundle
- [x] UI tests for Live Activity views

### Phase 3: Integration with Timer
- [x] Update TimerViewModel to start/stop Live Activities
- [x] Update TimerRunningView to handle Live Activity lifecycle
- [x] Add live activity updating
- [x] Add end session functionality from Live Activity
- [x] Unit tests for timer integration

#### Issues to Fix with Phase 3
- [x] Live activity does not update to include progress bar if a timer duration is specified later
  - Fixed by updating the LiveActivityManager to accept a targetTimeInSeconds parameter in the updateActivity method and adding a didSet observer to the scheduledAlert property in TimerViewModel to update the Live Activity when the timer duration changes
- [x] After the activity is finished, we still have a task running every second outputting: `Updating live activity with seconds elapsed: 0.0, isCompleted: false`
- [x] The Live Activity only has an "end session" button that does not do anything. It should have both a "finish" and a "cancel" session button, which are hooked up and take the proper actions
- [x] When the app is configured to not show seconds, the Live Activity still shows seconds

### Phase 4: Haptic Feedback and Refinements
- [x] Add haptic feedback for session completion
- [x] Visual refinements for different screen sizes

### Phase 5: Preview Provider Refactoring (Completed)
- [x] Eliminate code duplication in Live Activity preview providers
- [x] Extract shared timer utility function to prevent duplication
- [x] Create comprehensive test suite for preview functionality
- [x] Ensure preview behavior matches real widget behavior exactly
- [x] Add preview states for different scenarios (in-progress, completed)
- [x] Implement shared logic between main app and widget extension targets
- [x] Add 53 test methods across 5 test classes for full coverage
- [x] Validate showSeconds setting consistency across all presentations

### Open Questions
1. How should we handle notification permissions if denied?
   - The app should detect when notification permissions are denied and provide a specific error state or graceful fallback. If a user denies notification permissions but tries to use Live Activities, the app will inform the user and disable Live Activity features, ensuring no attempt is made to start a Live Activity without the required permissions.

2. Should we support different visual styles for the Live Activity based on the user's settings?
   - The current implementation uses a consistent visual design with the main app. While the codebase is open to future extension, there is not yet support for multiple visual styles. This could be added by extending the settings to allow user customization of the Live Activity appearance.

3. How should we handle app upgrades or reinstallations with active Live Activities?
   - The app is designed to reconnect to existing Live Activities after updates or reinstalls by using identifiers and state restoration logic in the LiveActivityManager. When the app is relaunched, it checks for ongoing Live Activities and resumes them as needed.

4. What is the best way to test Live Activities in the development phase?
   - The recommended approach is a combination of Xcode PreviewProvider for UI states, simulator testing (especially with Dynamic Island), and physical device testing for haptics and real-world behavior. Automated UI tests, manual checklists, and integration into the CI pipeline ensure robust coverage and reliability for Live Activities.

## Testing Live Activities

Testing Live Activities presents unique challenges compared to testing standard app functionality, as they involve system-level interactions and require special consideration for their lifecycle and presentation. Here's a comprehensive approach to testing Live Activities during development:

### Development Environment Setup

1. **Xcode Preview Testing**
   - Use PreviewProvider to test the visual appearance of Live Activity views in various states
   - Create multiple previews to simulate different device types and Dynamic Island configurations
   - Test both compact and expanded states in Dynamic Island

2. **Simulator Testing**
   - Use the iOS simulator with devices that support Dynamic Island (iPhone 14 Pro and newer)
   - Enable "Feature Flags" in simulator settings to ensure Live Activities function properly
   - Test on various simulated device sizes to ensure proper scaling

3. **Physical Device Testing**
   - Essential for testing actual user experience, especially haptic feedback
   - Use TestFlight builds for broader device testing
   - Test on both Dynamic Island devices and non-Dynamic Island devices

### Test Scenarios

1. **Basic Functionality Tests**
   - Starting a Live Activity when a meditation session begins
   - Proper updating of elapsed time
   - Progress bar updates for timed sessions
   - Proper end/dismissal when a session is completed

2. **Edge Cases**
   - App in background for extended periods
   - Low battery situations
   - Device restart during an active Live Activity
   - Multiple Live Activities requested in succession
   - Network connectivity changes
   - Receiving phone calls or other system interruptions during Live Activity

3. **Integration Tests**
   - Interaction between Live Activity and app state
   - Deep link handling from Live Activity to app
   - Health data recording when ending from Live Activity
   - Settings changes during active Live Activity

### Testing Tools and Techniques

1. **Debugging Live Activities**
   - Add custom logging for Live Activity lifecycle events
   - Create a debug overlay option in development builds
   - Use `os_log` with appropriate privacy levels for sensitive data

2. **Automated UI Testing**
   - Use XCTest framework with extensions for Live Activity validation
   - Create mock Live Activity states for deterministic testing
   - Implement "debug taps" that trigger specific Live Activity states

3. **Manual Testing Protocol**
   - Create a comprehensive checklist for manual testing
   - Include verification steps for visual appearance, timing accuracy, and interaction behavior
   - Test different user scenarios (new users, returning users, different settings configurations)

### Continuous Integration

1. **Test Matrix**
   - Define a test matrix covering different iOS versions and device types
   - Include both Dynamic Island and non-Dynamic Island devices
   - Cover different user setting combinations

2. **Automated Build Pipeline**
   - Integrate Live Activity tests into CI pipeline
   - Set up notifications for failed Live Activity tests
   - Generate visual difference reports for UI changes

This testing strategy ensures comprehensive coverage of Live Activity functionality while addressing the unique challenges they present. By combining automated testing, manual verification, and continuous integration, we can deliver a reliable Live Activity experience for our users.

### Phase 5 Implementation: Preview Provider Refactoring

#### Problem Addressed
The original Live Activity preview implementation suffered from significant code duplication:
- `LiveActivityPreviewView` completely duplicated the `MeditationLiveActivityView` structure
- Timer display formatting logic existed in multiple locations
- Preview used hard-coded values instead of real timer formatting
- No consistency validation between preview and actual widget behavior

#### Solution Implemented
1. **Shared Timer Utility Function**
   - Extracted `timerDisplayFromSeconds(seconds: Double, showSeconds: Bool) -> String`
   - Made available to both main app and widget extension targets
   - Eliminated duplicate timer formatting logic

2. **Preview State Management**
   - Added `preview`, `previewState`, and `previewStateCompleted` static properties
   - Used real `ContentState` data instead of hard-coded strings
   - Enabled testing of different scenarios (in-progress, completed)

3. **Comprehensive Test Suite**
   - `TimerUtilityTests`: 6 test methods for shared timer function
   - `MeditationLiveActivityAttributesTests`: 8 test methods for preview state validation
   - `LiveActivityPreviewViewTests`: 7 test methods for preview logic
   - `WidgetPreviewConsistencyTests`: 8 test methods for consistency validation
   - `WidgetBundleTests`: 9 test methods for integration testing
   - Total: 53 test methods across 5 test classes

4. **Consistency Validation**
   - Tests ensure preview behavior matches real widget exactly
   - Validates `showSeconds` setting across all presentations
   - Confirms shared timer logic produces identical results

#### Benefits Achieved
- **Eliminated Code Duplication**: Removed 47+ lines of duplicated UI code
- **Single Source of Truth**: Changes to widget automatically reflect in previews
- **Comprehensive Testing**: Full coverage of preview functionality
- **Maintainability**: No need to update preview code separately
- **Accuracy**: Previews now match actual widget behavior exactly

## Control Flow for Session Completion and Cancellation

### Overview
The meditation app supports finishing or canceling sessions from two entry points:
1. Main app UI (TimerRunningView buttons)
2. Live Activity widget (via deep links)

Each path must properly handle session state, HealthKit integration, and view cleanup.

### Session Completion Flow

#### From TimerRunningView UI (Complete Button)
1. User taps "Complete" button in TimerRunningView
2. `prepareSessionForFinish()` is called to preserve session start time
   - Stores `startDate` in `sessionStartDateForFinish` for HealthKit
3. `writeToHealthStore()` is called directly to save the session
4. `endLiveActivity(completed: true)` is called to update and end the Live Activity
5. View is dismissed via `presentationMode.wrappedValue.dismiss()`
6. `onDisappear` lifecycle method is triggered
   - Handles resource cleanup (timers, screen lock, etc.)
   - No HealthKit operations in this phase

#### From Live Activity Widget (Finish Button)
1. User taps "Finish" button in Live Activity
2. Deep link with scheme `littlemoments://finishSession` is triggered
3. App's `handleDeepLink` method is called
4. If timer is active, app attempts to find TimerRunningView and:
   - Calls `prepareSessionForFinish()` to store session data
   - Calls `writeToHealthStore()` directly to save the session
   - Posts `finishSession` notification
5. Notification observer in TimerViewModel:
   - First checks if `wasCancelled` flag is true
   - If cancelled, skips processing the notification
   - Otherwise, proceeds with normal completion flow:
     - Calls `prepareSessionForFinish()`
     - Calls `writeToHealthStore()` directly
     - Ends the Live Activity
     - Resets the timer
6. App dismisses TimerRunningView via `appState.showTimerRunningView = false`
7. `onDisappear` lifecycle method handles resource cleanup

### Session Cancellation Flow

#### From TimerRunningView UI (Cancel Button)
1. User taps "Cancel" button in TimerRunningView
2. `endLiveActivity(completed: false)` is called to end the Live Activity
3. `reset()` is called to clean up timer state
4. View is dismissed via `presentationMode.wrappedValue.dismiss()`
5. `onDisappear` lifecycle method handles resource cleanup
   - No HealthKit operations performed

#### From Live Activity Widget (Cancel Button)
1. User taps "Cancel" button in Live Activity
2. Deep link with scheme `littlemoments://cancelSession` is triggered
3. App's `handleDeepLink` method is called
4. If timer is active, app posts `cancelSession` notification
5. Notification observer in TimerViewModel:
   - Sets `wasCancelled` flag to true
   - Calls `endLiveActivity(completed: false)`
   - Calls `reset()` to clean up timer state
6. App dismisses TimerRunningView via `appState.showTimerRunningView = false`
7. If a `finishSession` notification arrives later, it will be ignored due to the `wasCancelled` flag
8. `onDisappear` lifecycle method handles resource cleanup
   - No HealthKit operations performed

### Notification Handling Safeguards

The app includes safeguards to prevent accidental HealthKit writes during cancellation:

1. The `wasCancelled` flag:
   - Set to `true` when `cancelSession` notification is received
   - Checked at the beginning of the `finishSession` notification handler
   - Prevents `finishSession` from processing if a cancellation occurred first
   - Reset to `false` in the `reset()` method for clean state in future sessions

2. Notification Priority:
   - Cancellation takes precedence over completion
   - The app will not write to HealthKit if a cancellation occurred, even if completion notifications arrive later

### Key Considerations
1. HealthKit writes happen at well-defined points in the flow:
   - Directly after `prepareSessionForFinish()` in completion paths
   - Never called in cancellation paths
2. Each entry point (app UI or Live Activity) performs HealthKit operations at the same logical point
3. View lifecycle method `onDisappear` is solely responsible for resource cleanup
4. The `wasCancelled` flag prevents race conditions between cancel and finish notifications

This simplified design provides a more direct and predictable control flow, with clearer separation of responsibilities and robust handling of notification sequences.
