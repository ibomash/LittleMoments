---
id: TASK-11
title: Add native macOS app
status: Done
assignee: []
created_date: '2026-08-11 21:29'
updated_date: '2026-08-12 02:27'
labels:
  - ui
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a native SwiftUI macOS version of Little Moments with one main window, a minimal shared session boundary, native desktop controls, guarded quit behavior during active sessions, and local Mac build/test support.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 All existing iOS unit tests continue to pass.
- [x] #2 The native macOS target builds and launches locally without Catalyst.
- [x] #3 The Mac app supports untimed, preset, and custom-duration sessions with complete and cancel actions.
- [x] #4 Closing or quitting during a running session offers keep open, complete and quit, and cancel and quit choices.
- [x] #5 The idle-to-running transition is lightweight and respects Reduce Motion.
- [x] #6 Mac-specific unit tests cover shared session behavior and quit decisions.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Establish a green iOS baseline.
- Extract only the session state needed by both platforms, preserving current iOS behavior.
- Add separate native macOS app and test targets in the existing Tuist project.
- Build the Mac idle/running/settings UI and lightweight session transition.
- Guard main-window close and application quit while a session is active.
- Add Fastlane and project-local Mac build/run support.
- Run format, lint, iOS tests, macOS tests/build, and inspect a launched Mac app.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented a minimal shared MeditationSessionController and kept iOS-only integrations in TimerViewModel. Added separate native macOS app and test targets, desktop-specific SwiftUI views and settings, a narrow AppKit window/termination bridge, local-only Mac session history, Mac app icons, and Fastlane build/test/run support. Manually verified preset selection, session start and completion, settings, guarded close with Keep Open, and idle-window quit in the launched app.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Native Little Moments for macOS is implemented in the existing project. Full iOS quality_check passed (130 unit tests and 11 UI tests), Mac tests passed (4 tests), and the signed app was launched and exercised locally.
<!-- SECTION:FINAL_SUMMARY:END -->
