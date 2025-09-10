//
//  Little_MomentsTests.swift
//  Little MomentsTests
//
//  Created by Illya Bomash on 5/1/23.
//

@preconcurrency import XCTest

@testable import LittleMoments

/// Test suite for core app functionality
@MainActor
final class AppTests: XCTestCase {

  @MainActor override func setUp() async throws {
    try await super.setUp()
    // Reset UserDefaults between tests
    UserDefaultsReset.resetDefaults()
    // Reset AppState to initial values
    AppState.shared.resetState()
  }

  /// Tests that AppState is a proper singleton
  func testAppStateSharedInstance() {
    let state1 = AppState.shared
    let state2 = AppState.shared

    // Should be the same instance
    XCTAssertTrue(state1 === state2)

    // Test default values
    XCTAssertFalse(state1.showTimerRunningView)
    XCTAssertFalse(state1.showSettingsView)
  }

  /// Tests that AppState properly publishes changes
  func testAppStatePublishing() {
    let state = AppState.shared

    // Create expectation for publisher
    let expectation = XCTestExpectation(description: "State change published")

    // Subscribe to changes
    let cancellable = state.$showTimerRunningView.sink { newValue in
      if newValue == true {
        expectation.fulfill()
      }
    }

    // Change state
    state.showTimerRunningView = true

    // Wait for expectation
    wait(for: [expectation], timeout: 1.0)
    cancellable.cancel()
  }
}
