# Build Architecture for Little Moments

This file describes the target state for the build architecture of the Little Moments app.

## Core Components (v1)

- **Swift Package Manager (SPM)** - Dependency management for Swift projects, making it easier to add and update third-party libraries and maintain internal modules.
- **xcodebuild** - Command-line tool for building and testing without using the Xcode IDE directly.
- **Fastlane** - Automation tool for iOS development tasks including building, testing, and releasing app updates.
- **.xcconfig files** - Configuration files that define build settings outside of the project file, enabling better organization and environment-specific settings.
- **XCTest** - Testing framework for unit tests, performance tests, and UI tests.
- **swiftlint** - Code quality tool to enforce Swift style and conventions through additional compiler warnings.
- **swiftformat** - Code formatter to automatically format Swift code according to configured rules (already partially implemented).

## Multi-Platform Support (Future)

- **Shared code architecture** - Structure the codebase to maximize code sharing between iOS and macOS.
- **Platform-specific extensions** - Organize platform-specific code into separate, clearly defined areas.
- **Target conditionals** - Use compiler directives for platform-specific implementations where needed.

## Nice-to-Have Next Steps

- **GitHub Actions** - CI/CD pipeline to automate testing, linting, and potentially app distribution.
- **Tuist** - Tool for generating and maintaining Xcode projects, simplifying project management.
- **swiftgen** - Tool to auto-generate Swift code for resources (like images, sounds, and fonts).
- **XcodeGen** - Another alternative to Tuist that generates Xcode project files from a specification file.

## Suggested Folder Structure

```
LittleMoments/
├── .github/                          # GitHub specific files
│   └── workflows/                    # GitHub Actions workflows
│       ├── ci.yml                    # Continuous integration workflow
│       └── release.yml               # App store release workflow
├── .swiftlint.yml                    # SwiftLint configuration
├── .swiftformat                      # SwiftFormat configuration (already exists in build phase)
├── Package.swift                     # Swift Package Manager manifest
├── fastlane/                         # Fastlane configuration
│   ├── Appfile                       # App identifiers
│   ├── Fastfile                      # Fastlane lanes (build, test, deploy)
│   ├── Pluginfile                    # Fastlane plugins
│   └── Matchfile                     # Certificate and provisioning profile config
├── Config/                           # Build configurations
│   ├── Base.xcconfig                 # Shared build settings
│   ├── Debug.xcconfig                # Debug-specific settings
│   ├── Release.xcconfig              # Release-specific settings
│   ├── iOS.xcconfig                  # iOS-specific settings
│   └── macOS.xcconfig                # macOS-specific settings (for future)
├── LittleMoments/                    # Main app code
│   ├── App/                          # App entry points
│   │   ├── iOS/                      # iOS-specific app code
│   │   │   └── Little_MomentsApp.swift # iOS app entry point
│   │   └── macOS/                    # macOS-specific app code (future)
│   ├── Features/                     # Feature modules
│   │   ├── Timer/                    # Timer feature
│   │   │   ├── Models/               # Timer-related models
│   │   │   │   └── TimerViewModel.swift
│   │   │   └── Views/                # Timer-related views
│   │   │       ├── TimerStartView.swift
│   │   │       └── TimerRunningView.swift
│   │   ├── Settings/                 # Settings feature
│   │   │   └── Views/                # Settings-related views
│   │   │       └── SettingsView.swift
│   │   ├── Meditation/               # Meditation feature
│   │   │   └── Models/               # Meditation-related models
│   │   │       └── MeditationSessionIntent.swift
│   │   └── Shared/                   # Shared UI components
│   │       └── ImageButton.swift
│   ├── Core/                         # Core functionality
│   │   ├── Extensions/               # Swift extensions
│   │   ├── Health/                   # Health integration
│   │   │   └── HealthKitManager.swift
│   │   ├── State/                    # App state management
│   │   │   └── AppState.swift
│   │   ├── Audio/                    # Audio functionality
│   │   │   ├── SoundManager.swift
│   │   │   └── ScheduledBellAlert.swift
│   │   └── Utilities/                # Utility functions
│   └── Resources/                    # App resources
│       ├── Assets.xcassets/          # Image assets
│       ├── Sounds/                   # Sound files
│       │   └── 42095__fauxpress__bell-meditation.aif
│       ├── Localization/             # Localized strings (future)
│       └── Launch.storyboard         # Launch screen
├── Tests/                            # Test files
│   ├── UnitTests/                    # Unit tests
│   │   ├── TimerTests/               # Tests for Timer feature
│   │   │   └── TimerRunningViewTests.swift
│   │   └── CoreTests/                # Tests for core functionality
│   └── UITests/                      # UI tests
├── Little Moments.entitlements       # App entitlements
└── Little-Moments-Info.plist         # Info.plist file
```

## High-Level Implementation Steps

1. **First Phase (Immediate Improvements)**
   - Set up Fastlane with basic lanes for linting, formatting, testing, and building
   - Implement SwiftLint
   - Configure existing SwiftFormat properly
   - Create basic folder structure and relocate existing files
   
   **Testable Outcomes - Phase 1:**
   - Run `fastlane format` and see proper code formatting applied
   - Run `fastlane lint` and see code style warnings and violations reported
   - Run `fastlane test` and verify all tests execute correctly
   - Run `fastlane build` to successfully build the app from command line
   - Verify that files have been organized according to the new folder structure
   - Confirm the app still runs correctly with the reorganized files

2. **Second Phase (Quality Improvements)**
   - Set up .xcconfig files for different build configurations
   - Implement basic GitHub Actions for continuous integration
   - Update project.pbxproj to reflect new structure
   - Add Fastlane lanes for code signing and beta distribution
   
   **Testable Outcomes - Phase 2:**
   - Switch between debug and release configurations using .xcconfig files
   - See GitHub Actions automatically run tests and linting on each push
   - Build the app using different configurations via command line
   - Successfully sign and distribute a test build using `fastlane beta`
   - Verify that the project.pbxproj correctly references all files in the new structure
   - Confirm build settings are properly inherited from .xcconfig files

3. **Third Phase (Advanced Tools)**
   - Implement Swift Package Manager
   - Enhance Fastlane setup with additional lanes for releases and metadata management
   - Prepare architecture for macOS support
   
   **Testable Outcomes - Phase 3:**
   - Add and manage dependencies using Swift Package Manager
   - Successfully update app metadata and screenshots using Fastlane
   - Create a full release build with `fastlane release`
   - Verify that shared code works correctly on both iOS and macOS targets
   - Confirm platform-specific code is properly isolated and conditionally compiled
   - Successfully build and run preliminary macOS version of the app

## Detailed Implementation Plan

### Phase 1: Initial Setup and Formatting

#### 1. Install and Configure Tools

- [ ] Install Fastlane
  ```bash
  brew install fastlane
  # Verify with: fastlane --version
  ```

- [ ] Initialize Fastlane in the project directory
  ```bash
  cd /path/to/LittleMoments
  fastlane init
  # Verify by checking for Fastfile and Appfile in fastlane/
  ```

- [ ] Install SwiftLint
  ```bash
  brew install swiftlint
  # Verify with: swiftlint --version
  ```

- [ ] Ensure swift-format is installed and working
  ```bash
  # Check if already installed
  swift-format --version
  # If not installed:
  brew install swift-format
  ```

#### 2. Configure Code Quality Tools

- [ ] Create basic SwiftLint configuration file at root
  ```bash
  touch .swiftlint.yml
  # Add basic rules
  ```
  Test: `swiftlint lint` should run with your custom rules

- [ ] Configure swift-format with a configuration file
  ```bash
  touch .swift-format.json
  # Add preferred formatting rules
  ```
  Test: `swift-format format -i -r . --configuration .swift-format.json` should format according to rules

- [ ] Ensure both tools are ignoring appropriate files (like dependencies)
  ```bash
  # Add exclusion paths to .swiftlint.yml and .swift-format.json
  ```
  Test: Formatting/linting shouldn't affect excluded files

#### 3. Create Initial Fastlane Setup

- [ ] Create basic lanes in the Fastfile for essential tasks
  ```ruby
  # Add lane for linting
  # Add lane for formatting
  # Add lane for testing
  # Add lane for building
  ```
  Test: Each lane should be runnable individually with `fastlane [lane_name]`

- [ ] Create a combined quality_check lane that runs format, lint, and test
  ```ruby
  # Add quality_check lane that calls the other lanes
  ```
  Test: `fastlane quality_check` should run all checks in sequence

- [ ] Ensure Fastlane is properly configured with your app's bundle ID in the Appfile
  ```ruby
  # Update app_identifier in Appfile
  ```

#### 4. Plan and Implement Folder Structure

- [ ] Map current files to target locations in the new structure
  ```
  # Create a mapping document of:
  # Current location -> New location
  ```

- [ ] Create the base folder structure according to the architecture plan
  ```bash
  # Create main directories
  mkdir -p LittleMoments/{App/{iOS,macOS},Features/{Timer/{Models,Views},Settings/Views,Meditation/Models,Shared},Core/{Extensions,Health,State,Audio,Utilities},Resources/{Sounds,Localization}}
  ```
  Test: Directory structure should match the plan

- [ ] Relocate files to their new locations, starting with non-critical files
  ```bash
  # Move supporting files first (resources, etc.)
  ```
  Test: App should still build and run

- [ ] Move core feature files to their new locations
  ```bash
  # Move feature files second
  ```
  Test: App should still build and run

- [ ] Move app entry point files to their new locations
  ```bash
  # Move app entry files last
  ```
  Test: App should still build and run

#### 5. Update Project References

- [ ] Update Xcode project file references
  ```bash
  # Either manually via Xcode or with a tool to update file references
  ```
  Test: All files should be properly referenced in Xcode with no red missing file indicators

- [ ] Fix any import statements that need to be updated
  ```
  # Check and update import statements if folder structure required changes
  ```
  Test: Code should compile without import errors

#### 6. Verify Complete Phase 1 Implementation

- [ ] Run `fastlane format` and verify formatting is applied
  Test: Code should be consistently formatted according to rules

- [ ] Run `fastlane lint` and review code quality warnings
  Test: Code issues should be identified according to your rules

- [ ] Run `fastlane test` to ensure all tests still pass
  Test: All tests should pass in the new structure

- [ ] Run `fastlane build` to verify the app builds successfully
  Test: App should build without errors

- [ ] Run the app to verify it functions correctly
  Test: All app features should work as before

- [ ] Document any issues encountered and lessons learned
  ```markdown
  # Create a document with issues and resolutions
  ```

### Phase 2: Build Configuration and GitHub Actions

### Phase 3: Swift Package Manager and macOS Support


## Fastlane Example

```ruby
# Fastfile example
default_platform(:ios)

platform :ios do
  desc "Run SwiftLint"
  lane :lint do
    swiftlint(
      mode: :lint,
      quiet: true,
      strict: true
    )
  end

  desc "Format Swift code"
  lane :format do
    sh "swift-format format -i -r ."
  end

  desc "Run tests"
  lane :test do
    scan(
      scheme: "Little Moments",
      device: "iPhone 15",
      clean: true
    )
  end

  desc "Build the app"
  lane :build do
    gym(
      scheme: "Little Moments",
      clean: true,
      skip_archive: true,
      skip_codesigning: true
    )
  end

  desc "Run all quality checks and tests"
  lane :quality_check do
    format
    lint
    test
  end

  desc "Build for TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "Little Moments")
    upload_to_testflight
  end
end
```

This structure provides a clean separation of concerns, making the codebase more maintainable, testable, and ready for expansion to macOS in the future. The organization follows modern Swift development practices while supporting comprehensive automation through Fastlane for all development and deployment tasks.