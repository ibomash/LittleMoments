#!/bin/bash

# Create the base directory structure
mkdir -p LittleMoments/App/iOS
mkdir -p LittleMoments/Features/Timer/Models
mkdir -p LittleMoments/Features/Timer/Views
mkdir -p LittleMoments/Features/Settings/Views
mkdir -p LittleMoments/Features/Settings/Models
mkdir -p LittleMoments/Features/Meditation/Models
mkdir -p LittleMoments/Features/Shared
mkdir -p LittleMoments/Core/State
mkdir -p LittleMoments/Core/Health
mkdir -p LittleMoments/Core/Audio
mkdir -p Tests/UnitTests/CoreTests
mkdir -p Tests/UnitTests/TimerTests
mkdir -p Tests/UITests

# Copy files to new locations (using cp for safety, can change to mv after verification)
# App Entry Point
cp "./Little Moments/Little_MomentsApp.swift" "LittleMoments/App/iOS/Little_MomentsApp.swift"

# Timer Feature
cp "./Little Moments/TimerViewModel.swift" "LittleMoments/Features/Timer/Models/TimerViewModel.swift"
cp "./Little Moments/TimerStartView.swift" "LittleMoments/Features/Timer/Views/TimerStartView.swift"
cp "./Little Moments/TimerRunningView.swift" "LittleMoments/Features/Timer/Views/TimerRunningView.swift"

# Settings Feature
cp "./Little Moments/SettingsView.swift" "LittleMoments/Features/Settings/Views/SettingsView.swift"
# Note: JustNowSettings class needs to be extracted from SettingsView.swift to a new file
echo "# JustNowSettings model extracted from SettingsView.swift" > "LittleMoments/Features/Settings/Models/JustNowSettings.swift"
echo "# Don't forget to manually extract JustNowSettings class from SettingsView.swift" >> "LittleMoments/Features/Settings/Models/JustNowSettings.swift"

# Meditation Feature
cp "./Little Moments/MeditationSessionIntent.swift" "LittleMoments/Features/Meditation/Models/MeditationSessionIntent.swift"

# Shared UI Components
cp "./Little Moments/ImageButton.swift" "LittleMoments/Features/Shared/ImageButton.swift"

# Core Functionality
cp "./Little Moments/AppState.swift" "LittleMoments/Core/State/AppState.swift"
cp "./Little Moments/HealthKitManager.swift" "LittleMoments/Core/Health/HealthKitManager.swift"
cp "./Little Moments/SoundManager.swift" "LittleMoments/Core/Audio/SoundManager.swift"
cp "./Little Moments/ScheduledBellAlert.swift" "LittleMoments/Core/Audio/ScheduledBellAlert.swift"

# Tests
cp "./Little MomentsTests/Little_MomentsTests.swift" "Tests/UnitTests/CoreTests/Little_MomentsTests.swift"
cp "./Little MomentsTests/TimerRunningViewTests.swift" "Tests/UnitTests/TimerTests/TimerRunningViewTests.swift"
cp "./Little MomentsUITests/Little_MomentsUITests.swift" "Tests/UITests/Little_MomentsUITests.swift"
cp "./Little MomentsUITests/Little_MomentsUITestsLaunchTests.swift" "Tests/UITests/Little_MomentsUITestsLaunchTests.swift"

echo "Migration completed. Please verify the new structure before removing original files." 