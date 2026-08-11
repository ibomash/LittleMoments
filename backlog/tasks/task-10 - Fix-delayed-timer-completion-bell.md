---
id: TASK-10
title: Fix delayed timer completion bell
status: Done
assignee: []
created_date: '2026-07-30 01:31'
updated_date: '2026-07-30 21:05'
labels:
  - audio
  - bug
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make the audible completion bell begin at the timer's absolute deadline instead of several seconds after the UI reaches its target. Start with the smallest correction to the existing robust playback coordinator, then validate in Simulator and leave physical-device locked-screen validation for handoff.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A completion plan does not add audio setup time to the timer deadline.
- [x] #2 Existing target replacement and cancellation behavior remains intact.
- [x] #3 Automated tests cover the corrected remaining-time calculation.
- [x] #4 A short Simulator timer reaches the bell playback path without an artificial scheduling delay.
- [x] #5 Physical-device locked-screen timing is recorded after user validation.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Anchor the completion plan to the absolute session deadline.
- Recalculate the sleep interval after synchronous audio setup.
- Add focused regression coverage for deadline calculation.
- Run scoped format, lint, and tests through Fastlane.
- Exercise a short timer in Simulator and inspect bell diagnostics.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-07-29 simple fix: derive an absolute deadline from sessionStartDate + target duration, then recalculate remaining time after synchronous audio setup before scheduling the completion task. Added focused tests for post-setup remaining time and elapsed-deadline clamping.

Validation: Fastlane generation succeeded; scoped swift-format and strict SwiftLint passed; LittleMomentsTests passed 117/117. XcodeBuildMCP audio-only Simulator run selected the 5-second target at elapsed=4.796719. Audio setup completed about 55 ms later and the adjusted plan logged remaining=0.147536. completion_plan_fired occurred at about 5.44 seconds from session start; final_bell_started followed about 3 ms later, and the one-second progress check reported elapsed=0.903537, playing/ready, waiting_reason=none, and no player or item errors. Physical-device locked-screen validation remains open.

2026-07-30 device validation: user reported the completion bell was approximately 4 seconds late and accepted that timing as good enough for this fix. No further queue-handoff changes are required in TASK-10.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed the timer completion bell scheduling so synchronous audio setup time is no longer added to the target duration. The coordinator now derives an absolute deadline from the session start and recalculates its delay after audio preparation. Added regression tests, passed 117 unit tests and scoped formatting/lint, validated the audio-only bell path in Simulator, and accepted a physical-device result of approximately 4 seconds late.
<!-- SECTION:FINAL_SUMMARY:END -->
