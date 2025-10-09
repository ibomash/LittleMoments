---
id: doc-5
title: "Build Architecture for Little Moments"
type: "spec"
created_date: "2025-03-29 00:00"
source_path: "2025-03-29-build-architecture.md"
---
# Build Architecture for Little Moments

## Overview
- **Problem Statement**: The Little Moments app lacked a consistent, maintainable build architecture, making it difficult to collaborate, test, and deploy efficiently.
- **Intended Impact**: Creating a standardized build architecture improves development efficiency, code quality, and enables future expansion to multiple platforms.
- **Background Context**: The project started with a basic Xcode project structure but required modernization to support growing feature requirements and multiple developers.

## Goals and Success Metrics
- **Primary Goal**: Establish a robust, maintainable build architecture for the Little Moments app that supports efficient development workflows.
- **Success Metrics**:
  - Automated building, testing, and linting processes through command-line tools
  - Clear separation of concerns with a modular code organization
  - Consistent code formatting and style across the codebase
  - Ability to run quality checks with a single command
- **Non-goals**:
  - Complete rewrite of the application code
  - Migration to a different programming language or framework

## Requirements
### Functional Requirements
- Support for automated building and testing via command line
- Code quality enforcement through linting and formatting tools
- Project generation through Tuist for consistent project structure
- Clear organization of code into feature modules and core components

### Non-functional Requirements
- Performance: Build and test processes should complete within a reasonable timeframe
- Maintainability: Architecture should be easy to understand and modify
- Scalability: Architecture should support future expansion to macOS

### Constraints
- Must maintain compatibility with existing code and features
- Must use standard iOS development tools and patterns

## Implementation Considerations
### Current State

The Little Moments app build architecture has been successfully updated to implement the target architecture. The project has been restructured using Tuist for project generation and organized with a clear folder structure.

#### Project Structure
- `Project.swift` – Tuist project definition that manages targets, schemes, and the current marketing/build versions.
- `LittleMoments/Core/` – Shared business logic, app state, utilities, and integrations.
- `LittleMoments/Features/` – Feature-oriented modules for the timer, settings, live activities, and shared UI components.
- `LittleMoments/App/iOS/` – Platform-specific entry point and scene configuration.
- `LittleMoments/Resources/` – Assets, sounds, and bundled configuration files.
- `LittleMoments/Tests/UnitTests/` and `LittleMoments/Tests/UITests/` – Unit and UI test suites.
- `Little-Moments-Info.plist` and `Little Moments.entitlements` – Application configuration and entitlements.

Tuist keeps the generated Xcode project aligned with this structure; regenerate via `fastlane generate` after structural changes.

#### Build Tools
- **Fastlane**: Successfully set up with the following lanes:
  - `lint`: Runs SwiftLint with appropriate configuration
  - `format_code`: Formats Swift code using swift-format
  - `generate`: Generates Xcode project using Tuist
  - `test_unit`: Runs unit tests on iPhone 17 simulator
  - `test_ui`: Runs UI tests on iPhone 17 simulator
  - `test`: Runs all tests (unit and UI)
  - `build`: Builds the app using Tuist
  - `quality_check`: Runs format_code, lint, test, and build lanes in sequence
  - `repomix`: Generates a repository overview using Repomix for documentation and planning support

All shell-based lanes that invoke Tuist or xcodebuild unset the `CPATH` environment variable before running commands to avoid inherited module map conflicts in non-interactive environments.

- **SwiftLint**: Configured and working
- **swift-format**: Configured and working with a JSON configuration file
- **Tuist**: Configured for project generation and building
- **xcodebuild**: Used in Fastlane lanes for building and testing

#### Completed Items
- ✅ Project structured with Tuist
- ✅ Fastlane setup with comprehensive lanes
- ✅ SwiftLint configuration
- ✅ swift-format configuration
- ✅ Directory restructuring to match target architecture
- ✅ Project files organized according to feature modules
- ✅ Test directories properly set up for unit and UI tests

#### Dependencies
- Tuist for project generation
- Fastlane for automation
- SwiftLint and swift-format for code quality

#### Phasing
The implementation has been completed in a single phase, focusing on establishing the core architecture components:
1. Project structure and organization
2. Build automation
3. Code quality tools

#### Next Steps
1. **Continuous Integration**: Implement GitHub Actions for CI/CD
2. **Swift Package Manager**: Further adopt SPM for dependency management
3. **Multi-Platform Support**: Begin preparing the architecture for macOS support

### Target State

#### Core Components (v1)
- **Swift Package Manager (SPM)** - Dependency management for Swift projects, making it easier to add and update third-party libraries and maintain internal modules.
- **xcodebuild** - Command-line tool for building and testing without using the Xcode IDE directly.
- **Fastlane** - Automation tool for iOS development tasks including building, testing, and releasing app updates.
- **.xcconfig files** - Configuration files that define build settings outside of the project file, enabling better organization and environment-specific settings.
- **XCTest** - Testing framework for unit tests, performance tests, and UI tests.
- **swiftlint** - Code quality tool to enforce Swift style and conventions through additional compiler warnings.
- **swiftformat** - Code formatter to automatically format Swift code according to configured rules.
- **Tuist** - Tool for generating and maintaining Xcode projects, simplifying project management.

#### Multi-Platform Support (Future)
- **Shared code architecture** - Structure the codebase to maximize code sharing between iOS and macOS.
- **Platform-specific extensions** - Organize platform-specific code into separate, clearly defined areas.
- **Target conditionals** - Use compiler directives for platform-specific implementations where needed.

#### Nice-to-Have Next Steps
- **GitHub Actions** - CI/CD pipeline to automate testing, linting, and potentially app distribution.
- **swiftgen** - Tool to auto-generate Swift code for resources (like images, sounds, and fonts).
- **XcodeGen** - Another alternative to Tuist that generates Xcode project files from a specification file.

### Implemented Solutions

#### Fastlane Implementation
The automation catalog lives in `fastlane/Fastfile`. Key iOS lanes include:
- `lint` – Runs SwiftLint in strict mode with the repository configuration.
- `format_code` – Formats source files via `swift-format`.
- `generate` – Calls Tuist to regenerate the Xcode project.
- `test_unit` – Executes unit tests for the `LittleMoments` scheme on the iPhone 17 simulator.
- `test_ui` – Executes UI tests with the `LittleMoments-UI` scheme on the iPhone 17 simulator.
- `test` – Aggregates the unit and UI test lanes.
- `build` – Performs a Tuist build and falls back to `xcodebuild` for a generic iOS device if Tuist fails.
- `quality_check` – Runs formatting, linting, tests, and build sequentially.
- `repomix` – Generates a repository overview to support planning and documentation.

Every lane that invokes Tuist or `xcodebuild` unsets the `CPATH` environment variable before execution to prevent inherited module map conflicts in non-interactive environments. Refer to `fastlane/Fastfile` for the authoritative lane definitions and options.

#### Tuist Project Implementation
`Project.swift` defines the Tuist configuration for Little Moments. It sets the marketing/build versions (0.2.0/51), declares the primary app target along with `LittleMomentsTests` and `LittleMomentsUITests`, enables code coverage in the shared scheme, and wires resources plus entitlements into the build. Update this file when introducing new modules or targets so the generated Xcode project remains consistent.

## Open Questions
- What additional CI/CD workflows would be most beneficial to implement with GitHub Actions?
- Should we consider integrating additional code quality tools beyond SwiftLint and swift-format?
- What timeline should we target for adding macOS support to the project?
