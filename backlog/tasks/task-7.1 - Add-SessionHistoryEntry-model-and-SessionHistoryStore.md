---
id: TASK-7.1
title: Add SessionHistoryEntry model and SessionHistoryStore
status: Later
assignee: []
created_date: '2026-02-23 19:39'
labels: []
dependencies: []
documentation:
  - >-
    backlog/docs/doc-23 -
    Spec-Session-History-Sync-and-Asynchronous-Health-Writes.md
parent_task_id: TASK-7
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement SwiftData-backed SessionHistoryEntry persistence with CloudKit private database sync and query/update APIs required by async Health writing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 SessionHistoryEntry includes id, start/end timestamps, duration, source device id, and health write status fields from doc-23.
- [ ] #2 SessionHistoryStore can create entries, fetch pending entries oldest-first, and mark entries written atomically.
- [ ] #3 Store records last write attempt metadata and remains durable across app relaunch.
- [ ] #4 Model container is configured for SwiftData + CloudKit private database sync.
<!-- AC:END -->
