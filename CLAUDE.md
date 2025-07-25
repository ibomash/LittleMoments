# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Little Moments is a mindfulness iOS app built with SwiftUI that helps users take brief meditation breaks throughout the day. The app focuses on "small glimpses, many times" - supporting sessions from 30 seconds to several minutes with optional bells and Live Activity integration.

## Development Commands

This project uses Tuist for project generation and Fastlane for build automation. **Always use Fastlane lanes rather than direct commands** - never call `tuist` or `bundle exec` directly.

### Essential Commands
- `fastlane generate` - Generate Xcode project with Tuist (required before building)
- `fastlane build` - Build the app using Tuist
- `fastlane test` - Run all tests (unit + UI tests)
- `fastlane test_unit` - Run unit tests only
- `fastlane test_ui` - Run UI tests only
- `fastlane lint` - Run SwiftLint (with strict mode)
- `fastlane format_code` - Format Swift code using swift-format
- `fastlane quality_check` - Run format, lint, test, and build in sequence

### Testing Setup
- Tests run on iPhone 16 simulator by default
- Unit tests: `LittleMomentsTests` target
- UI tests: `LittleMomentsUITests` target
- Test coverage is enabled for the main app target

## Architecture

### Core Structure
- **App State**: Singleton `AppState` manages global UI state (timer running, settings view visibility)
- **Timer System**: `TimerViewModel` handles meditation session timing, background tasks, and HealthKit integration
- **Live Activities**: `LiveActivityManager` manages Lock Screen/Dynamic Island integration for active sessions
- **Settings**: `JustNowSettings` manages user preferences (HealthKit, Live Activities, display options)
- **Sound**: `SoundManager` handles meditation bell sounds and audio session management
- **Health Integration**: `HealthKitManager` writes mindful sessions to Apple Health

### Key Components
- **TimerViewModel**: Central controller for meditation sessions with background task management, notification handling, and Live Activity coordination
- **LiveActivityManager**: Singleton managing Live Activity lifecycle with proper state synchronization
- **AppState**: Simple singleton for global UI state management
- **Deep Link Handling**: URL scheme `littlemoments://` supports `finishSession` and `cancelSession` actions

### Project Structure
- `LittleMoments/App/iOS/` - Main app entry point
- `LittleMoments/Core/` - Core functionality (state, audio, health)
- `LittleMoments/Features/` - Feature modules (timer, settings, live activity, shared components)
- `LittleMoments/Resources/` - Assets, sounds, storyboards
- `LittleMoments/Tests/` - Unit and UI tests
- `LittleMoments/WidgetExtension/` - Live Activity widget extension

### Build Configuration
- Uses Tuist for project generation with Swift Package Manager integration
- Two main targets: `LittleMoments` (main app) and `LittleMomentsWidgetExtension` (Live Activity)
- Supports iOS only (no macOS/iPad catalyst)
- Development Team: Z5NU48NAF9

## Key Implementation Details

### Live Activity Integration
- Live Activities display meditation progress on Lock Screen and Dynamic Island
- `LiveActivityManager` handles the full lifecycle with proper error handling
- Deep link integration allows finishing/canceling sessions from Live Activity buttons
- Race condition protection prevents accidental HealthKit writes on cancellation

### Timer System
- Background task support for continued timing when app is backgrounded
- Notification-based communication between main app and Live Activity
- Sophisticated cancellation handling to prevent accidental HealthKit writes
- Support for both timed and untimed sessions

### Testing Strategy
- Unit tests for core business logic (timer, health integration, settings)
- UI tests for Live Activity functionality
- Mock utilities for testing dependencies
- Test-specific configurations (5-second timer option in simulator)
- **Always plan tests for any changes and typically write those tests first (TDD approach)**

## Development Notes

### Health Integration
- Sessions are written to HealthKit as mindful minutes
- Cancellation protection prevents accidental writes when sessions are cancelled
- Health integration can be disabled in settings

### Live Activity Considerations
- Live Activities must be enabled in settings and supported by device
- Widget extension is a separate target with its own bundle ID
- Proper entitlements configuration required for Live Activities

### Background Tasks
- Timer continues running in background via background task API
- Notifications can trigger session completion even when app is backgrounded
- Proper cleanup of background tasks on session end

## Commit Message Standards

Follow conventional commit format: `type(scope): description`

### Common Types
- `feat`: New features or significant functionality additions
- `fix`: Bug fixes and corrections
- `docs`: Documentation changes only
- `chore`: Maintenance tasks, renaming, etc.
- `config`: Configuration changes

### Format Rules
- Start with lowercase type (feat, fix, etc.)
- Optional scope in parentheses
- Use colon and space after type/scope
- Write description in imperative mood
- Keep first line under 72 characters
- No period at the end of the first line
- Don't add references to Claude Code in commit messages

### Examples
- `feat: Add meditation session intent`
- `fix: Don't play the timer after session is done`
- `docs: Update README with current status`
- `chore: Cleaning up project structure`
- `config: Set up my developer account for the build`

## PRD Standards

Product Requirement Documents must be placed in `specs/` directory with naming convention `YYYY-MM-DD-feature-name.md`. Use the template in `specs/TEMPLATE-feature-name.md`. Always run `date +%Y-%m-%d` to get current date before creating PRDs.