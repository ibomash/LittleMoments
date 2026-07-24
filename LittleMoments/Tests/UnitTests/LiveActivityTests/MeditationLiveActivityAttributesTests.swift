@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class MeditationLiveActivityAttributesTests: XCTestCase {

  func testPreviewStateValues() {
    let previewState = MeditationLiveActivityAttributes.previewState

    // Test that preview state has expected values
    XCTAssertEqual(previewState.secondsElapsed, 180, "Preview state should show 3 minutes elapsed")
    XCTAssertEqual(
      previewState.targetTimeInSeconds, 600, "Preview state should have 10 minute target")
    XCTAssertEqual(previewState.isCompleted, false, "Preview state should not be completed")
    XCTAssertEqual(previewState.showSeconds, true, "Preview state should show seconds by default")
  }

  func testPreviewStateCompletedValues() {
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted

    // Test that completed preview state has expected values
    XCTAssertEqual(
      previewStateCompleted.secondsElapsed, 600, "Completed preview should show full duration")
    XCTAssertEqual(
      previewStateCompleted.targetTimeInSeconds, 600, "Completed preview should match target time")
    XCTAssertEqual(
      previewStateCompleted.isCompleted, true, "Completed preview should be marked as completed")
    XCTAssertEqual(
      previewStateCompleted.showSeconds, true, "Completed preview should show seconds by default")
  }

  func testPreviewStateProgress() {
    let previewState = MeditationLiveActivityAttributes.previewState

    // Test progress calculation
    if let targetTime = previewState.targetTimeInSeconds {
      let expectedProgress = previewState.secondsElapsed / targetTime
      XCTAssertEqual(expectedProgress, 0.3, accuracy: 0.01, "Preview should show 30% progress")
    } else {
      XCTFail("Preview state should have a target time")
    }
  }

  func testPreviewStateCompletedProgress() {
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted

    // Test completed progress calculation
    if let targetTime = previewStateCompleted.targetTimeInSeconds {
      let expectedProgress = previewStateCompleted.secondsElapsed / targetTime
      XCTAssertEqual(
        expectedProgress, 1.0, accuracy: 0.01, "Completed preview should show 100% progress")
    } else {
      XCTFail("Completed preview state should have a target time")
    }
  }

  func testPreviewAttributesValues() {
    let previewAttributes = MeditationLiveActivityAttributes.preview

    // Test that preview attributes have expected values
    XCTAssertEqual(
      previewAttributes.sessionName, "Morning Meditation",
      "Preview should have descriptive session name")
  }

  func testContentStateInitializer() {
    // Test ContentState initializer with various showSeconds values
    let startDate = Date(timeIntervalSinceReferenceDate: 1_000)
    let stateWithSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 120,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: true,
      startDate: startDate
    )

    XCTAssertEqual(stateWithSeconds.secondsElapsed, 120)
    XCTAssertEqual(stateWithSeconds.targetTimeInSeconds, 300)
    XCTAssertEqual(stateWithSeconds.isCompleted, false)
    XCTAssertEqual(stateWithSeconds.showSeconds, true)
    XCTAssertEqual(stateWithSeconds.startDate, startDate)
    XCTAssertEqual(
      stateWithSeconds.targetEndDate,
      startDate.addingTimeInterval(300)
    )

    let stateWithoutSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 120,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: false
    )

    XCTAssertEqual(stateWithoutSeconds.showSeconds, false)
  }

  func testContentStateDerivesStartDateFromElapsedSnapshot() {
    let beforeCreation = Date()
    let state = MeditationLiveActivityAttributes.ContentState(secondsElapsed: 90)
    let afterCreation = Date()

    XCTAssertGreaterThanOrEqual(
      state.startDate,
      beforeCreation.addingTimeInterval(-90)
    )
    XCTAssertLessThanOrEqual(
      state.startDate,
      afterCreation.addingTimeInterval(-90)
    )
    XCTAssertNil(state.targetEndDate)
  }

  func testContentStateTimingDatesSurviveCodableRoundTrip() throws {
    let startDate = Date(timeIntervalSinceReferenceDate: 10_000)
    let state = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 45,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true,
      startDate: startDate
    )

    let encoded = try JSONEncoder().encode(state)
    let decoded = try JSONDecoder().decode(
      MeditationLiveActivityAttributes.ContentState.self,
      from: encoded
    )

    XCTAssertEqual(decoded, state)
    XCTAssertEqual(decoded.targetEndDate, startDate.addingTimeInterval(600))
  }

  func testContentStateDefaultValues() {
    // Test ContentState with default values
    let stateWithDefaults = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 60
    )

    XCTAssertEqual(stateWithDefaults.secondsElapsed, 60)
    XCTAssertNil(stateWithDefaults.targetTimeInSeconds, "Target time should be nil by default")
    XCTAssertEqual(stateWithDefaults.isCompleted, false, "Should not be completed by default")
    XCTAssertEqual(stateWithDefaults.showSeconds, true, "Should show seconds by default")
  }

  func testTimerDisplayWithPreviewStates() {
    // Test timer display using preview states with showSeconds setting
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted

    // Test with seconds enabled (default)
    let displayWithSeconds = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    XCTAssertEqual(displayWithSeconds, "3:00")

    let completedDisplayWithSeconds = timerDisplayFromSeconds(
      seconds: previewStateCompleted.secondsElapsed,
      showSeconds: previewStateCompleted.showSeconds
    )
    XCTAssertEqual(completedDisplayWithSeconds, "10:00")

    // Test with seconds disabled
    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: false
    )
    XCTAssertEqual(displayWithoutSeconds, "3")

    let completedDisplayWithoutSeconds = timerDisplayFromSeconds(
      seconds: previewStateCompleted.secondsElapsed,
      showSeconds: false
    )
    XCTAssertEqual(completedDisplayWithoutSeconds, "10")
  }
}
