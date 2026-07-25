---
id: TASK-8
title: Evaluate lower-overhead robust bell playback
status: Later
assignee: []
created_date: '2026-07-24 20:50'
updated_date: '2026-07-25 15:27'
labels:
  - performance
dependencies: []
documentation:
  - backlog/docs/doc-25 - Spec-Robust-Completion-Bell-Playback.md
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Follow up on the robust completion bell spike by measuring whether a simpler audio engine reduces background power use while preserving reliable bell timing and duration changes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Capture comparable untethered Power Profiler traces for the current implementation and AVAudioPlayer.
- [ ] #2 Verify screen-off bell timing, target replacement, extension after a bell, interruptions, and audio routes.
- [ ] #3 Adopt an alternative only if it measurably improves power use without making playback state harder to maintain.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Benchmark AVAudioPlayer with the 60-second silent asset against the current AVQueuePlayer/AVPlayerLooper implementation. Evaluate AVAudioEngine only if AVAudioPlayer does not materially improve power use or reliability.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Deferred while closing the initial robust bell feature. The current implementation now uses a 60-second silent loop to reduce AVPlayer item-boundary churn from once per second to once per minute.

2026-07-25 physical-device validation on IBmini reproduced a silent completion bell with the screen locked. Diagnostics showed the silent AVQueuePlayer remained active and the completion plan fired, but replacing it with a newly constructed AVQueuePlayer in the background produced final_bell_started without playback progress or AVPlayerItemDidPlayToEndTime. The corrective implementation keeps the already-active AVQueuePlayer, disables its looper, replaces its queue contents with the bell item, and logs a one-second playback progress snapshot. The redundant UIApplication background task was removed because it expires after roughly 30 seconds and generated a runtime warning; background audio remains the session execution mechanism. Added a regression test for same-player queue replacement. Physical locked-screen retest remains required.

2026-07-25 locked-screen retest succeeded on IBmini. The user heard the completion bell at approximately 1:04 by their observation while the phone was set to vibrate. Xcode diagnostics prove the primary background-audio path played: final_bell_progress reported elapsed=0.602359, player_status=readyToPlay, time_control_status=playing, item_status=readyToPlay, and no player/item errors; final_bell_ended followed after the sample duration. The target plan itself was scheduled for target=60 with elapsed=1.789052 and remaining=58.210948, so the coordinator fired at 60 seconds from session start. The observed extra seconds likely reflect UI/interaction timing rather than playback scheduling, but can be measured separately if tighter user-perceived timing is required.
<!-- SECTION:NOTES:END -->
