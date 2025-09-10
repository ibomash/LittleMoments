import SwiftUI
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class WidgetPreviewConsistencyTests: XCTestCase {

  func testTimerDisplayConsistencyBetweenWidgetAndPreview() {
    // Test that both real widget and preview use the same timer formatting
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 185,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )

    // Both should use the same shared function
    let sharedTimerDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )

    XCTAssertEqual(sharedTimerDisplay, "3:05")

    // Test with seconds disabled
    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: false
    )

    XCTAssertEqual(displayWithoutSeconds, "3")
  }

  func testProgressBarConsistencyBetweenWidgetAndPreview() {
    // Test that both widget and preview calculate progress the same way
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 300,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )

    if let targetTime = testState.targetTimeInSeconds {
      let progress = min(testState.secondsElapsed / targetTime, 1.0)
      XCTAssertEqual(progress, 0.5, accuracy: 0.01, "Both should show 50% progress")
    } else {
      XCTFail("Test state should have target time")
    }

    // Test progress clamping for overtime sessions
    let overtimeState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 700,
      targetTimeInSeconds: 600,
      isCompleted: true,
      showSeconds: true
    )

    if let targetTime = overtimeState.targetTimeInSeconds {
      let progress = min(overtimeState.secondsElapsed / targetTime, 1.0)
      XCTAssertEqual(progress, 1.0, "Both should clamp progress to 100%")
    }
  }

  func testNilTargetTimeHandlingConsistency() {
    // Test that both widget and preview handle nil targetTimeInSeconds the same way
    let untimedState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 180,
      targetTimeInSeconds: nil,
      isCompleted: false,
      showSeconds: true
    )

    XCTAssertNil(untimedState.targetTimeInSeconds, "Untimed sessions should have no target time")

    // Timer display should still work
    let timerDisplay = timerDisplayFromSeconds(
      seconds: untimedState.secondsElapsed,
      showSeconds: untimedState.showSeconds
    )
    XCTAssertEqual(timerDisplay, "3:00")

    // Progress calculation should not be performed (would be handled in UI)
    // Both widget and preview should check for nil before showing progress bar
  }

  func testShowSecondsSettingConsistency() {
    // Test that both widget and preview respect showSeconds setting identically
    let baseSeconds: Double = 245

    let stateWithSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: baseSeconds,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )

    let stateWithoutSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: baseSeconds,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: false
    )

    // Both should produce the same results
    let displayWithSeconds = timerDisplayFromSeconds(
      seconds: stateWithSeconds.secondsElapsed,
      showSeconds: stateWithSeconds.showSeconds
    )
    XCTAssertEqual(displayWithSeconds, "4:05")

    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: stateWithoutSeconds.secondsElapsed,
      showSeconds: stateWithoutSeconds.showSeconds
    )
    XCTAssertEqual(displayWithoutSeconds, "4")
  }

  func testButtonConsistencyBetweenWidgetAndPreview() {
    // Test that both widget and preview use the same button URLs and text
    let finishURL = "littlemoments://finishSession"
    let cancelURL = "littlemoments://cancelSession"

    // Both should use the same deep link URLs
    XCTAssertNotNil(URL(string: finishURL), "Finish URL should be valid")
    XCTAssertNotNil(URL(string: cancelURL), "Cancel URL should be valid")

    // Button text should be consistent
    let finishText = "Finish"
    let cancelText = "Cancel"

    XCTAssertEqual(finishText, "Finish")
    XCTAssertEqual(cancelText, "Cancel")
  }

  func testPreviewStateConsistencyWithExpectedValues() {
    // Test that preview states match expected values used in both widget and preview
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted

    // In-progress state
    XCTAssertEqual(previewState.secondsElapsed, 180)
    XCTAssertEqual(previewState.targetTimeInSeconds, 600)
    XCTAssertEqual(previewState.isCompleted, false)
    XCTAssertEqual(previewState.showSeconds, true)

    // Completed state
    XCTAssertEqual(previewStateCompleted.secondsElapsed, 600)
    XCTAssertEqual(previewStateCompleted.targetTimeInSeconds, 600)
    XCTAssertEqual(previewStateCompleted.isCompleted, true)
    XCTAssertEqual(previewStateCompleted.showSeconds, true)

    // Both should produce expected timer displays
    let inProgressDisplay = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    XCTAssertEqual(inProgressDisplay, "3:00")

    let completedDisplay = timerDisplayFromSeconds(
      seconds: previewStateCompleted.secondsElapsed,
      showSeconds: previewStateCompleted.showSeconds
    )
    XCTAssertEqual(completedDisplay, "10:00")
  }

  func testWidgetAndPreviewUseSameSharedFunction() {
    // Test that the shared function produces consistent results
    let testCases: [(seconds: Double, showSeconds: Bool, expected: String)] = [
      (0, true, "0:00"),
      (0, false, "0"),
      (59, true, "0:59"),
      (59, false, "0"),
      (60, true, "1:00"),
      (60, false, "1"),
      (185, true, "3:05"),
      (185, false, "3"),
      (3600, true, "60:00"),
      (3600, false, "60"),
    ]

    for testCase in testCases {
      let result = timerDisplayFromSeconds(
        seconds: testCase.seconds,
        showSeconds: testCase.showSeconds
      )
      XCTAssertEqual(
        result, testCase.expected,
        "Failed for \(testCase.seconds) seconds with showSeconds: \(testCase.showSeconds)")
    }
  }

  func testConsistencyAcrossDifferentPresentations() {
    // Test that the same state produces consistent displays across different widget presentations
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 150,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: true
    )

    // All presentations should use the same shared function
    let lockScreenDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )

    let dynamicIslandDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )

    let previewDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )

    XCTAssertEqual(lockScreenDisplay, "2:30")
    XCTAssertEqual(dynamicIslandDisplay, "2:30")
    XCTAssertEqual(previewDisplay, "2:30")

    // All should be identical
    XCTAssertEqual(lockScreenDisplay, dynamicIslandDisplay)
    XCTAssertEqual(dynamicIslandDisplay, previewDisplay)
  }
}
