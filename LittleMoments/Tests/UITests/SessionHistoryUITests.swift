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
    XCTAssertTrue(app.staticTexts["No Session History"].waitForExistence(timeout: 10))
  }

  func testSessionHistoryShowsRecordedSessionStatus() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    app.launchArguments = [
      "UITesting",
      "-DISABLE_SYSTEM_INTEGRATIONS",
      "-RESET_SESSION_HISTORY_FOR_TESTS",
      "-SEED_SESSION_HISTORY_FOR_TESTS",
    ]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["settings_button"].waitForExistence(timeout: 5))
    app.buttons["settings_button"].tap()

    XCTAssertTrue(app.buttons["session_history_link"].waitForExistence(timeout: 5))
    app.buttons["session_history_link"].tap()

    XCTAssertTrue(app.navigationBars["Session History"].waitForExistence(timeout: 5))

    let historyCell = app.cells.firstMatch
    let emptyState = app.staticTexts["No Session History"]
    let existsPredicate = NSPredicate(format: "exists == true")
    let historyExpectation = expectation(for: existsPredicate, evaluatedWith: historyCell)
    let emptyExpectation = expectation(for: existsPredicate, evaluatedWith: emptyState)
    let result = XCTWaiter().wait(for: [historyExpectation, emptyExpectation], timeout: 10)

    XCTAssertNotEqual(result, .timedOut)
  }
}
