---
id: doc-20
title: "Spec: Timer Background Task Tests"
type: "tech-debt"
created_date: "2025-09-17 01:14"
source_path: "todo/tech-debt/timer-background-task-tests.md"
---
# Spec: Timer Background Task Tests

## Objective
Cover the timer background task lifecycle so regressions in how `TimerViewModel` cooperates with `UIApplication` are caught before shipping.

## Current Gaps
- `TimerViewModel.start()` begins a background task but we have no verification that an identifier is stored or that the expiration handler resets state.
- `TimerViewModel.reset()` attempts to end any active background task, yet we lack tests proving it always calls `endBackgroundTask` and clears the identifier.
- Expiration handlers should end tasks even when `reset()` is never called (e.g., the system terminates background execution), but we currently have no automated coverage.
- Because `TimerViewModel` touches `UIApplication.shared` directly, it is impossible to validate the behavior with a deterministic test double today.

## Proposed Test Coverage
### Start Lifecycle
- When `start()` is invoked, `beginBackgroundTask` should be called once and the returned identifier stored on the view model.
- The expiration handler passed to `beginBackgroundTask` should call `endBackgroundTask` and set the identifier back to `.invalid`.

### Reset Lifecycle
- If `backgroundTask` is active, `reset()` should call `endBackgroundTask` exactly once and reset the identifier to `.invalid`.
- When no background task exists, `reset()` should skip additional calls (preventing redundant `endBackgroundTask` invocations).

### Integration With Timer Cancellation
- Triggering the expiration handler while the timer is running should leave the timer in a clean state (no leaked identifier, timer invalidated).

## Implementation Plan
1. **Abstract UIApplication Access**
   - Introduce a `BackgroundTaskManaging` protocol exposing `beginBackgroundTask(withName:expirationHandler:)` and `endBackgroundTask(_:)` along with `isIdleTimerDisabled` mutation where needed.
   - Provide a production wrapper backed by `UIApplication.shared` and inject it into `TimerViewModel` (defaulting to the live app).

2. **Provide Test Doubles**
   - Create a spy implementation recording begin/end invocations, capturing the expiration handler, and exposing the identifiers used.

3. **Refactor TimerViewModel**
   - Update the initializer to accept the new dependency so tests can inject the spy.
   - Ensure resetting the timer also notifies the injected manager rather than `UIApplication.shared` directly.

4. **Author Tests**
   - Add `TimerBackgroundTaskTests` verifying each scenario above using the spy.
   - Simulate the expiration handler by invoking the captured closure to ensure cleanup occurs without manual reset calls.

## Dependencies & Tooling
- `XCTest`
- Newly introduced protocol + wrapper inside the production module

## Acceptance Criteria
- Tests fail if the timer stops ending background tasks or fails to clear identifiers when required.
- `TimerViewModel` no longer references `UIApplication.shared` directly for background task management, enabling deterministic tests.
- Expiration handler behavior is covered so a regression (e.g., forgetting to set identifier back to `.invalid`) is caught immediately.
