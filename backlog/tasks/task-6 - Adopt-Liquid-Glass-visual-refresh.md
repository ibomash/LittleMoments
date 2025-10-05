---
id: task-6
title: Adopt Liquid Glass visual refresh
status: Later
assignee: []
created_date: '2025-10-05 03:15'
labels:
  - ui
dependencies: []
---

## Description

Implement Liquid Glass migration per specs/2025-10-05-liquid-glass-migration-prd.md, replacing custom button backgrounds, updating timer controls, and modernizing Settings navigation.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Buttons in TimerStartView and TimerRunningView adopt Liquid Glass button styles without manual Color.blue backgrounds.
- [ ] #2 Timer grids use glassEffect APIs with accessibility fallbacks verified (Reduce Motion, Reduce Transparency).
- [ ] #3 Settings navigation uses NavigationStack + toolbar, no deprecated navigationBarItems.
- [ ] #4 QA checklist from the PRD documented in implementation PR.
<!-- AC:END -->
