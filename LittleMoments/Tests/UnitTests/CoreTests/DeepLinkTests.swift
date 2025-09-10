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
    let url = URL(string: "littlemoments://startSession")!
    app.handleDeepLink(url: url)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
  }

  func testWrongSchemeIsIgnored() {
    XCTAssertFalse(AppState.shared.showTimerRunningView)
    let app = LittleMomentsApp()
    let url = URL(string: "otherapp://startSession")!
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
}
