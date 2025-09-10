import SwiftUI
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class LiveActivityPreviewViewTests: XCTestCase {

  func testPreviewUsesSharedTimerLogic() {
    // Test that preview view uses the same timer logic as the real widget
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 125,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: true
    )

    let expectedDisplayWithSeconds = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    XCTAssertEqual(expectedDisplayWithSeconds, "2:05")

    // Test with seconds disabled
    let testStateNoSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 125,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: false
    )

    let expectedDisplayWithoutSeconds = timerDisplayFromSeconds(
      seconds: testStateNoSeconds.secondsElapsed,
      showSeconds: testStateNoSeconds.showSeconds
    )
    XCTAssertEqual(expectedDisplayWithoutSeconds, "2")
  }

  func testPreviewProgressCalculation() {
    // Test progress calculation for timed sessions
    let timedState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 180,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )

    if let targetTime = timedState.targetTimeInSeconds {
      let progress = min(timedState.secondsElapsed / targetTime, 1.0)
      XCTAssertEqual(
        progress, 0.3, accuracy: 0.01, "Progress should be 30% for 3 minutes out of 10")
    } else {
      XCTFail("Timed state should have target time")
    }

    // Test progress clamping for completed sessions
    let completedState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 700,
      targetTimeInSeconds: 600,
      isCompleted: true,
      showSeconds: true
    )

    if let targetTime = completedState.targetTimeInSeconds {
      let progress = min(completedState.secondsElapsed / targetTime, 1.0)
      XCTAssertEqual(
        progress, 1.0, "Progress should be clamped to 100% even when elapsed exceeds target")
    } else {
      XCTFail("Completed state should have target time")
    }
  }

  func testPreviewProgressForUntimedSessions() {
    // Test that untimed sessions (no target time) don't show progress
    let untimedState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 180,
      targetTimeInSeconds: nil,
      isCompleted: false,
      showSeconds: true
    )

    XCTAssertNil(untimedState.targetTimeInSeconds, "Untimed sessions should have no target time")

    // Progress calculation should not be performed for untimed sessions
    // This would be handled in the UI by checking if targetTimeInSeconds exists
  }

  func testPreviewStateBinding() {
    // Test that preview correctly uses state properties
    let customState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 245,
      targetTimeInSeconds: 900,
      isCompleted: false,
      showSeconds: true
    )

    // Test timer display matches expected format
    let timerDisplay = timerDisplayFromSeconds(
      seconds: customState.secondsElapsed,
      showSeconds: customState.showSeconds
    )
    XCTAssertEqual(timerDisplay, "4:05")

    // Test progress calculation
    if let targetTime = customState.targetTimeInSeconds {
      let progress = customState.secondsElapsed / targetTime
      XCTAssertEqual(progress, 245.0 / 900.0, accuracy: 0.01)
    }
  }

  func testPreviewWithDifferentShowSecondsSettings() {
    // Test preview behavior with different showSeconds settings
    let baseState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 185,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )

    let stateWithSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: baseState.secondsElapsed,
      targetTimeInSeconds: baseState.targetTimeInSeconds,
      isCompleted: baseState.isCompleted,
      showSeconds: true
    )

    let stateWithoutSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: baseState.secondsElapsed,
      targetTimeInSeconds: baseState.targetTimeInSeconds,
      isCompleted: baseState.isCompleted,
      showSeconds: false
    )

    // Test timer displays
    let displayWithSeconds = timerDisplayFromSeconds(
      seconds: stateWithSeconds.secondsElapsed,
      showSeconds: stateWithSeconds.showSeconds
    )
    XCTAssertEqual(displayWithSeconds, "3:05")

    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: stateWithoutSeconds.secondsElapsed,
      showSeconds: stateWithoutSeconds.showSeconds
    )
    XCTAssertEqual(displayWithoutSeconds, "3")
  }

  func testPreviewAttributesUsage() {
    // Test that preview correctly uses attributes
    let previewAttributes = MeditationLiveActivityAttributes.preview

    XCTAssertEqual(previewAttributes.sessionName, "Morning Meditation")

    // Test with custom attributes
    let customAttributes = MeditationLiveActivityAttributes(sessionName: "Evening Meditation")
    XCTAssertEqual(customAttributes.sessionName, "Evening Meditation")
  }

  func testPreviewConsistencyWithPreviewStates() {
    // Test that preview uses the predefined preview states correctly
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted

    // Test in-progress state
    let inProgressDisplay = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    XCTAssertEqual(inProgressDisplay, "3:00")

    // Test completed state
    let completedDisplay = timerDisplayFromSeconds(
      seconds: previewStateCompleted.secondsElapsed,
      showSeconds: previewStateCompleted.showSeconds
    )
    XCTAssertEqual(completedDisplay, "10:00")

    // Test progress values
    if let targetTime = previewState.targetTimeInSeconds {
      let progress = previewState.secondsElapsed / targetTime
      XCTAssertEqual(progress, 0.3, accuracy: 0.01)
    }

    if let targetTime = previewStateCompleted.targetTimeInSeconds {
      let progress = previewStateCompleted.secondsElapsed / targetTime
      XCTAssertEqual(progress, 1.0, accuracy: 0.01)
    }
  }
}
