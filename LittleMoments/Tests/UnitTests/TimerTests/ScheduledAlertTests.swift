@preconcurrency import XCTest

@testable import LittleMoments

/// Test suite for ScheduledAlert classes
@MainActor
final class ScheduledAlertTests: XCTestCase {

  /// Tests the OneTimeScheduledBellAlert class
  func testOneTimeScheduledBellAlert() {
    // Test initialization and progress calculation
    let alert = OneTimeScheduledBellAlert(targetTimeInMin: 5)
    XCTAssertEqual(alert.targetTimeInSec, 300)
    XCTAssertEqual(alert.name, "5")
    XCTAssertFalse(alert.hasTriggered)
    XCTAssertTrue(alert.hasTarget)

    // Test progress calculation
    XCTAssertEqual(alert.getProgress(secondsElapsed: 150), 0.5)
    XCTAssertEqual(alert.getProgress(secondsElapsed: 300), 1.0)
    XCTAssertEqual(alert.getProgress(secondsElapsed: 350), 1.0)

    // Test trigger behavior
    XCTAssertFalse(alert.hasTriggered)
    alert.checkTrigger(secondsElapsed: 200)
    XCTAssertFalse(alert.hasTriggered)
    alert.checkTrigger(secondsElapsed: 300)
    XCTAssertTrue(alert.hasTriggered)
  }
}
