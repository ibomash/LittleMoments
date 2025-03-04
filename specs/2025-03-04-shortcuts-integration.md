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
- Provide a Shortcut action to start a meditation session immediately
- Support invocation via Siri commands
- Support automation triggers (time, location, etc.) through the Shortcuts app
- Donate relevant Shortcuts to the system for quick access
- Sessions started via Shortcuts should be recorded to Health (if enabled)

### Non-functional Requirements
- Quick response time when invoked via Shortcuts
- Consistent behavior whether launched directly or via Shortcuts
- Adherence to Apple Shortcuts API best practices

### Constraints
- Limited by iOS Shortcuts framework capabilities
- Must work across iOS versions that support App Intents
- Limited customization options for the initial implementation

## User Experience

### User Flows

#### Creating a Basic Shortcut
1. User opens Shortcuts app
2. User creates a new Shortcut
3. User searches for "Just Now" actions
4. User adds "Start Meditation Session" action
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

### Dependencies
- App Intents framework
- Siri integration
- Background app launch capabilities

### Phasing
1. Basic "Start Meditation Session" action (current implementation)
2. Enhanced action with duration parameter
3. Action for immediate session with preset bell interval
4. Potential future: custom Siri phrases for meditation start

### Open Questions
- Should we add a Shortcut action to specify session duration?
- Would users benefit from a Shortcut action to configure if the bell should ring at start?
- Should we add a "silent mode" parameter for situations where audio isn't appropriate?
- How can we enhance Siri integration with natural language understanding? 