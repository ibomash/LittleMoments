# Feature: Apple Health Integration

## Overview

### Problem Statement
Meditation practitioners who use Just Now need a way to track their mindfulness practice alongside other health metrics in Apple Health, but manually logging these sessions would add friction to the experience.

### Intended Impact
Automatic recording of meditation sessions to Apple Health allows users to maintain a complete health record without additional effort, encouraging consistent practice and providing a historical record of their mindfulness sessions.

### Background Context
Apple Health serves as a centralized repository for health data on iOS devices. By integrating with HealthKit, Just Now can contribute mindfulness data that works with the broader Apple Health ecosystem, allowing users to see trends and correlations with other health metrics like sleep, exercise, and heart rate.

## Goals and Success Metrics

### Primary Goal
Seamlessly record all meditation sessions to Apple Health (when enabled) without requiring user interaction for each session.

### Success Metrics
- 80%+ of users enable Health integration
- Consistent recording of meditation sessions to Apple Health
- Positive user feedback about the integration's reliability

### Non-goals
- Detailed analytics of meditation patterns in-app (Apple Health already provides this)
- Reading other health data from Apple Health
- Creating custom categories beyond Apple's "Mindful Minutes"

## Requirements

### Functional Requirements
- Record the start time, end time, and duration of meditation sessions to Apple Health
- Allow users to enable/disable Health integration via settings
- Request HealthKit permissions when the feature is first enabled
- Support writing to the "Mindful Session" category in HealthKit
- Record sessions only when they are completed (not canceled)

### Non-functional Requirements
- Privacy-focused approach that respects user data
- Reliable recording even for very short sessions
- Minimal battery impact

### Constraints
- Limited to Apple's predefined "Mindful Minutes" category
- Only available on iOS devices (not available on iPad/Mac)
- Requires user permission to access HealthKit

## User Experience

### User Flows

#### Enabling Health Integration
1. User navigates to settings
2. User toggles "Write sessions to Health"
3. System permission dialog appears
4. User grants permission
5. Feature is enabled

#### Session Recording
1. User completes a meditation session
2. Session is automatically recorded to Apple Health
3. No user interaction required for the recording process

### Key Screens/Interactions
- Settings toggle for "Write sessions to Health"
- System permission dialog (standard iOS dialog)
- No direct UI for the actual recording process (happens automatically)

### Edge Cases
- If user denies HealthKit permissions, the toggle remains on but sessions aren't recorded
- If HealthKit is unavailable on the device, the toggle is disabled
- If writing to HealthKit fails, the app logs the error but doesn't notify the user

## Implementation Considerations

### Dependencies
- HealthKit framework
- User permission for HealthKit access

### Phasing
1. Basic HealthKit integration for recording sessions (current implementation)
2. Potential future enhancements:
   - More detailed categorization if Apple expands HealthKit categories
   - Reading historical session data from HealthKit to show in-app statistics

### Open Questions
- Should failed health recording attempts be retried?
- Would users benefit from viewing their meditation history within the app (pulled from HealthKit)?
- Should the app request read access to see if sessions were already recorded for the same timeframe? 