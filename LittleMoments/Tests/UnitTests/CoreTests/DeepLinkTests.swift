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
    let intent = MeditationSessionIntent(durationMinutes: 2)
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
}
