import XCTest

@MainActor
final class SessionHistoryUITests: XCTestCase {
  func testSessionHistoryNavigationShowsEmptyState() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    app.launchArguments = [
      "UITesting",
      "-DISABLE_SYSTEM_INTEGRATIONS",
      "-RESET_SESSION_HISTORY_FOR_TESTS",
    ]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["settings_button"].waitForExistence(timeout: 5))
    app.buttons["settings_button"].tap()

    XCTAssertTrue(app.buttons["session_history_link"].waitForExistence(timeout: 5))
    app.buttons["session_history_link"].tap()

    XCTAssertTrue(app.navigationBars["Session History"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.otherElements["session_history_empty_state"].waitForExistence(timeout: 5))
  }

  func testSessionHistoryShowsRecordedSessionStatus() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    app.launchArguments = [
      "UITesting",
      "-DISABLE_SYSTEM_INTEGRATIONS",
      "-RESET_SESSION_HISTORY_FOR_TESTS",
    ]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["start_session_button"].waitForExistence(timeout: 5))
    app.buttons["start_session_button"].tap()

    XCTAssertTrue(app.buttons["complete_timer_button"].waitForExistence(timeout: 5))
    app.buttons["complete_timer_button"].tap()

    XCTAssertTrue(app.buttons["settings_button"].waitForExistence(timeout: 5))
    app.buttons["settings_button"].tap()

    XCTAssertTrue(app.buttons["session_history_link"].waitForExistence(timeout: 5))
    app.buttons["session_history_link"].tap()

    XCTAssertTrue(app.otherElements["session_history_list"].waitForExistence(timeout: 5))
    XCTAssertTrue(app.staticTexts["Pending"].exists || app.staticTexts["Written"].exists)
  }
}
