---
id: TASK-8
title: Evaluate lower-overhead robust bell playback
status: Later
assignee: []
created_date: '2026-07-24 20:50'
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
<!-- SECTION:NOTES:END -->
