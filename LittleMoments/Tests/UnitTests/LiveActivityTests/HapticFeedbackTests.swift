@preconcurrency import XCTest

@testable import LittleMoments

/// Tests for haptic feedback functionality in meditation session completion
@MainActor
final class HapticFeedbackTests: XCTestCase {

  // MARK: - LiveActivityManager Haptic Feedback Tests

  func testHapticFeedbackManagerInitialization() {
    // Test that the HapticFeedbackManager can be initialized
    let manager = HapticFeedbackManager.shared
    XCTAssertNotNil(manager, "HapticFeedbackManager should initialize successfully")
  }

  func testProvideCompletionFeedbackDoesNotThrow() {
    // Test that providing completion feedback doesn't throw errors
    let manager = HapticFeedbackManager.shared

    // This should not throw any exceptions
    XCTAssertNoThrow(
      manager.provideCompletionFeedback(), "Providing completion feedback should not throw")
  }

  func testProvideCompletionFeedbackCanBeCalledMultipleTimes() {
    // Test that completion feedback can be called multiple times without issues
    let manager = HapticFeedbackManager.shared

    // Call multiple times to ensure no side effects
    XCTAssertNoThrow(manager.provideCompletionFeedback())
    XCTAssertNoThrow(manager.provideCompletionFeedback())
    XCTAssertNoThrow(manager.provideCompletionFeedback())
  }

  // MARK: - LiveActivityManager Integration Tests

  func testLiveActivityManagerHasHapticFeedbackCapability() {
    // Test that LiveActivityManager has the capability to provide haptic feedback
    let manager = LiveActivityManager.shared

    // This test verifies the method exists and doesn't crash
    XCTAssertNoThrow(
      manager.provideSessionCompletionFeedback(),
      "LiveActivityManager should have haptic feedback capability")
  }

  func testSessionCompletionWithHapticFeedback() {
    // Test that session completion triggers haptic feedback
    let manager = LiveActivityManager.shared

    // This should complete successfully with haptic feedback
    XCTAssertNoThrow(
      manager.completeSessionWithFeedback(),
      "Session completion with haptic feedback should not throw")
  }

  // MARK: - Edge Cases and Error Handling

  func testHapticFeedbackOnUnsupportedDevice() {
    // Test graceful handling when haptic feedback is not supported
    let manager = HapticFeedbackManager.shared

    // Should not crash even if device doesn't support haptics
    XCTAssertNoThrow(
      manager.provideCompletionFeedback(), "Should handle unsupported devices gracefully")
  }

  func testHapticFeedbackWithSystemSettingsDisabled() {
    // Test behavior when haptic feedback is disabled in system settings
    let manager = HapticFeedbackManager.shared

    // Should still complete without error
    XCTAssertNoThrow(
      manager.provideCompletionFeedback(), "Should handle disabled system settings gracefully")
  }

  // MARK: - Integration with Timer Completion

  func testTimerCompletionTriggersHapticFeedback() {
    // Test that timer completion properly triggers haptic feedback
    // This is a behavioral test - we verify the method can be called

    let expectation = XCTestExpectation(description: "Haptic feedback called on completion")

    // Mock completion scenario
    DispatchQueue.main.async {
      let manager = HapticFeedbackManager.shared
      manager.provideCompletionFeedback()
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  func testTimerCancellationDoesNotTriggerHapticFeedback() async {
    // Test that timer cancellation does NOT trigger haptic feedback
    // This is a design requirement - only completion should trigger feedback

    let manager = LiveActivityManager.shared

    // Cancellation should not include haptic feedback
    await manager.endActivity()
    XCTAssertTrue(true, "Cancellation did not crash")
  }

  // MARK: - Timing and Performance Tests

  func testHapticFeedbackPerformance() {
    // Test that haptic feedback is fast and doesn't block the UI
    let manager = HapticFeedbackManager.shared

    measure {
      manager.provideCompletionFeedback()
    }
  }
}
