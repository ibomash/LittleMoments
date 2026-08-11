---
id: TASK-9
title: Experiment with minute-boundary Live Activity updates
status: Done
assignee: []
created_date: '2026-07-27 14:00'
updated_date: '2026-07-31 12:18'
labels:
  - ui
dependencies: []
references:
  - LittleMoments/WidgetExtension/MeditationLiveActivityView.swift
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Experiment with restoring app-driven ActivityKit content updates at whole-minute boundaries so the Lock Screen can display elapsed whole minutes without seconds. The experiment tests whether the active background-audio session keeps the host process executing while locked. Preserve the system-driven timer-interval progress bar, avoid the former one-second update loop, and do not introduce an APNs dependency.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The locked-device experiment records whether app-driven minute updates advance the no-seconds label; result: the label remained at 0, so the approach was not adopted.
- [x] #2 Diagnostic logs verify that attempted ActivityKit publications occurred at elapsed-minute changes (60, 120, and 180 seconds), aside from explicit lifecycle updates.
- [x] #3 A locked physical-device run on IBmini spans at least three minute boundaries without opening the app and records the observed label behavior.
- [x] #4 The linear progress bar remains system-driven and continues advancing smoothly between ActivityKit updates.
- [x] #5 After rollback to SwiftUI system-relative date text, the Live Activity archive/content-load validation succeeds without the custom formatter or placeholder regression.
- [x] #6 Behavior when background audio is disabled, interrupted, or the app is terminated is tested or explicitly documented.
- [x] #7 If the host process is suspended and minute updates stop, the experiment records the result and is not adopted without an agreed fallback.
- [x] #8 Scoped formatting and strict lint pass, relevant tests pass, and the app/widget build succeeds.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Render the no-seconds elapsed label from the latest secondsElapsed content-state snapshot.
- Track the last published whole minute and call Activity.update only when that value changes.
- Reconcile immediately at activity start, target-duration changes, app/scene activation, and session completion.
- Keep ProgressView(timerInterval:countsDown:) system-driven.
- Add focused tests and diagnostics for minute deduplication and lifecycle reconciliation.
- Validate on IBmini while locked under the default background-audio mode, then test or document behavior when background execution is unavailable.
- Keep or revert the experiment based on physical-device results.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Historical evidence: before ef1661c, TimerRunningView pushed ActivityKit state every second and the widget rendered a static secondsElapsed snapshot. Commit ef1661c removed that loop immediately before the robust background-audio branch was merged. Commit 727633b later validated continued locked-screen execution through a one-minute audio session on IBmini. Commit 28563d4 introduced the custom minute formatter that triggered archive/rendering failures. Suggested experiment branch: codex/live-activity-minute-updates-experiment.

2026-07-27 implementation on codex/live-activity-minute-updates-experiment:
- The existing one-second timer used for scheduled-bell checks now requests an elapsed reconciliation; LiveActivityUpdateGate permits Activity.update only when the whole-minute value changes. Start, target changes, scene activation, and completion remain explicit publication points.
- With Show Seconds disabled, the widget renders the latest secondsElapsed snapshot through the existing plain String formatter. The timed ProgressView remains based on startDate...targetEndDate, so the system continues animating it between content updates.
- OSLog diagnostics record start, elapsedMinute, targetChanged, sceneActivated, recovery, and completion publications. Existing ActivityKit activities are recovered for activation reconciliation when the host process is still able to reconstruct the running session.
- Degradation is intentional for this experiment: minute publication depends on the host process being scheduled. If background audio is disabled, interrupted, or suspended, the no-seconds label freezes at its last published whole minute; a timed progress bar continues system-driven. Force-termination stops minute publications, and the in-memory timer session is not reconstructed on a cold launch. There is no APNs fallback. Do not adopt the experiment if the locked IBmini run shows suspension without an agreed fallback.
- Validation: scoped swift-format and strict SwiftLint passed; Fastlane LittleMomentsTests passed 118 tests with 0 failures; the Fastlane build lane succeeded for LittleMoments, LittleMoments-UI, and LittleMomentsWidgetExtension. Locked IBmini three-boundary validation and archive/content-load inspection remain pending.

2026-07-27 IBmini device result: app logs showed minute-boundary update attempts, but the Lock Screen label remained at 0 after several minutes. This disproves acceptance criterion 1 for the first implementation and keeps the experiment unadopted. Diagnosis: LiveActivityManager cached an Activity without verifying that it could still receive updates and requested a new activity without dismissing existing instances, so logs could describe updates to a different or ended activity than the one visible on the Lock Screen. Follow-up now dismisses prior activities before start, resolves only active/stale activities, timestamps local updates, and logs activity ID, lifecycle state, active count, requested elapsed, and ActivityKit stored elapsed for device verification.

Follow-up validation: scoped formatting and strict lint passed; LittleMomentsTests passed 118 tests with 0 failures; the Fastlane build lane passed LittleMoments, LittleMoments-UI, and LittleMomentsWidgetExtension. Device retest should confirm a single start log with active_count=1 and matching activity ID on minute logs; requested_elapsed and stored_elapsed should both cross 60, 120, and 180.

Second IBmini device run ruled out stale identity: the same activity ID remained active with active_count=1. A foreground target update was accepted, but background publications requested elapsed values 60, 120, and 180 while ActivityKit stored elapsed remained 1.1 and the Lock Screen stayed at 0. Background audio kept the host process executing, but did not make local ActivityKit content updates commit or render. Per the experiment rollback criterion, the minute publisher and diagnostics were removed and the widget was restored to the system-driven relative date display.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Experiment completed and not adopted. Physical-device evidence showed that local ActivityKit updates issued once per minute from the background-running app were not committed to the Live Activity, despite the process running and addressing the correct active activity. Rolled back the experimental publisher and retained the system-driven relative timer; no APNs fallback was added.
<!-- SECTION:FINAL_SUMMARY:END -->
