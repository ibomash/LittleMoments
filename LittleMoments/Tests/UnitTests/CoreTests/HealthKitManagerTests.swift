import HealthKit
@preconcurrency import XCTest

@testable import LittleMoments

/// Test suite for HealthKitManager
@MainActor
final class HealthKitManagerTests: XCTestCase {

  /// Tests creation of a mindful session
  func testMindfulSessionCreation() {
    let startDate = Date()
    let endDate = startDate.addingTimeInterval(600)  // 10 minutes later

    // Create session
    let session = HealthKitManager.shared.createMindfulSession(
      startDate: startDate, endDate: endDate)

    // Verify session exists
    XCTAssertNotNil(session, "Mindful session should not be nil")

    // Safely unwrap the optional
    guard let unwrappedSession = session else {
      XCTFail("Failed to create mindful session")
      return
    }

    // Verify session properties
    XCTAssertEqual(unwrappedSession.startDate, startDate)
    XCTAssertEqual(unwrappedSession.endDate, endDate)
    XCTAssertEqual(unwrappedSession.value, 0)
  }

  /// Tests HealthKit authorization request with mock
  func testHealthKitAuthorization() {
    let mockManager = MockHealthKitManager()

    // Create expectation for async call
    let expectation = XCTestExpectation(description: "HealthKit Authorization")

    mockManager.requestAuthorization { success, error in
      XCTAssertTrue(success)
      XCTAssertNil(error)
      XCTAssertTrue(mockManager.requestAuthorizationWasCalled)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }
}
