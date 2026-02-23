---
id: TASK-4.1
title: Fix fastlane lint path filtering with current SwiftLint CLI
status: Later
assignee: []
created_date: '2026-02-23 19:44'
labels:
  - process
dependencies: []
parent_task_id: TASK-4
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Make the Fastlane lint lane compatible with current SwiftLint behavior so scoped linting works again. This was discovered while landing TASK-4 when lint path invocations failed but full lint succeeded.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 bin/fastlane lint path:LittleMoments/App/iOS/Little_MomentsApp.swift succeeds.
- [ ] #2 Lane implementation supports single-file and path-scoped linting without invalid --path usage.
- [ ] #3 AGENTS guidance for scoped lint matches actual lane behavior.
<!-- AC:END -->
