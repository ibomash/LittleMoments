import SwiftUI
import XCTest

/// @testable import allows access to internal members of the app module
@testable import Little_Moments

/// Test suite for TimerRunningView and its associated TimerViewModel
/// These tests verify both the view model logic and basic view creation
final class TimerRunningViewTests: XCTestCase {
  /// The view model instance used across all tests
  var timerViewModel: TimerViewModel!

  /// Set up method runs before each test
  /// Creates a fresh TimerViewModel instance to ensure tests start with a clean state
  override func setUp() {
    super.setUp()
    timerViewModel = TimerViewModel()
  }

  /// Tear down method runs after each test
  /// Ensures proper cleanup of timer and resources
  override func tearDown() {
    timerViewModel.reset()
    timerViewModel = nil
    super.tearDown()
  }

  /// Tests the initial state of the TimerViewModel
  /// Verifies that all properties are properly initialized to their default values
  func testTimerViewModelInitialState() {
    XCTAssertEqual(timerViewModel.timeElapsedFormatted, "0:00")
    XCTAssertFalse(timerViewModel.hasEndTarget)
    XCTAssertFalse(timerViewModel.isDone)
    XCTAssertEqual(timerViewModel.progress, 0.0)
  }

  /// Tests the scheduled alert functionality
  /// Verifies that setting an alert works correctly and the timer values are appropriate
  /// for both simulator and device environments
  func testTimerViewModelScheduledAlert() {
    // Select the first timer option
    let firstAlert = timerViewModel.scheduledAlertOptions[0]
    timerViewModel.scheduledAlert = firstAlert

    XCTAssertNotNil(timerViewModel.scheduledAlert)
    XCTAssertTrue(timerViewModel.hasEndTarget)

    #if targetEnvironment(simulator)
      // In simulator, first alert should be 5 seconds
      // This shorter duration makes testing faster in the simulator
      XCTAssertEqual(timerViewModel.scheduledAlert?.targetTimeInSec, 5)
    #else
      // On device, first alert should be 3 minutes (180 seconds)
      // This is the actual production value used in the app
      XCTAssertEqual(timerViewModel.scheduledAlert?.targetTimeInSec, 180)
    #endif
  }

  /// Tests that the timer properly tracks progress
  /// Uses an async expectation to verify timer behavior over time
  func testTimerProgress() {
    let fiveMinAlert = timerViewModel.scheduledAlertOptions[1]  // 5-minute timer
    timerViewModel.scheduledAlert = fiveMinAlert

    timerViewModel.start()

    // Wait for 1 second to ensure timer has started
    let expectation = XCTestExpectation(description: "Timer running")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // Verify that time has elapsed and progress is being tracked
      XCTAssertTrue(self.timerViewModel.secondsElapsed > 0)
      XCTAssertTrue(self.timerViewModel.progress > 0)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 2)
  }

  /// Tests the timer reset functionality
  /// Verifies that resetting the timer properly clears all state
  func testTimerReset() {
    timerViewModel.start()

    // Wait briefly then reset
    let expectation = XCTestExpectation(description: "Timer reset")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.timerViewModel.reset()
      // Verify that all values are reset to their initial state
      XCTAssertEqual(self.timerViewModel.timeElapsedFormatted, "0:00")
      XCTAssertEqual(self.timerViewModel.progress, 0.0)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
  }

  /// Tests basic view creation and initialization
  /// Verifies that the view is created with proper default values
  func testTimerRunningViewCreation() {
    let view = TimerRunningView()
    XCTAssertNotNil(view.timerViewModel)
    XCTAssertEqual(view.buttonsPerRow, 4)
  }
}
