@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class LiveActivityManagerTests: XCTestCase {
  func testActivityInitialization() {
    // This test will check if the LiveActivityManager initializes correctly
    // Since we can't fully test ActivityKit in unit tests, we'll just ensure the class exists
    let manager = LiveActivityManager.shared
    XCTAssertNotNil(manager)
  }

  func testActivityUpdateWithNilActivity() async {
    // This test will check that updateActivity doesn't crash when activity is nil
    let manager = LiveActivityManager.shared

    // This shouldn't throw any errors even if activity is nil
    await manager.updateActivity(secondsElapsed: 10)
  }

  func testActivityEndWithNilActivity() async {
    // This test will check that endActivity doesn't crash when activity is nil
    let manager = LiveActivityManager.shared

    // This shouldn't throw any errors even if activity is nil
    await manager.endActivity()
  }
}
