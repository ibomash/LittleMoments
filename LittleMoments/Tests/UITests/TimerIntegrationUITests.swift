import XCTest

@MainActor
final class TimerIntegrationUITests: XCTestCase {
  // This test intentionally does NOT pass -DISABLE_SYSTEM_INTEGRATIONS
  // so it exercises the UNUserNotificationCenter authorization callback path.

  func testSelectingDurationSchedulesNotification_NoCrash() throws {
    let app = XCUIApplication()
    continueAfterFailure = false

    // Handle the notifications permission sheet if it appears
    addUIInterruptionMonitor(withDescription: "Notifications") { alert in
      if alert.buttons["Allow"].exists {
        alert.buttons["Allow"].tap()
        return true
      }
      if alert.buttons["Don’t Allow"].exists {
        alert.buttons["Don’t Allow"].tap()
        return true
      }
      if alert.buttons["Don't Allow"].exists {
        alert.buttons["Don't Allow"].tap()
        return true
      }
      return false
    }

    app.launchArguments = ["UITesting"]
    app.launch()
    app.activate()
    // Trigger monitor immediately if permission alert shows on main screen
    app.tap()

    // Go into running view
    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 10))
    app.buttons["Start session"].tap()
    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10))

    // Tap a short duration to trigger scheduling + authorization callback
    if app.buttons["5 sec"].waitForExistence(timeout: 2) {
      app.buttons["5 sec"].tap()
    } else if app.buttons["1"].waitForExistence(timeout: 2) {
      app.buttons["1"].tap()
    }

    // Trigger interruption handler if the permission alert is shown
    app.tap()

    // Give things a moment; if the app crashes from thread violations,
    // the test will fail with "application is not running".
    _ = XCTWaiter.wait(for: [expectation(description: "settle")], timeout: 2.5)

    // Complete to dismiss
    app.buttons["Complete"].tap()
    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 5))
  }
}
