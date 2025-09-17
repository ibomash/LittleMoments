---
id: doc-15
title: "Spec: NotificationManager Unit Tests"
type: "tech-debt"
created_date: "2025-09-17 01:14"
source_path: "todo/tech-debt/notification-manager-unit-tests.md"
---
# Spec: NotificationManager Unit Tests

## Objective
Add targeted unit coverage for the concurrency-safe `NotificationManager` so we can confidently request notification authorization, inspect authorization status, and schedule or clear timer alerts without relying on the simulator or real notification center.

## Current Gaps
- No automated verification of the async `requestAuthorization` pathways (success vs. thrown error).
- `getAuthorizationStatus()` bridging to `UNUserNotificationCenter.getNotificationSettings` lacks coverage to ensure the continuation resumes with the expected status.
- `requestAuthorizationIfNeeded()` is untested, so regressions could cause duplicate prompts or skipped authorization.
- `scheduleTimerNotification` is untested, leaving the content payload, trigger configuration, and error propagation unchecked.
- `removeAllPendingNotifications()` currently hits the live notification center in production code with no guardrails for future refactors.

## Proposed Test Coverage
### Authorization Requests
- **Success Path**: When the injected notification center returns `true`, `requestAuthorization` should surface `(granted: true, error: nil)`.
- **Failure Path**: When the underlying call throws, `requestAuthorization` should surface `(granted: false, error: TestError)`.

### Authorization Status + Conditional Prompting
- Verify `getAuthorizationStatus` relays the status returned by the notification center stub.
- Ensure `requestAuthorizationIfNeeded` calls `requestAuthorization` only when the status is `.notDetermined` and skips any additional work for `.denied`, `.authorized`, or `.provisional`.

### Scheduling
- Confirm `scheduleTimerNotification` forwards the identifier, title, body, sound name, and interval into the produced `UNNotificationRequest` and that `add` is invoked once.
- Validate errors thrown from the underlying `add` method propagate to the caller (allowing tests to catch misconfigured requests).

### Cleanup
- Assert `removeAllPendingNotifications` delegates to the injected notification center exactly once.

## Implementation Plan
1. **Introduce Dependency Injection**
   - Define a lightweight `UserNotificationCentering` protocol that exposes the subset of APIs used (`requestAuthorization`, `getNotificationSettings`, `add`, `removeAllPendingNotificationRequests`).
   - Update `NotificationManager` to accept a dependency (defaulting to `UNUserNotificationCenter.current()`) so tests can inject a deterministic stub.

2. **Build Test Doubles**
   - Create a `UserNotificationCenterSpy` that captures method invocations, returns canned responses, and can simulate thrown errors.
   - Supply async helpers that fulfill continuations deterministically (e.g., providing the desired `UNAuthorizationStatus`).

3. **Write XCTest Cases**
   - Cover each scenario outlined above using the spy.
   - Exercise `scheduleTimerNotification` from a background Task to ensure the nonisolated API remains testable without MainActor hops.

4. **Guard Against Regressions**
   - Add negative tests ensuring that `requestAuthorizationIfNeeded` does **not** call the spy when status is not `.notDetermined`.
   - Verify the spy records exactly one call for remove-all.

## Dependencies & Tooling
- `XCTest`
- New protocol types (should live inside the production target).
- Requires `@testable import LittleMoments`.

## Acceptance Criteria
- All new tests pass and fail without flakiness when the underlying implementation regresses.
- `NotificationManager` can be safely refactored without invoking the real `UNUserNotificationCenter` during unit tests.
- Coverage includes both success and failure paths for every public API in `NotificationManager`.
