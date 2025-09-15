# Spec: Timer UI Flow UI Tests

## Objective
Add UI automation that exercises the primary meditation timer flows so changes to SwiftUI views or wiring between `TimerStartView` and `TimerRunningView` are caught immediately.

## Current Gaps
- No XCUITests cover the start-to-finish timer journey, so regressions in sheet presentation or button wiring can ship unnoticed.
- Duration preset buttons expose accessibility identifiers (e.g., `duration_5`) but nothing verifies they toggle or remain selected.
- Cancel and complete actions are untested, so future refactors could stop dismissing the running timer or leave lingering state.
- Launch-time setup (e.g., notification authorization requests) isn’t exercised under UI automation, risking prompts or flakiness without guardrails.

## Proposed Test Coverage
1. **Launch Smoke Test**
   - Launch the app with `-DISABLE_SYSTEM_INTEGRATIONS` to bypass HealthKit/notification work.
   - Assert the start screen renders the mantra emoji, settings button, and “Start session” control.

2. **Start Session Flow**
   - Tap “Start session” and verify the timer sheet appears by asserting the existence of the cancel/complete buttons and the timer label.
   - Confirm that `UIApplication.shared.isIdleTimerDisabled` toggling is observable via the background task spy when available (or future instrumentation).

3. **Duration Preset Selection**
   - Tap a preset button (e.g., “5”) and verify its accessibility identifier flips to `selected_duration_5`.
   - Tap the same button again to ensure it toggles off and pending notifications are removed (observed via NotificationManager spy instrumentation once available).

4. **Cancel Flow**
   - From the running view, tap “Cancel” and assert the sheet dismisses back to the start screen.
   - Validate that the timer sheet disappears within a reasonable timeout to guard against regressions in dismissal logic.

5. **Complete Flow (Smoke)**
   - Start a session, tap “Complete”, and confirm the start screen reappears without crashing.
   - Use launch arguments to disable system integrations so HealthKit/notification side effects don’t interfere with the UI test run.

6. **Settings Sheet**
   - From the start screen, tap the gear button and ensure the settings sheet appears, then dismiss it to verify bidirectional sheet control.

## Implementation Plan
1. **Create XCUITest Target Coverage File**
   - Add `TimerUITests` XCTestCase with helper methods for launching the app using the shared `UITestApp` wrapper (if available) or `XCUIApplication` directly.

2. **Adopt Launch Arguments**
   - Append `-DISABLE_SYSTEM_INTEGRATIONS` (already honored by the views) plus any stubs needed for Live Activity/HealthKit to keep the run deterministic.

3. **Author Individual Tests**
   - One test per flow outlined above to keep failures focused.
   - Use accessibility identifiers already defined in SwiftUI (`duration_*`, `selected_duration_*`) for reliable element lookup.

4. **Add Helpers for Sheet Detection**
   - Implement polling helpers that wait for the timer sheet to appear/disappear via `.exists` checks to avoid flakiness.

5. **Future Enhancements**
   - Once NotificationManager and BackgroundTask tests introduce injectable spies, surface those toggles to UI tests (via launch environment) so UI automation can assert side effects without hitting real APIs.

## Dependencies & Tooling
- `XCTest` UI testing bundle
- Launch arguments wiring inside the main target (already partially implemented)

## Acceptance Criteria
- UI tests fail if the timer no longer opens, cancels, or completes correctly.
- Duration preset buttons must change accessibility state in UI automation, preventing accidental regressions in selection logic.
- Smoke coverage exists for the settings sheet and main navigation, ensuring primary mindfulness flows are under automation.
