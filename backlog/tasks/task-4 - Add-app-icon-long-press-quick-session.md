---
id: TASK-4
title: Add app icon long-press quick session
status: Done
assignee: []
created_date: '2025-09-17 13:00'
updated_date: '2026-02-23 19:42'
labels:
  - ui
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Define and implement a Home Screen quick action so users can start a meditation session directly from the app icon long-press menu. Align on which duration should launch, how it interacts with existing quick actions, and what feedback the user gets when the app opens.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 At least one long-press quick action starts a session without additional taps once the app opens.
- [x] #2 Behavior documented for when a session is already running or HealthKit permissions are missing.
- [x] #3 QA notes cover supported devices/iOS versions and any limitations of Home Screen quick actions.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1) Add a static Home Screen quick action for a 5-minute session in Info.plist. 2) Route quick action selections into app state using a SwiftUI-compatible scene delegate bridge. 3) Add/extend unit tests for quick action parsing and in-app behavior (including already-running session handling). 4) Capture behavior/QA limitations in task notes and mark ACs complete.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented app-side handling for a new Home Screen quick action type (net.bomash.illya.LittleMoments.startQuickSession) with a default 5-minute preset, plus a guard that ignores new start requests when a session is already running.

Added scene/app delegate bridge for UIApplicationShortcutItem callbacks so long-press actions route into AppState in SwiftUI lifecycle apps.

Added unit tests covering quick action handling, custom duration parsing, unknown action handling, and already-running-session behavior.

Behavior documentation: if a session is already running, quick-start requests are ignored and the current session continues unchanged (no pending preset is queued).

Behavior documentation: Home Screen quick start does not depend on HealthKit authorization; it always opens a session. Health writes remain governed by existing settings/permission checks at completion time.

QA notes: validate on iOS 26+ devices (iPhone/iPad) from the Home Screen app icon long-press menu. Verify Quick Session opens TimerRunningView with the 5-minute preset selected, verify the in-session ignore behavior, and verify start still works when HealthKit permission is denied or writeToHealth is off. Limitation: Home Screen quick actions are not reliably triggerable from current XCUITest deep-link helpers and should be manually verified on device.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented a Home Screen long-press quick action (Quick Session) that launches directly into a 5-minute session via AppState, with app/scene delegate routing for UIApplicationShortcutItem handling in the SwiftUI lifecycle. Added guards so start requests are ignored when a session is already running, documented HealthKit-permission behavior and QA limitations in task notes, and expanded DeepLinkTests with quick-action coverage. Validation completed: fastlane format_code, fastlane lint, and fastlane test_targets (LittleMomentsTests) all pass in the current environment.
<!-- SECTION:FINAL_SUMMARY:END -->
