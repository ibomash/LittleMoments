---
id: TASK-7
title: Implement session history sync and async Health writes
status: Done
assignee: []
created_date: '2026-02-23 19:39'
updated_date: '2026-03-01 00:11'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Deliver the feature in doc-23 by introducing history-first session persistence, cross-device sync, asynchronous Health writes, and a read-only Settings history view.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Completed sessions are persisted first and never block on Health write completion.
- [ ] #2 Pending sessions can be written by an eligible device and converge to written status across devices.
- [ ] #3 Settings includes a read-only Session History screen showing sync state.
- [ ] #4 Required tests and validation pass before merge.
<!-- AC:END -->
