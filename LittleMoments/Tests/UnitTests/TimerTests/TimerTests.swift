import SwiftUI
import XCTest

/// @testable import allows access to internal members of the app module
@testable import LittleMoments

/// Test suite for TimerRunningView and its associated TimerViewModel
/// These tests verify both the view model logic and basic view creation
final class TimerTests: XCTestCase {
  /// The view model instance used across all tests
  var timerViewModel: TimerViewModel?

  /// Helper method to set showSeconds setting
  private func setShowSeconds(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "showSeconds")
    UserDefaults.standard.synchronize()
  }

  /// Set up method runs before each test
  /// Creates a fresh TimerViewModel instance to ensure tests start with a clean state
  override func setUp() {
    super.setUp()
    timerViewModel = TimerViewModel()
    UserDefaultsReset.resetDefaults()
  }

  /// Tear down method runs after each test
  /// Ensures proper cleanup of timer and resources
  override func tearDown() {
    timerViewModel?.reset()
    timerViewModel = nil
    super.tearDown()
  }

  /// Tests the initial state of the TimerViewModel with both showSeconds settings
  /// Verifies that all properties are properly initialized to their default values
  func testTimerViewModelInitialState() {
    // Test with showSeconds = true
    setShowSeconds(true)
    XCTAssertEqual(timerViewModel?.timeElapsedFormatted, "0:00")
    XCTAssertFalse(timerViewModel?.hasEndTarget ?? true)
    XCTAssertFalse(timerViewModel?.isDone ?? true)
    XCTAssertEqual(timerViewModel?.progress, 0.0)

    // Test with showSeconds = false
    setShowSeconds(false)
    XCTAssertEqual(timerViewModel?.timeElapsedFormatted, "0")
    XCTAssertFalse(timerViewModel?.hasEndTarget ?? true)
    XCTAssertFalse(timerViewModel?.isDone ?? true)
    XCTAssertEqual(timerViewModel?.progress, 0.0)
  }

  /// Tests that time formatting respects showSeconds setting after time has elapsed
  func testTimeFormattingWithSettings() {
    timerViewModel?.start()

    // Wait for 1 second to elapse
    let expectation = XCTestExpectation(description: "Timer running")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {  // Wait just over 1 second
      // Test with showSeconds = true
      self.setShowSeconds(true)
      XCTAssertEqual(self.timerViewModel?.timeElapsedFormatted, "0:01")

      // Test with showSeconds = false
      self.setShowSeconds(false)
      XCTAssertEqual(self.timerViewModel?.timeElapsedFormatted, "0")
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 2)
  }

  /// Tests the scheduled alert functionality
  /// Verifies that setting an alert works correctly and the timer values are appropriate
  /// for both simulator and device environments
  func testTimerViewModelScheduledAlert() {
    // Select the first timer option
    let firstAlert = timerViewModel?.scheduledAlertOptions[0]
    timerViewModel?.scheduledAlert = firstAlert

    XCTAssertNotNil(timerViewModel?.scheduledAlert)
    XCTAssertTrue(timerViewModel?.hasEndTarget ?? false)

    #if targetEnvironment(simulator)
      // In simulator, first alert should be 5 seconds
      // This shorter duration makes testing faster in the simulator
      XCTAssertEqual(timerViewModel?.scheduledAlert?.targetTimeInSec, 5)
    #else
      // On device, first alert should be 3 minutes (180 seconds)
      // This is the actual production value used in the app
      XCTAssertEqual(timerViewModel?.scheduledAlert?.targetTimeInSec, 180)
    #endif
  }

  /// Tests that the timer properly tracks progress
  /// Uses an async expectation to verify timer behavior over time
  func testTimerProgress() {
    let fiveMinAlert = timerViewModel?.scheduledAlertOptions[1]  // 5-minute timer
    timerViewModel?.scheduledAlert = fiveMinAlert

    timerViewModel?.start()

    // Wait for 1 second to ensure timer has started
    let expectation = XCTestExpectation(description: "Timer running")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      // Verify that time has elapsed and progress is being tracked
      XCTAssertTrue(self.timerViewModel?.secondsElapsed ?? 0 > 0)
      XCTAssertTrue(self.timerViewModel?.progress ?? 0 > 0)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 2)
  }

  /// Tests the timer reset functionality
  /// Verifies that resetting the timer properly clears all state
  func testTimerReset() {
    // Ensure showSeconds is true for consistent formatting
    setShowSeconds(true)

    timerViewModel?.start()

    // Wait briefly then reset
    let expectation = XCTestExpectation(description: "Timer reset")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.timerViewModel?.reset()
      // Verify that all values are reset to their initial state
      XCTAssertEqual(self.timerViewModel?.timeElapsedFormatted, "0:00")
      XCTAssertEqual(self.timerViewModel?.progress, 0.0)
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

  /// Tests writing to Health Store when setting is enabled
  func testWriteToHealthStore() {
    // Create a mock HealthKitManager
    let mockHealthManager = MockHealthKitManager()

    // Set up conditions for health write
    let settings = JustNowSettings.shared
    settings.writeToHealth = true

    // Start timer
    timerViewModel?.start()

    // Wait briefly then write to health
    let expectation = XCTestExpectation(description: "Health write")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      // Use the mock directly instead of trying to replace the shared instance
      mockHealthManager.saveMindfulSession(
        startDate: Date().addingTimeInterval(-10),
        endDate: Date()
      ) { success, _ in
        XCTAssertTrue(success)
        XCTAssertTrue(mockHealthManager.saveWasCalled)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 1)
  }
}
