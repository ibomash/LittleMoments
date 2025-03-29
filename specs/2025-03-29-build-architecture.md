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
- **Main Project Structure**: Tuist-generated project with:
  - `/Project.swift` - Main Tuist project definition with:
    - Marketing version (0.2.0)
    - Build version (51)
    - Targets for app, unit tests, and UI tests
    - Schemes configuration
  - `/LittleMoments/Core/**` - Core functionality
  - `/LittleMoments/Features/**` - Feature modules
  - `/LittleMoments/App/iOS/**` - iOS-specific app code
  - `/LittleMoments/Resources/**` - App resources
  - `/LittleMoments/Tests/UnitTests/**` - Unit test files
  - `/LittleMoments/Tests/UITests/**` - UI test files
  - `Little-Moments-Info.plist` - App Info.plist file
  - `Little Moments.entitlements` - App entitlements

The directory structure now matches the target structure outlined in the architecture plan.

#### Build Tools
- **Fastlane**: Successfully set up with the following lanes:
  - `lint`: Runs SwiftLint with appropriate configuration
  - `format_code`: Formats Swift code using swift-format
  - `generate`: Generates Xcode project using Tuist
  - `test_unit`: Runs unit tests on iPhone 16 simulator
  - `test_ui`: Runs UI tests on iPhone 16 simulator
  - `test`: Runs all tests (unit and UI)
  - `build`: Builds the app using Tuist
  - `quality_check`: Runs format_code, lint, test, and build lanes in sequence

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

### Suggested Folder Structure

```
LittleMoments/
├── Project.swift                     # Defines the Tuist project
├── .github/                          # GitHub specific files
│   └── workflows/                    # GitHub Actions workflows
│       ├── ci.yml                    # Continuous integration workflow
│       └── release.yml               # App store release workflow
├── .swiftlint.yml                    # SwiftLint configuration
├── .swift-format.json                # SwiftFormat configuration
├── Package.swift                     # Swift Package Manager manifest
├── fastlane/                         # Fastlane configuration
│   ├── Appfile                       # App identifiers
│   ├── Fastfile                      # Fastlane lanes (build, test, deploy)
│   ├── README.md                     # Fastlane documentation
│   └── Pluginfile                    # Fastlane plugins
├── Config/                           # Build configurations
│   ├── Base.xcconfig                 # Shared build settings
│   ├── Debug.xcconfig                # Debug-specific settings
│   └── Release.xcconfig              # Release-specific settings
├── LittleMoments/                    # Main app code
│   ├── App/                          # App entry points
│   │   ├── iOS/                      # iOS-specific app code
│   │   │   └── Little_MomentsApp.swift # iOS app entry point
│   │   └── macOS/                    # macOS-specific app code (future)
│   ├── Features/                     # Feature modules
│   │   ├── Timer/                    # Timer feature
│   │   │   ├── Models/               # Timer-related models
│   │   │   └── Views/                # Timer-related views
│   │   ├── Settings/                 # Settings feature
│   │   │   └── Views/                # Settings-related views
│   │   ├── Meditation/               # Meditation feature
│   │   │   └── Models/               # Meditation-related models
│   │   └── Shared/                   # Shared UI components
│   ├── Core/                         # Core functionality
│   │   ├── Extensions/               # Swift extensions
│   │   ├── Health/                   # Health integration
│   │   ├── State/                    # App state management
│   │   ├── Audio/                    # Audio functionality
│   │   └── Utilities/                # Utility functions
│   ├── Resources/                    # App resources
│   │   ├── Assets.xcassets/          # Image assets
│   │   ├── Sounds/                   # Sound files
│   │   └── Localization/             # Localized strings (future)
│   └── Tests/                        # Test files
│       ├── UnitTests/                # Unit tests
│       └── UITests/                  # UI tests
├── Little Moments.entitlements       # App entitlements
└── Little-Moments-Info.plist         # Info.plist file
```

### Implemented Solutions

#### Fastlane Implementation
The project has implemented Fastlane with the following lanes:

```ruby
# Fastfile
default_platform(:ios)

platform :ios do
  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      quiet: true,
      strict: true,
      ignore_exit_status: true
    )
  end

  desc "Format Swift code"
  lane :format_code do
    sh "cd .. && swift-format -i -r . --configuration .swift-format.json"
  end

  desc "Generate Xcode project with Tuist"
  lane :generate do
    sh "cd .. && tuist generate"
  end

  desc "Run unit tests"
  lane :test_unit do
    sh "cd .. && xcodebuild test -project LittleMoments.xcodeproj -scheme \"LittleMoments\" -configuration Debug -sdk iphonesimulator -destination \"platform=iOS Simulator,name=iPhone 16\" -only-testing:LittleMomentsTests"
  end

  desc "Run UI tests"
  lane :test_ui do
    sh "cd .. && xcodebuild test -project LittleMoments.xcodeproj -scheme \"LittleMoments\" -configuration Debug -sdk iphonesimulator -destination \"platform=iOS Simulator,name=iPhone 16\" -only-testing:LittleMomentsUITests"
  end

  desc "Run all tests"
  lane :test do
    test_unit
    test_ui
  end

  desc "Build app with Tuist"
  lane :build do
    sh "cd .. && tuist build"
  end

  desc "Format, lint, test, and build"
  lane :quality_check do
    format_code
    lint
    test
    build
  end
end
```

#### Tuist Project Implementation
The project uses Tuist for project generation and management with the following configuration:

```swift
// Project.swift
import ProjectDescription

let marketingVersion = "0.2.0"
let buildVersion = "51"

let baseSettings: [String: SettingValue] = [
  "MARKETING_VERSION": .string(marketingVersion),
  "CURRENT_PROJECT_VERSION": .string(buildVersion)
]

let project = Project(
  name: "LittleMoments",
  targets: [
    .target(
      name: "LittleMoments",
      destinations: .iOS,
      product: .app,
      bundleId: "net.bomash.illya.LittleMoments",
      infoPlist: .file(path: "Little-Moments-Info.plist"),
      sources: ["LittleMoments/Core/**", "LittleMoments/Features/**", "LittleMoments/App/iOS/**"],
      resources: ["LittleMoments/Resources/**"],
      entitlements: .file(path: "Little Moments.entitlements"),
      dependencies: [],
      settings: .settings(
        base: baseSettings
      )
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.LittleMomentsTests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UnitTests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ]
    ),
    .target(
      name: "LittleMomentsUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "net.bomash.illya.LittleMomentsUITests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UITests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ]
    )
  ],
  schemes: [
    .scheme(
      name: "LittleMoments",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMoments"]),
      testAction: .targets(
        ["LittleMomentsTests", "LittleMomentsUITests"],
        configuration: .debug,
        options: .options(coverage: true, codeCoverageTargets: ["LittleMoments"])
      ),
      runAction: .runAction(configuration: .debug),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    )
  ]
)
```

## Open Questions
- What additional CI/CD workflows would be most beneficial to implement with GitHub Actions?
- Should we consider integrating additional code quality tools beyond SwiftLint and swift-format?
- What timeline should we target for adding macOS support to the project?