# Feature: Shortcuts Integration

## Overview

### Problem Statement
Users want to integrate meditation moments into their daily routines and automation workflows, but without deep system integration, starting a meditation requires manual app launching.

### Intended Impact
By integrating with Apple Shortcuts, Just Now allows users to incorporate meditation sessions into their broader productivity and wellness workflows, making meditation a more seamless part of daily routines.

### Background Context
Apple Shortcuts allows users to automate tasks across apps and create custom workflows. For meditation practice, this enables scenarios like starting a brief meditation after completing focused work, before an important meeting, or as part of a morning routine.

## Goals and Success Metrics

### Primary Goal
Allow users to start meditation sessions directly from Shortcuts, Siri, or automation routines without manually opening the app.

### Success Metrics
- 30%+ of users create at least one Shortcut using the app's actions
- Increase in sessions initiated through Shortcuts vs direct app launches
- Positive user feedback about the Shortcuts integration

### Non-goals
- Complex conditional Shortcut actions
- Shortcuts for managing app settings
- Deep statistics or data export via Shortcuts

## Requirements

### Functional Requirements
- Provide a single Shortcut action to start a meditation session
- Include an optional Duration (minutes) parameter
- Support invocation via Siri commands (App Shortcuts phrases + natural language)
- Support automation triggers (time, location, etc.) through the Shortcuts app
- Donate relevant Shortcuts to the system for quick access
- Add search synonyms so the action appears for queries like “meditate”, “mindfulness”, “breathing”
- Sessions started via Shortcuts should be recorded to Health (if enabled)

### Non-functional Requirements
- Quick response time when invoked via Shortcuts
- Consistent behavior whether launched directly or via Shortcuts
- Adherence to Apple Shortcuts API best practices

### Constraints
- Limited by iOS Shortcuts framework capabilities
- iOS 16+ (App Intents)
- Avoid duplicate actions: widget/control intents are hidden from Shortcuts (isDiscoverable = false)

## User Experience

### User Flows

#### Creating a Basic Shortcut
1. User opens Shortcuts app
2. User creates a new Shortcut
3. User searches for "Just Now" actions
4. User adds "Start Meditation Session" action, optionally sets Duration
5. User saves Shortcut with a name

#### Using a Shortcut
1. User triggers Shortcut (via Shortcuts app, Home Screen, or Siri)
2. App launches in timer running mode
3. Meditation session begins immediately

#### Setting Up Automation
1. User creates a Shortcut with the meditation action
2. User creates an Automation in the Shortcuts app
3. User sets a trigger (time of day, arrival at location, etc.)
4. User selects the meditation Shortcut as the action
5. When trigger occurs, meditation session starts automatically

### Key Screens/Interactions
- Shortcuts app integration screen showing available actions
- Voice interaction with Siri
- Direct transition to timer running screen when Shortcut is executed

### Edge Cases
- If device is locked, authentication may be required before session starts
- If multiple Shortcuts run in sequence, ensure meditation session isn't interrupted
- Handle scenarios where Shortcuts are triggered but user isn't in a position to meditate

## Implementation Considerations

### Current Implementation
- AppIntent: `MeditationSessionIntent` with optional `durationMinutes: Int?`.
- Parameter summary for clarity in Shortcuts:
  - Untimed: “Start an untimed meditation”.
  - Timed: “Start a meditation for X minutes”.
- Discoverability and synonyms:
  - `IntentDescription` provides `searchKeywords`: meditate, meditation, mindfulness, breathe, breathing, timer, untimed, bells, focus.
  - `LittleMomentsShortcuts` (`AppShortcutsProvider`) supplies synonym phrases: “Start meditation in (AppName)”, “Begin meditation…”, “Meditate…”, “Start an untimed meditation…”.
- Foregrounding: `openAppWhenRun = true` to show the running timer immediately.
- Dupes prevention: Control/Widget intents use `isDiscoverable = false` to keep only one user‑facing action in Shortcuts.

### Dependencies
- App Intents framework
- Siri/Spotlight discovery through App Shortcuts
- Background app launch capabilities

### Phasing
1. Single action with optional duration (done)
2. Add curated presets as App Shortcuts (e.g., 1m, 3m, 5m) [optional]
3. Consider parameterized phrases for duration (e.g., “Start a 5‑minute meditation”) [optional]
4. Potential future: additional parameters (e.g., silent start, bells at start)

### Open Questions
- Do we want curated preset shortcuts (1m/3m/5m) for quicker setup?
- Should we add a "silent mode" parameter for situations where audio isn't appropriate?
- Any additional synonyms to include for non‑English locales?
