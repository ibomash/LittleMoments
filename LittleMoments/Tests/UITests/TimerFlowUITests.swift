import XCTest

@MainActor
final class TimerFlowUITests: XCTestCase {
  // No shared app instance; create within each test to avoid actor issues

  func testStartSetTimeThenComplete() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    registerNotificationPermissionMonitor(app: app)
    app.launchArguments = ["UITesting", "-DISABLE_SYSTEM_INTEGRATIONS"]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 10))
    app.buttons["Start session"].tap()

    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), "Timer sheet did not appear")

    registerNotificationPermissionMonitor(app: app)
    selectShortDuration(app: app)
    // Trigger interruption handler if system alert appears
    app.tap()

    _ = XCTWaiter.wait(for: [expectation(description: "wait")], timeout: 3)

    app.buttons["Complete"].tap()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 3))
  }

  func testStartSetTimeThenCancel() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    registerNotificationPermissionMonitor(app: app)
    app.launchArguments = ["UITesting", "-DISABLE_SYSTEM_INTEGRATIONS"]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 10))
    app.buttons["Start session"].tap()

    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), "Timer sheet did not appear")

    registerNotificationPermissionMonitor(app: app)
    selectShortDuration(app: app)
    // Trigger interruption handler if system alert appears
    app.tap()

    _ = XCTWaiter.wait(for: [expectation(description: "wait")], timeout: 2)

    app.buttons["Cancel"].tap()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 3))
  }

  func testStartSetTimeWaitLongerThanTimerThenComplete() throws {
    let app = XCUIApplication()
    continueAfterFailure = false
    registerNotificationPermissionMonitor(app: app)
    app.launchArguments = ["UITesting", "-DISABLE_SYSTEM_INTEGRATIONS"]
    app.launch()
    app.activate()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 10))
    app.buttons["Start session"].tap()

    XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 10), "Timer sheet did not appear")

    registerNotificationPermissionMonitor(app: app)
    selectShortDuration(app: app)
    // Trigger interruption handler if system alert appears
    app.tap()

    // Wait longer than the short timer (5 sec on simulator)
    _ = XCTWaiter.wait(for: [expectation(description: "wait longer than timer")], timeout: 6.5)

    app.buttons["Complete"].tap()

    XCTAssertTrue(app.buttons["Start session"].waitForExistence(timeout: 3))
  }

  private func selectShortDuration(app: XCUIApplication) {
    if app.buttons["5 sec"].exists {
      app.buttons["5 sec"].tap()
    } else if app.buttons["1"].exists {
      app.buttons["1"].tap()
    }
  }

  private func registerNotificationPermissionMonitor(app: XCUIApplication) {
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
  }
}
