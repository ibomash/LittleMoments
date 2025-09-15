import XCTest

@MainActor
final class TimerDeepLinkUITests: XCTestCase {

  // MARK: - Deep Link UI Testing Issues

  /*
   * DO NOT RUN: This test is currently disabled due to XCUITest limitations
   *
   * ISSUE: XCUIApplication.open(URL(...)) relaunches the app instead of calling onOpenURL,
   * preventing proper deep link testing in the UI test environment.
   *
   * SOLUTION REFERENCE: See specs/2025-09-15-deep-link-testing-strategy.md
   * - Consider alternative testing approaches (unit tests for deep link logic)
   * - Investigate XCUITest workarounds or migration to unit test coverage
   * - Core deep link functionality is already covered in DeepLinkTests.swift
   */

  func DISABLED_testCustomDurationHighlightedViaDeepLink() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    app.launchArguments = ["UITesting", "-DISABLE_SYSTEM_INTEGRATIONS"]
    app.launch()

    app.open(URL(string: "littlemoments://startSession?duration=420")!)
    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))

    // Verify the temporary 7-minute option appears and is highlighted
    let selectedSeven = app.buttons["selected_duration_7"]
    XCTAssertTrue(selectedSeven.waitForExistence(timeout: 10))
  }
}
