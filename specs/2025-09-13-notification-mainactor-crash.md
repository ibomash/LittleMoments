# Swift 6 Concurrency Issues with UNUserNotificationCenter

Date: 2025-09-13

## Summary

After migrating to Swift 6, the app can crash when tapping a timer preset because SwiftUI/MainActor–isolated code is touched from a `UNUserNotificationCenter` background callback. Apple’s user notification authorization and scheduling APIs invoke completions on a private background queue; any access to `@MainActor`-isolated state inside those completions must hop to the MainActor first. Additionally, system completion handlers should be marked `@Sendable` under Swift 6’s stricter concurrency rules.

## Root Cause

Swift 6 enforces stricter concurrency rules:
- System completion handlers (notifications, HealthKit) run on background queues
- These handlers must be marked `@Sendable` to be concurrency-safe
- Any access to `@MainActor`-isolated state from these handlers requires explicit MainActor hopping
- `UNNotificationSettings` is not `Sendable`, so async/await wrappers must use continuation patterns

## Specific Issues Fixed

### 1. TimerStartView notification authorization
**Problem:** Completion handlers not marked `@Sendable`
```swift
// ❌ Before (Swift 6 error)
center.getNotificationSettings { settings in
  center.requestAuthorization(options: [.alert, .sound]) { _, _ in
```

**Solution:** Use async/await with NotificationManager
```swift
// ✅ After (Swift 6 compliant)
Task {
  await NotificationManager.shared.requestAuthorizationIfNeeded()
}
```

### 2. HealthKit authorization callback
**Problem:** Completion handler not marked `@Sendable`
```swift
// ❌ Before
HealthKitManager.shared.requestAuthorization { (success, error) in
```

**Solution:** Mark callback as `@Sendable`
```swift
// ✅ After
HealthKitManager.shared.requestAuthorization { @Sendable (success, error) in
```

### 3. Notification scheduling
**Problem:** Synchronous API call could block MainActor
```swift
// ❌ Before
UNUserNotificationCenter.current().add(request)
```

**Solution:** Use async version
```swift
// ✅ After
Task {
  try? await UNUserNotificationCenter.current().add(request)
}
```

### 4. Tests flaking due to system surfaces
**Problem:** UI tests were flaking due to OS permission surfaces and Live Activities.

**Solution:** Add a `-DISABLE_SYSTEM_INTEGRATIONS` launch argument and guard notification scheduling and Live Activities in code paths used by tests.

## Current Implementation (as of 2025-09-13)

### Architecture
- Created `NotificationManager` for centralized, concurrency-safe notification handling
- Request authorization on first main screen show (`TimerStartView.onAppear`)
- Schedule notifications best-effort (iOS drops unauthorized notifications)
- All system completion handlers marked `@Sendable`

### Files Modified
- `TimerStartView.swift` - Updated to use async notification authorization
- `JustNowSettings.swift` - Added `@Sendable` to HealthKit callback
- `TimerRunningView.swift` - Updated notification scheduling to use async/await
- Created `NotificationManager.swift` - Swift 6 compliant notification manager
- Moved example code into this spec as reference documentation (and removed example source from the app target)

### Swift 6 Concurrency Rules Applied
1. ✅ Mark completion handlers as `@Sendable`
2. ✅ Use `Task { @MainActor in ... }` to hop back to MainActor when needed
3. ✅ Prefer async/await over callbacks for new code
4. ✅ Use `nonisolated` functions for background work
5. ❌ Never access `@MainActor` properties directly from system callbacks

## Future Considerations

The notification permission request could potentially be moved to a more strategic location in the user flow, such as:
- During onboarding when explaining timer notifications
- Just before the user's first attempt to schedule a notification
- In settings when the user enables notification-related features

This would provide better UX by explaining the purpose of the permission before requesting it.

## Test Strategy

Integration UI test (`TimerIntegrationUITests`) exercises the authorization path without `-DISABLE_SYSTEM_INTEGRATIONS` to catch MainActor violations and crashes.

## Why It Crashes

- `UNUserNotificationCenter` completions and delegate methods run on a background queue.
- `@Published` properties in `TimerViewModel`, `AppState.showTimerRunningView`, and other `@MainActor` APIs must be accessed on the MainActor.
- When the background completion directly updates those properties or calls `@MainActor` APIs, Swift’s concurrency runtime detects crossing actor boundaries incorrectly and asserts.

## Desired Threading Model (What should happen)

1) UI action (SwiftUI Button) runs on MainActor.
2) MainActor updates SwiftUI state (e.g., set selected duration) before any background calls.
3) Off-main work (requesting permission, scheduling the notification) runs on a background queue.
4) Any subsequent UI/MainActor updates happen only via an explicit MainActor hop (e.g., `await MainActor.run { ... }` or `Task { @MainActor in ... }`).

## Observed Problem Areas

- `UNUserNotificationCenter.requestAuthorization` completion previously changed UI/model state directly.
- Any future additions to that completion (e.g., to show banners, persist state) can reintroduce the bug if not MainActor-hopped.

## Approaches to Fix (Design Options)

### Option A: Minimal fix (wrap completion in MainActor)

- Wrap the authorization completion (and any future `UN...` completions) with `Task { @MainActor in ... }` before touching any `@MainActor` state.
- Pros: Smallest change; easy to reason about; minimal code churn.
- Cons: Easy to regress if future edits add state changes outside the MainActor hop; still mixes callback-style APIs with MainActor code.

### Option B: Use async/await wrappers for UN APIs (preferred)

- Replace callback-based APIs with async wrappers:
  - e.g., wrap `requestAuthorization` with `withCheckedContinuation` and expose an `async` function.
  - Similarly wrap `add(request:)` if you need completion handling.
- Perform scheduling inside a detached `Task` or a nonisolated context that doesn’t capture `@MainActor` state; only hop to MainActor when updating SwiftUI state.
- Pros: Structured concurrency clarifies where suspension occurs; fewer callback queues; easier to enforce "no MainActor touches" in background code.
- Cons: Requires refactoring to async functions; need to ensure no MainActor state is captured inadvertently in tasks.

### Option C: Extract a NotificationScheduler service (actor or class)

- Create a `NotificationScheduler` component not annotated with `@MainActor` that owns all notification logic.
- Expose an `async` API (e.g., `scheduleTimerNotification(duration: Int) async throws`).
- UI layer calls it from MainActor; the scheduler runs off-main and never touches UI state; upon completion, the caller may hop to MainActor if needed.
- Pros: Clear separation; easier unit testing with protocol + fake; avoids UI-state in system callbacks completely.
- Cons: Slightly more boilerplate and DI; coordination required to report errors back to UI.

### Option D: Centralize all UI state mutations

- Keep all state changes before/after scheduling (never inside system callbacks). Any callback should only perform non-UI work (e.g., building requests, logging). If any UI state must change based on callback results, publish via `MainActor.run`.
- Pros: Keeps UI logic linearly on the MainActor.
- Cons: Sometimes you really do need to react to callback outcomes (e.g., permission denied) and must carefully hop to MainActor.

## Test Strategy

1) UI Flow (stable): existing `TimerFlowUITests` use `-DISABLE_SYSTEM_INTEGRATIONS` to avoid flakiness from OS surfaces and validate core flow.
2) UI Integration (crash-catcher): `TimerIntegrationUITests` runs without that flag and exercises the authorization path on main screen show (permission sheet), and then the scheduling path when a duration is selected; the test fails if the app crashes.
3) Unit Tests: Prefer adding a `NotificationScheduler` protocol and test double to assert `add(request)` is invoked with expected trigger/content.

---

## Appendix: Swift 6 Notification Examples

The following examples demonstrate two safe patterns in Swift 6 for requesting notification permissions and scheduling notifications without violating MainActor isolation.

```swift
//
//  Swift6NotificationExamples.swift
//  Little Moments
//
//  Reference examples for handling notification permissions in Swift 6
//

import Foundation
import UserNotifications

// MARK: - Option A: Minimal Fix (Callback + @Sendable + MainActor.run)

class CallbackApproach {
  @MainActor
  func requestNotificationPermissionCallback() {
    let center = UNUserNotificationCenter.current()

    center.getNotificationSettings { @Sendable settings in
      guard settings.authorizationStatus == .notDetermined else { return }

      center.requestAuthorization(options: [.alert, .sound]) { @Sendable granted, _ in
        // ✅ Safe: No UI state access here
        print("Authorization granted: \(granted)")

        // ❌ BAD: This would crash in Swift 6
        // self.someUIProperty = granted

        // ✅ GOOD: If you need to update UI, hop to MainActor
        if granted {
          Task { @MainActor in
            // Update UI state here safely
            print("Can now update UI on MainActor")
          }
        }
      }
    }
  }
}

// MARK: - Option B: Async/Await Approach (Recommended)

@MainActor
class AsyncApproach {
  func requestNotificationPermissionAsync() async {
    let center = UNUserNotificationCenter.current()

    // Check current status using callback approach for Swift 6 compliance
    let authStatus = await withCheckedContinuation { continuation in
      center.getNotificationSettings { @Sendable settings in
        continuation.resume(returning: settings.authorizationStatus)
      }
    }

    guard authStatus == .notDetermined else { return }

    do {
      // Request authorization using async/await
      let granted = try await center.requestAuthorization(options: [.alert, .sound])

      // ✅ Safe: We're already on MainActor, can update UI directly
      print("Authorization granted: \(granted)")
      // self.someUIProperty = granted // This would be safe here

    } catch {
      print("Authorization failed: \(error)")
    }
  }

  // Alternative: Non-isolated function for use from background
  nonisolated func scheduleNotificationFromBackground() async {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "Timer Complete"
    content.body = "Your session has finished"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)

    try? await center.add(request)

    // If we need to update UI after scheduling:
    await MainActor.run {
      print("Notification scheduled, updating UI on MainActor")
    }
  }
}

// MARK: - Key Swift 6 Concurrency Rules for Notifications

/*
 1. ✅ Always mark completion handlers as @Sendable
 2. ✅ Use Task { @MainActor in ... } to hop back to MainActor when needed
 3. ✅ Prefer async/await over callbacks for new code
 4. ✅ Mark functions as nonisolated if they don't need MainActor isolation
 5. ❌ Never access @MainActor properties directly from system callbacks
 6. ❌ Never call @MainActor methods directly from background queues

 Swift 6 enforces these rules at compile time and runtime, preventing
 the MainActor violations that could cause crashes in previous versions.
 */
```

## Recommendation

- Starting point: Keep the current approach (ask on main screen show; schedule best‑effort on selection).
- Next iteration (preferred): Implement Option C (NotificationScheduler) and/or use async wrappers (Option B) so notification logic is isolated, testable, and never touches UI state.
- Keep the integration UI test to guard against regressions.

## Acceptance Criteria

- No MainActor violations during notification authorization or scheduling.
- Integration UI test passes without `-DISABLE_SYSTEM_INTEGRATIONS`.
- Unit tests cover scheduling logic via a test double (if Option C is implemented).
