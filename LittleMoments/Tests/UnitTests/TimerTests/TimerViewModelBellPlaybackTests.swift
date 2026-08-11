import Foundation
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class TimerViewModelBellPlaybackTests: XCTestCase {
  private var coordinator: SpyBellPlaybackCoordinator!
  private var timerViewModel: TimerViewModel!

  override func setUp() async throws {
    try await super.setUp()
    UserDefaultsReset.resetDefaults()
    coordinator = SpyBellPlaybackCoordinator()
    timerViewModel = TimerViewModel(bellPlaybackCoordinator: coordinator)
  }

  override func tearDown() async throws {
    timerViewModel.reset()
    timerViewModel = nil
    coordinator = nil
    try await super.tearDown()
  }

  func testStartNotifiesBellPlaybackCoordinator() {
    JustNowSettings.shared.ringBellAtStart = false

    timerViewModel.start()

    XCTAssertEqual(coordinator.startCalls.count, 1)
    XCTAssertFalse(coordinator.startCalls[0].ringBellAtStart)
  }

  func testSettingDurationWhileRunningPlansTarget() {
    timerViewModel.start()
    timerViewModel.setDurationTarget(seconds: 300)

    XCTAssertEqual(coordinator.targetCalls.last?.secondsFromSessionStart, 300)
  }

  func testClearingDurationCancelsPlaybackTarget() {
    timerViewModel.start()
    timerViewModel.setDurationTarget(seconds: 300)
    timerViewModel.clearDurationTarget()

    XCTAssertNil(coordinator.targetCalls.last?.secondsFromSessionStart)
  }

  func testResetCancelsPlaybackSession() {
    timerViewModel.start()
    timerViewModel.reset()

    XCTAssertEqual(coordinator.cancelCallCount, 1)
  }

  func testDueScheduledAlertRequestsAudibilityOnce() {
    timerViewModel.start()
    timerViewModel.setDurationTarget(seconds: 300)

    timerViewModel.checkScheduledAlert(secondsElapsed: 300)
    timerViewModel.checkScheduledAlert(secondsElapsed: 301)

    XCTAssertEqual(coordinator.ensureAudibleCalls, [300])
  }
}

@MainActor
private final class SpyBellPlaybackCoordinator: BellPlaybackCoordinating {
  var mode: BellPlaybackMode = .off
  var startCalls: [(startDate: Date, ringBellAtStart: Bool)] = []
  var targetCalls: [(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval)] = []
  var ensureAudibleCalls: [TimeInterval] = []
  var finishCallCount = 0
  var cancelCallCount = 0

  func startSession(startDate: Date, ringBellAtStart: Bool) {
    startCalls.append((startDate, ringBellAtStart))
  }

  func setTarget(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval) {
    targetCalls.append((secondsFromSessionStart, elapsedSeconds))
  }

  func ensureCompletionBellAudible(elapsedSeconds: TimeInterval) {
    ensureAudibleCalls.append(elapsedSeconds)
  }

  func finishSession() {
    finishCallCount += 1
  }

  func cancelSession() {
    cancelCallCount += 1
  }
}
