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
- [ ] Create MeditationLiveActivityView for Lock Screen view
- [ ] Create compact Dynamic Island view
- [ ] Create expanded Dynamic Island view
- [ ] Create LiveActivityWidgetBundle
- [ ] UI tests for Live Activity views

### Phase 3: Integration with Timer
- [ ] Update TimerViewModel to start/stop Live Activities
- [ ] Update TimerRunningView to handle Live Activity lifecycle
- [ ] Add live activity updating
- [ ] Add end session functionality from Live Activity
- [ ] Unit tests for timer integration

### Phase 4: Haptic Feedback and Refinements
- [ ] Add haptic feedback for session completion
- [ ] Visual refinements for different screen sizes
- [ ] Add accessibility support
- [ ] Final UI tests
- [ ] Comprehensive integration testing

### Detailed Technical Specifications

#### Phase 1: Basic Live Activity Setup

##### 1.1 Update project entitlements
- Add Push Notifications entitlement
- Set background modes for remote notifications

##### 1.2 Create MeditationLiveActivityAttributes model
```swift
import ActivityKit
import Foundation

struct MeditationLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var secondsElapsed: Double
        var targetTimeInSeconds: Double?
        var isCompleted: Bool
    }
    
    var sessionName: String
}
```

##### 1.3 Create LiveActivityManager
```swift
import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var activity: Activity<MeditationLiveActivityAttributes>?
    
    private init() {}
    
    func startActivity(sessionName: String, targetTimeInSeconds: Double?) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not available")
            return
        }
        
        let initialState = MeditationLiveActivityAttributes.ContentState(
            secondsElapsed: 0,
            targetTimeInSeconds: targetTimeInSeconds,
            isCompleted: false
        )
        
        let attributes = MeditationLiveActivityAttributes(sessionName: sessionName)
        
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
        } catch {
            print("Error starting live activity: \(error)")
        }
    }
    
    func updateActivity(secondsElapsed: Double, isCompleted: Bool = false) {
        Task {
            let updatedState = MeditationLiveActivityAttributes.ContentState(
                secondsElapsed: secondsElapsed,
                targetTimeInSeconds: activity?.contentState.targetTimeInSeconds,
                isCompleted: isCompleted
            )
            
            await activity?.update(using: updatedState)
        }
    }
    
    func endActivity() {
        Task {
            await activity?.end(
                using: activity?.contentState ?? MeditationLiveActivityAttributes.ContentState(
                    secondsElapsed: 0,
                    targetTimeInSeconds: nil,
                    isCompleted: true
                ),
                dismissalPolicy: .immediate
            )
            activity = nil
        }
    }
}
```

##### 1.4 Update JustNowSettings
```swift
// Add to JustNowSettings.swift
var enableLiveActivities: Bool {
    get {
        if let value = userDefaults.object(forKey: "enableLiveActivities") as? Bool {
            return value
        } else {
            return true  // Default value
        }
    }
    set {
        userDefaults.set(newValue, forKey: "enableLiveActivities")
        userDefaults.synchronize()
    }
}
```

#### Phase 2: Live Activity UI Implementation

##### 2.1 Create MeditationLiveActivityView
```swift
import SwiftUI
import WidgetKit
import ActivityKit

struct MeditationLiveActivityView: View {
    let context: ActivityViewContext<MeditationLiveActivityAttributes>
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(showsWidgetBackground ? .clear : .black.opacity(0.1))
                
            VStack {
                Text("Meditation in progress")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    // Timer display
                    VStack {
                        Text(timerDisplay)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .minimumScaleFactor(0.5)
                    }
                    
                    // Progress bar (for timed sessions)
                    if let targetTime = context.state.targetTimeInSeconds, targetTime > 0 {
                        ProgressView(value: min(context.state.secondsElapsed / targetTime, 1.0))
                            .progressViewStyle(.circular)
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.vertical, 4)
                
                // End session button
                Button("End Session") {
                    // This will be handled by deeplink
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }
            .padding()
        }
    }
    
    private var timerDisplay: String {
        let totalSeconds = Int(context.state.secondsElapsed)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

##### 2.2 Create LiveActivityWidgetBundle
```swift
import WidgetKit
import SwiftUI
import ActivityKit

@main
struct MeditationWidgets: WidgetBundle {
    var body: some WidgetBundleBuilder {
        MeditationLiveActivityWidget()
    }
}

struct MeditationLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MeditationLiveActivityAttributes.self) { context in
            MeditationLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(timerDisplayFromSeconds(context.state.secondsElapsed))
                            .monospacedDigit()
                            .font(.title2)
                    } icon: {
                        Image(systemName: "timer")
                    }
                    .padding(.leading)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if let targetTime = context.state.targetTimeInSeconds {
                        ProgressView(value: min(context.state.secondsElapsed / targetTime, 1.0))
                            .progressViewStyle(.circular)
                            .frame(width: 40, height: 40)
                            .padding(.trailing)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Button("End Session") {
                        // Will be handled via deep link
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                Text(timerDisplayFromSeconds(context.state.secondsElapsed))
                    .monospacedDigit()
                    .font(.caption2)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
    
    private func timerDisplayFromSeconds(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        
        return String(format: "%d:%02d", minutes, secs)
    }
}
```

#### Phase 3: Integration with Timer

##### 3.1 Update TimerViewModel
```swift
// Add to TimerViewModel.swift
func startLiveActivity() {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    let targetSeconds = scheduledAlert?.targetTimeInSec
    LiveActivityManager.shared.startActivity(
        sessionName: "Meditation",
        targetTimeInSeconds: targetSeconds
    )
}

func updateLiveActivity() {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    LiveActivityManager.shared.updateActivity(secondsElapsed: secondsElapsed)
}

func endLiveActivity(completed: Bool = true) {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    if completed {
        LiveActivityManager.shared.updateActivity(
            secondsElapsed: secondsElapsed,
            isCompleted: true
        )
    }
    
    LiveActivityManager.shared.endActivity()
}
```

##### 3.2 Update TimerRunningView
```swift
// Update onAppear in TimerRunningView.swift
.onAppear {
    timerViewModel.start()
    timerViewModel.startLiveActivity()
    UIApplication.shared.isIdleTimerDisabled = true
    if JustNowSettings.shared.ringBellAtStart {
        SoundManager.playSound()
    }
    
    // Update timer for Live Activity
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        timerViewModel.updateLiveActivity()
    }
}

// Update onDisappear in TimerRunningView.swift
.onDisappear {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    timerViewModel.writeToHealthStore()
    timerViewModel.endLiveActivity()
    timerViewModel.reset()
    UIApplication.shared.isIdleTimerDisabled = false
}
```

#### Phase 4: Haptic Feedback and Refinements

##### 4.1 Add haptic feedback for session completion
```swift
// Add to LiveActivityManager.swift
import CoreHaptics

func provideTapticFeedback() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
```

##### 4.2 Add deep linking to handle Live Activity actions
```swift
// In Little_MomentsApp.swift
.onOpenURL { url in
    handleDeepLink(url: url)
}

func handleDeepLink(url: URL) {
    guard url.scheme == "littlemoments" else { return }
    
    if url.host == "endSession" {
        // End the current session
        if let timerViewModel = getActiveTimerViewModel() {
            timerViewModel.endLiveActivity()
            timerViewModel.writeToHealthStore()
            timerViewModel.reset()
        }
    }
}
```

### Tests

#### Unit Tests
1. LiveActivityManagerTests
```swift
import XCTest
@testable import LittleMoments

final class LiveActivityManagerTests: XCTestCase {
    func testActivityInitialization() {
        // Test initialization with valid parameters
    }
    
    func testActivityUpdate() {
        // Test updating activity state
    }
    
    func testActivityTermination() {
        // Test properly ending an activity
    }
}
```

2. TimerViewModelLiveActivityTests
```swift
import XCTest
@testable import LittleMoments

final class TimerViewModelLiveActivityTests: XCTestCase {
    func testStartLiveActivity() {
        // Test that live activity starts when timer starts
    }
    
    func testUpdateLiveActivity() {
        // Test that live activity updates with timer
    }
    
    func testEndLiveActivity() {
        // Test that live activity ends when timer ends
    }
}
```

#### UI Tests
1. LiveActivityUITests
```swift
import XCTest

final class LiveActivityUITests: XCTestCase {
    func testLiveActivityAppears() {
        // Test that live activity appears when timer starts
    }
    
    func testLiveActivityUpdates() {
        // Test that live activity updates correctly
    }
    
    func testLiveActivityEndsWithTimer() {
        // Test that live activity ends when timer ends
    }
}
```

### Open Questions
1. How should we handle notification permissions if denied?
   - We could add a specific error state or graceful fallback for users who deny notification permissions but try to use Live Activities.

2. Should we support different visual styles for the Live Activity based on the user's settings?
   - We could consider extending the settings to allow customization of the Live Activity appearance.

3. How should we handle app upgrades or reinstallations with active Live Activities?
   - We need to ensure that the app can reconnect to existing Live Activities after updates.

4. What is the best way to test Live Activities in the development phase?
   - We should establish a testing protocol specifically for Live Activities since they require special testing approaches.

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
