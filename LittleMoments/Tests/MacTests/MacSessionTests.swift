import XCTest

@testable import LittleMomentsMac

final class MacTerminationPolicyTests: XCTestCase {
  func testIdleAppTerminatesWithoutConfirmation() {
    XCTAssertEqual(
      MacTerminationPolicy.decision(isSessionRunning: false),
      .terminate
    )
  }

  func testRunningSessionRequiresConfirmation() {
    XCTAssertEqual(
      MacTerminationPolicy.decision(isSessionRunning: true),
      .confirmActiveSession
    )
  }
}

@MainActor
final class MacSharedSessionTests: XCTestCase {
  func testTimedSessionUsesSharedElapsedAndProgressRules() {
    let startDate = Date(timeIntervalSince1970: 1_000)
    let controller = MeditationSessionController()

    controller.start(at: startDate, targetDurationSeconds: 600)

    XCTAssertEqual(controller.elapsed(at: startDate.addingTimeInterval(90)), 90)
    XCTAssertEqual(controller.progress(at: startDate.addingTimeInterval(150)), 0.25)
    XCTAssertFalse(controller.isDone(at: startDate.addingTimeInterval(599)))
    XCTAssertTrue(controller.isDone(at: startDate.addingTimeInterval(600)))
  }

  func testUntimedSessionCanBeEndedCleanly() {
    let controller = MeditationSessionController()
    controller.start(at: Date(timeIntervalSince1970: 1_000))

    XCTAssertTrue(controller.isRunning)
    XCTAssertNil(controller.activeSession?.targetDurationSeconds)

    controller.end()

    XCTAssertFalse(controller.isRunning)
    XCTAssertNil(controller.activeSession)
  }
}
