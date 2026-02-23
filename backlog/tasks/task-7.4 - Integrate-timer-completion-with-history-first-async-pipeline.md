---
id: TASK-7.4
title: Integrate timer completion with history-first async pipeline
status: Later
assignee: []
created_date: '2026-02-23 19:40'
labels: []
dependencies:
  - TASK-7.1
  - TASK-7.2
documentation:
  - >-
    backlog/docs/doc-23 -
    Spec-Session-History-Sync-and-Asynchronous-Health-Writes.md
parent_task_id: TASK-7
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update timer completion flows so completed sessions are recorded to history first and Health writing is delegated to the async coordinator.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Manual complete, Live Activity finish, and deep-link finish paths create a pending session history entry and return immediately.
- [ ] #2 Cancel paths continue to produce no history entry and no Health write.
- [ ] #3 Direct completion-time Health write coupling is removed from TimerViewModel completion flow.
- [ ] #4 A fire-and-forget coordinator trigger runs after successful history record creation.
<!-- AC:END -->
