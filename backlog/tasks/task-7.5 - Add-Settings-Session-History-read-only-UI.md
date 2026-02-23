---
id: TASK-7.5
title: Add Settings -> Session History read-only UI
status: Done
assignee: []
created_date: '2026-02-23 19:40'
updated_date: '2026-02-23 20:10'
labels:
  - ui
dependencies:
  - TASK-7.1
documentation:
  - >-
    backlog/docs/doc-23 -
    Spec-Session-History-Sync-and-Asynchronous-Health-Writes.md
parent_task_id: TASK-7
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a Session History entry under Settings and a read-only list screen that surfaces synced session records and Health write status.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Settings view includes a Session History navigation entry.
- [ ] #2 Session History list shows newest-first entries with completion time, duration, and Pending/Written status.
- [ ] #3 The screen is read-only in this phase with no edit, delete, or manual retry controls.
- [ ] #4 UI handles empty state gracefully when there are no sessions.
<!-- AC:END -->
