---
id: TASK-7.6
title: Add tests and validation for session history + async Health writes
status: Now
assignee: []
created_date: '2026-02-23 19:40'
updated_date: '2026-02-23 19:46'
labels: []
dependencies:
  - TASK-7.3
  - TASK-7.4
  - TASK-7.5
documentation:
  - >-
    backlog/docs/doc-23 -
    Spec-Session-History-Sync-and-Asynchronous-Health-Writes.md
parent_task_id: TASK-7
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add unit, integration, and UI coverage plus manual device validation for the new session history sync and asynchronous Health write behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Unit tests cover history creation, pending query ordering, eligibility gating, dedupe handling, and write-status transitions.
- [ ] #2 Integration tests cover completion-to-pending-to-written flow, app relaunch processing, and mixed batch outcomes.
- [ ] #3 UI tests verify Settings -> Session History navigation and status rendering.
- [ ] #4 Manual two-device validation confirms an ineligible device can sync pending sessions that are later written by an eligible device.
<!-- AC:END -->
