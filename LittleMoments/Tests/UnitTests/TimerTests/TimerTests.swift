import SwiftUI
@preconcurrency import XCTest

/// @testable import allows access to internal members of the app module
@testable import LittleMoments

/// Test suite for TimerRunningView and its associated TimerViewModel
/// These tests verify both the view model logic and basic view creation
@MainActor
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
  @MainActor override func setUp() async throws {
    try await super.setUp()
    UserDefaultsReset.resetDefaults()
    try? SessionHistoryStore.shared.purgeAllEntries()
    timerViewModel = TimerViewModel()
  }

  /// Tear down method runs after each test
  /// Ensures proper cleanup of timer and resources
  @MainActor override func tearDown() async throws {
    try? SessionHistoryStore.shared.purgeAllEntries()
    timerViewModel?.reset()
    timerViewModel = nil
    try await super.tearDown()
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
    XCTAssertEqual(
      TimerViewModel.formatElapsedTime(secondsElapsed: 1, showSeconds: true),
      "0:01"
    )
    XCTAssertEqual(
      TimerViewModel.formatElapsedTime(secondsElapsed: 1, showSeconds: false),
      "0"
    )
    XCTAssertEqual(
      TimerViewModel.formatElapsedTime(secondsElapsed: 61, showSeconds: true),
      "1:01"
    )
    XCTAssertEqual(
      TimerViewModel.formatElapsedTime(secondsElapsed: 61, showSeconds: false),
      "1"
    )
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
      // On device, first alert should be 5 minutes (300 seconds)
      // This is the first production preset now that the 1-minute preset is removed
      XCTAssertEqual(timerViewModel?.scheduledAlert?.targetTimeInSec, 300)
    #endif
  }

  /// Tests that the timer properly tracks progress
  /// Suspends briefly so the main actor remains available while time advances.
  func testTimerProgress() async throws {
    let fiveMinAlert = timerViewModel?.scheduledAlertOptions[0]  // 5-minute timer
    timerViewModel?.scheduledAlert = fiveMinAlert

    timerViewModel?.start()
    try await Task.sleep(for: .milliseconds(10))

    XCTAssertTrue(timerViewModel?.secondsElapsed ?? 0 > 0)
    XCTAssertTrue(timerViewModel?.progress ?? 0 > 0)
  }

  /// Tests the timer reset functionality
  /// Verifies that resetting the timer properly clears all state
  func testTimerReset() {
    // Ensure showSeconds is true for consistent formatting
    setShowSeconds(true)

    timerViewModel?.start()
    timerViewModel?.reset()

    XCTAssertEqual(timerViewModel?.timeElapsedFormatted, "0:00")
    XCTAssertEqual(timerViewModel?.progress, 0.0)
  }

  /// Tests basic view creation and initialization
  /// Verifies that the view is created with proper default values
  func testTimerRunningViewCreation() {
    let view = TimerRunningView()
    XCTAssertNotNil(view.timerViewModel)
    XCTAssertEqual(view.buttonsPerRow, 4)
  }

  /// Tests that the legacy Health-writing entry point queues the completed session.
  func testWriteToHealthStoreQueuesCompletedSession() throws {
    guard let timerViewModel else {
      XCTFail("TimerViewModel should be initialized")
      return
    }

    timerViewModel.start()
    timerViewModel.writeToHealthStore()

    let entries = try SessionHistoryStore.shared.fetchAllEntriesNewestFirst()
    XCTAssertEqual(entries.count, 1)
    let entry = try XCTUnwrap(entries.first)
    XCTAssertTrue(
      entry.healthWriteStatus == .pendingHealthWrite
        || entry.healthWriteStatus == .writtenToHealth
    )
  }

  func testRecordCompletedSessionAddsHistoryEntry() throws {
    guard let timerViewModel else {
      XCTFail("TimerViewModel should be initialized")
      return
    }

    let initialCount = try SessionHistoryStore.shared.fetchAllEntriesNewestFirst().count

    timerViewModel.start()
    timerViewModel.prepareSessionForFinish()
    timerViewModel.recordCompletedSession()

    let entries = try SessionHistoryStore.shared.fetchAllEntriesNewestFirst()
    XCTAssertEqual(entries.count, initialCount + 1)

    let latestEntry = try XCTUnwrap(entries.first)
    XCTAssertTrue(
      latestEntry.healthWriteStatus == .pendingHealthWrite
        || latestEntry.healthWriteStatus == .writtenToHealth
    )
  }
}
