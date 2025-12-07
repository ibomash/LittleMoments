# iOS Best-Practice Review (Little Moments)

Date: 2025-12-05  
Scope: Swift 6 / iOS 26 review of current codebase (App, Core, Features, WidgetExtension, Tests).

## Key Gaps Observed

- **Dependency management:** Extensive use of singletons (`AppState.shared`, `JustNowSettings.shared`, managers) couples layers and complicates testing. Services are not protocolized or injected.
- **Settings persistence:** `JustNowSettings` uses computed properties with `UserDefaults.synchronize()` and no observation; toggles rely on globals rather than `@AppStorage` / `Observable` state.
- **Deep-link flow:** `handleDeepLink` reaches into UIKit view hierarchies (`getActiveTimerViewController`, `findTimerRunningView` returns `nil`), so finish/start actions may silently fail; no centralized routing.
- **Timer & background handling:** Relies on `Timer`/`DispatchQueue` and a single `UIBackgroundTask` without cancellation ties to scene phase; tasks can leak or run after view disappearance.
- **Concurrency isolation:** Many managers are `@MainActor` while performing I/O (HealthKit saves, notification scheduling, Live Activity updates), risking main-thread stalls; limited use of structured concurrency.
- **Live Activities:** Updates driven by a repeating `Timer` rather than a cancellable `Task`; no authorization/state change checks; Live Activity lifetime not coordinated with scene/background transitions.
- **HealthKit safety:** Writes are attempted without re-checking authorization/denial, and errors are only printed; no user feedback path.
- **Audio session:** `SoundManager` sets category but never activates, and ignores route/interruption changes; no background audio policy configuration.
- **Privacy compliance:** No `PrivacyInfo.xcprivacy` describing HealthKit, ActivityKit, notification, or audio usage—required for iOS 18+ App Store submissions.
- **Logging:** Wide use of `print`; minimal `os.Logger` with privacy annotations, making production diagnostics weak.
- **Accessibility & localization:** Hard-coded strings; limited `accessibilityLabel`/Dynamic Type/VoiceOver coverage; gradients/glass treatment lack high-contrast fallbacks beyond reduce-transparency.
- **Testing coverage gaps:** No tests for deep links, HealthKit authorization gating, notification errors, audio interruptions, or Live Activity lifecycle; no snapshot/accessibility UI tests.

## Recommended Actions (Prioritized)

1. Introduce light dependency injection (protocol-backed services passed via environment/constructors) and convert settings to an `@Observable`/`@AppStorage` store; remove global singletons from views.
2. Refactor timer flow to structured concurrency: replace `Timer` with `Clock`/`AsyncSequence`, manage cancellation via view `Task`s and `scenePhase`, and scope background tasks.
3. Add centralized deep-link/router layer that triggers state changes rather than poking view hierarchies; unit test parsing and race-condition guards.
4. Tighten HealthKit path: preflight authorization, surface failures, and gate writes; move heavy work off the main actor.
5. Standardize logging with `os.Logger` categories and privacy annotations; remove `print`.
6. Ship a `PrivacyInfo.xcprivacy` manifest covering HealthKit, ActivityKit, notifications, and audio; ensure reasons align with usage.
7. Harden audio handling: activate session, listen for interruptions/route changes, and decide on mixing/background policy.
8. Expand tests: deep-link flows, HealthKit gating, notification scheduling errors, Live Activity start/update/end, audio interruptions; add snapshot and accessibility UI tests for custom controls/glass UI.
9. Improve accessibility/localization: externalize strings, add semantic labels/traits, support Dynamic Type and reduce-motion; ensure contrast for glass backgrounds.

## Quick Wins

- Swap `synchronize()` calls for `@AppStorage` bindings to make settings reactive.
- Replace repetitive `Timer` live-activity updater with a cancellable `Task` tied to view appearance.
- Introduce `Logger` instances (per subsystem/category) and wrap current `print` calls.
