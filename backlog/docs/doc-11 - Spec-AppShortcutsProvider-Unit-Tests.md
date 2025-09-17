---
id: doc-11
title: "Spec: AppShortcutsProvider Unit Tests"
type: "tech-debt"
created_date: "2025-09-17 01:14"
source_path: "todo/tech-debt/app-shortcuts-provider-unit-tests.md"
---
# Spec: AppShortcutsProvider Unit Tests

## Objective
Guarantee the Siri/App Shortcuts configuration remains discoverable and accurate by covering `LittleMomentsShortcuts.appShortcuts` with deterministic tests.

## Current Gaps
- No tests confirm the provider emits a single `AppShortcut` wired to `MeditationSessionIntent`.
- Synonym phrases could regress (e.g., typos, missing `\(.applicationName)` token) without any automated failure.
- Shortcut metadata such as `shortTitle` and `systemImageName` is unprotected.
- Future additions to the shortcut array could break expectations without surfacing in review.

## Proposed Test Coverage
- Ensure `appShortcuts` returns exactly one shortcut by default.
- Validate the shortcut’s intent is `MeditationSessionIntent` and that creating the intent does not crash under test.
- Assert the `phrases` collection matches the expected four strings, including the embedded `\(.applicationName)` placeholder for App Shortcuts discoverability.
- Verify `shortTitle` equals “Start Meditation” and `systemImageName` is `play.circle.fill`.
- (Optional) Validate `AppShortcutsMetadata` remains stable by snapshotting to a lightweight codable struct if API churn makes direct comparisons fragile.

## Implementation Plan
1. **Expose Test Surface**
   - Because `AppShortcutsProvider` is a pure static array, tests can instantiate `LittleMomentsShortcuts.appShortcuts` directly; ensure the production module is compiled for tests via `@testable import`.

2. **Write Deterministic Assertions**
   - Add a `LittleMomentsShortcutsTests` XCTestCase validating array count, intent type, phrases, and metadata.
   - Use `XCTAssertEqual` for arrays to guarantee order (mirroring App Shortcuts presentation).

3. **Guard Future Changes**
   - Add a regression test that fails if additional shortcuts are appended without test updates, prompting reviewers to consider coverage for new intents.

## Dependencies & Tooling
- `XCTest`
- AppIntents framework (already linked for the target)

## Acceptance Criteria
- Tests fail if any of the shortcut phrases, metadata, or intent assignments change unexpectedly.
- Running the test suite does not hit live Siri/App Shortcuts APIs.
- Future shortcut additions require explicit test updates, ensuring coverage evolves with new intents.
