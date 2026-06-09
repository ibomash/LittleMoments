import XCTest

@MainActor
final class TimerDeepLinkUITests: XCTestCase {

  // MARK: - Deep Link UI Testing Issues

  // DO NOT RUN: This test is currently disabled due to XCUITest limitations.
  //
  // ISSUE: XCUIApplication.open(URL(...)) relaunches the app instead of calling onOpenURL,
  // preventing proper deep link testing in the UI test environment.
  //
  // SOLUTION REFERENCE: See `backlog/docs/doc-8 - Deep-Link-Testing-Strategy.md`.
  // - Consider alternative testing approaches (unit tests for deep link logic).
  // - Investigate XCUITest workarounds or migration to unit test coverage.
  // - Core deep link functionality is already covered in DeepLinkTests.swift.

  func disabledCustomDurationHighlightedViaDeepLink() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    app.launchArguments = ["UITesting", "-DISABLE_SYSTEM_INTEGRATIONS"]
    app.launch()

    app.open(URL(string: "littlemoments://startSession?duration=420")!)
    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))

    // Verify the custom duration chip is highlighted for the 7-minute target
    let selectedCustom = app.buttons["custom_duration_running_chip"]
    XCTAssertTrue(selectedCustom.waitForExistence(timeout: 10))
    XCTAssertTrue(selectedCustom.isSelected)
  }
}
