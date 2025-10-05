---
id: task-6
title: Adopt Liquid Glass visual refresh
status: Later
assignee: []
created_date: '2025-10-05 03:15'
updated_date: '2025-10-05 16:57'
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

## Implementation Plan

1. Update the deployment target to iOS 26+, removing pre-Liquid Glass fallbacks to align with the new baseline.
2. Add shared GlassButtonStyle utilities and refreshed color/typography tokens, then migrate TimerStartView to the new styling.
3. Refactor TimerRunningView to wrap controls in GlassEffectContainer, replace manual backgrounds with semantic tints, and present the view via fullScreenCover.
4. Migrate SettingsView to NavigationStack with toolbar APIs, adopt grouped Form styling, and configure the sheet with presentationDetents([.large]).
5. Apply Liquid Glass materials to the widget extension and validate legibility across appearances and accessibility toggles.
6. Run fastlane format/lint/tests plus the PRD QA checklist, recording accessibility and performance observations for the implementation PR.
