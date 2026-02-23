import UIKit
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class DeepLinkTests: XCTestCase {
  @MainActor override func setUp() async throws {
    try await super.setUp()
    UserDefaultsReset.resetDefaults()
    AppState.shared.resetState()
  }

  func testStartSessionDeepLinkOpensTimer() {
    XCTAssertFalse(AppState.shared.showTimerRunningView)
    let app = LittleMomentsApp()
    guard let url = URL(string: "littlemoments://startSession") else {
      return XCTFail("URL should be valid")
    }
    app.handleDeepLink(url: url)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
  }

  func testStartSessionDeepLinkWithDurationSetsPreset() {
    AppState.shared.resetState()
    let app = LittleMomentsApp()
    guard let url = URL(string: "littlemoments://startSession?duration=60") else {
      return XCTFail("URL should be valid")
    }
    app.handleDeepLink(url: url)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, 60)
  }

  func testWrongSchemeIsIgnored() {
    XCTAssertFalse(AppState.shared.showTimerRunningView)
    let app = LittleMomentsApp()
    guard let url = URL(string: "otherapp://startSession") else {
      return XCTFail("URL should be valid")
    }
    app.handleDeepLink(url: url)
    XCTAssertFalse(AppState.shared.showTimerRunningView)
  }

  func testStartSessionDeepLinkIsIgnoredWhenSessionAlreadyRunning() {
    AppState.shared.resetState()
    AppState.shared.showTimerRunningView = true
    let app = LittleMomentsApp()
    guard let url = URL(string: "littlemoments://startSession?duration=420") else {
      return XCTFail("URL should be valid")
    }

    app.handleDeepLink(url: url)

    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertNil(AppState.shared.pendingStartDurationSeconds)
  }

  func testMeditationSessionIntentPerformShowsTimer() {
    AppState.shared.resetState()
    let intent = MeditationSessionIntent()
    let exp = expectation(description: "intent perform")
    Task {
      _ = try? await intent.perform()
      exp.fulfill()
    }
    wait(for: [exp], timeout: 2.0)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
  }

  func testMeditationSessionIntentPerformWithDurationSetsPreset() {
    AppState.shared.resetState()
    var intent = MeditationSessionIntent()
    intent.durationMinutes = 2
    let exp = expectation(description: "intent perform")
    Task {
      _ = try? await intent.perform()
      exp.fulfill()
    }
    wait(for: [exp], timeout: 2.0)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, 120)
  }

  func testParseDurationHelper() throws {
    XCTAssertEqual(LittleMomentsApp.parseDurationToSeconds("60"), 60)
    XCTAssertEqual(LittleMomentsApp.parseDurationToSeconds("60s"), 60)
    XCTAssertEqual(LittleMomentsApp.parseDurationToSeconds("1m"), 60)
    XCTAssertEqual(LittleMomentsApp.parseDurationToSeconds("3m"), 180)
    XCTAssertNil(LittleMomentsApp.parseDurationToSeconds("whoops"))
  }

  func testHomeScreenQuickActionStartsSessionWithDefaultDuration() {
    AppState.shared.resetState()
    let shortcutItem = UIApplicationShortcutItem(
      type: LittleMomentsApp.quickSessionShortcutType,
      localizedTitle: "Quick Session"
    )

    let handled = LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem)

    XCTAssertTrue(handled)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, 300)
  }

  func testHomeScreenQuickActionAcceptsCustomDurationFromUserInfo() {
    AppState.shared.resetState()
    let shortcutItem = UIApplicationShortcutItem(
      type: LittleMomentsApp.quickSessionShortcutType,
      localizedTitle: "Quick Session",
      localizedSubtitle: nil,
      icon: nil,
      userInfo: [
        LittleMomentsApp.quickSessionDurationUserInfoKey: "7m" as NSString
      ]
    )

    let handled = LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem)

    XCTAssertTrue(handled)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, 420)
  }

  func testHomeScreenQuickActionIgnoresStartWhenSessionAlreadyRunning() {
    AppState.shared.resetState()
    AppState.shared.showTimerRunningView = true
    AppState.shared.pendingStartDurationSeconds = nil

    let shortcutItem = UIApplicationShortcutItem(
      type: LittleMomentsApp.quickSessionShortcutType,
      localizedTitle: "Quick Session",
      localizedSubtitle: nil,
      icon: nil,
      userInfo: [
        LittleMomentsApp.quickSessionDurationUserInfoKey: 420 as NSNumber
      ]
    )

    let handled = LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem)

    XCTAssertTrue(handled)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
    XCTAssertNil(AppState.shared.pendingStartDurationSeconds)
  }

  func testUnknownHomeScreenQuickActionTypeIsIgnored() {
    AppState.shared.resetState()
    let shortcutItem = UIApplicationShortcutItem(
      type: "net.bomash.illya.LittleMoments.unknown",
      localizedTitle: "Unknown"
    )

    let handled = LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem)

    XCTAssertFalse(handled)
    XCTAssertFalse(AppState.shared.showTimerRunningView)
    XCTAssertNil(AppState.shared.pendingStartDurationSeconds)
  }
}
