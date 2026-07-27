---
id: TASK-9
title: Experiment with minute-boundary Live Activity updates
status: Later
assignee: []
created_date: '2026-07-27 14:00'
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
- [ ] #1 With Show Seconds disabled, the running Live Activity displays elapsed whole minutes and no seconds.
- [ ] #2 ActivityKit content updates occur no more than once per elapsed-minute change, aside from explicit start, target-change, activation/reconciliation, and completion updates.
- [ ] #3 During a locked physical-device run on IBmini, the elapsed-minute label advances across at least three minute boundaries without opening the app.
- [ ] #4 The linear progress bar remains system-driven and continues advancing smoothly between ActivityKit updates.
- [ ] #5 The Live Activity archive loads successfully with visible title and button labels; placeholder capsules do not recur.
- [ ] #6 Behavior when background audio is disabled, interrupted, or the app is terminated is tested or explicitly documented.
- [ ] #7 If the host process is suspended and minute updates stop, the experiment records the result and is not adopted without an agreed fallback.
- [ ] #8 Scoped formatting and strict lint pass, relevant tests pass, and the app/widget build succeeds.
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
<!-- SECTION:NOTES:END -->
