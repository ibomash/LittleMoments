---
id: TASK-7.2
title: Build HealthWriteCoordinator and eligibility gating
status: Later
assignee: []
created_date: '2026-02-23 19:39'
labels: []
dependencies:
  - TASK-7.1
documentation:
  - >-
    backlog/docs/doc-23 -
    Spec-Session-History-Sync-and-Asynchronous-Health-Writes.md
parent_task_id: TASK-7
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create an asynchronous coordinator that processes pending session history records only when the device is eligible to write mindful sessions to Health.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eligibility requires Health data availability, write-to-Health setting enabled, and mindful-session sharing authorization granted.
- [ ] #2 Coordinator is triggered on app launch/foreground, after local session completion, and after relevant sync updates.
- [ ] #3 Transient failures remain pending with retry scheduling, while permission/availability failures pause writes on that device.
- [ ] #4 Processing runs off the main session completion path and does not block UI.
<!-- AC:END -->
