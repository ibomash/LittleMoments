---
id: TASK-7.3
title: Add idempotent Health dedupe and write status transitions
status: Done
assignee: []
created_date: '2026-02-23 19:40'
updated_date: '2026-02-23 20:10'
labels: []
dependencies:
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
Implement duplicate-safe mindful-session writing so concurrent devices can process the same pending records without creating duplicate Health samples.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each pending entry writes/queries using a stable sync identifier derived from session id.
- [ ] #2 Before save, HealthKit is queried for an existing matching session; fallback time-window check is used when metadata lookup cannot be used.
- [ ] #3 Existing sample or successful save both mark the entry written_to_health with healthWrittenAt set.
- [ ] #4 Failed writes keep the entry pending and record last attempt metadata for future retries.
<!-- AC:END -->
