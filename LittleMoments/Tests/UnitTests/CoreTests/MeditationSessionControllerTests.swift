import XCTest

@testable import LittleMoments

@MainActor
final class MeditationSessionControllerTests: XCTestCase {
  func testStartTracksDateTargetAndElapsedProgress() throws {
    let controller = MeditationSessionController()
    let startDate = Date(timeIntervalSince1970: 1_000)

    controller.start(at: startDate, targetDurationSeconds: 120)

    let session = try XCTUnwrap(controller.activeSession)
    XCTAssertEqual(session.startDate, startDate)
    XCTAssertEqual(session.targetDurationSeconds, 120)
    XCTAssertEqual(controller.elapsed(at: startDate.addingTimeInterval(30)), 30)
    XCTAssertEqual(controller.progress(at: startDate.addingTimeInterval(30)), 0.25)
    XCTAssertFalse(controller.isDone(at: startDate.addingTimeInterval(119)))
    XCTAssertTrue(controller.isDone(at: startDate.addingTimeInterval(120)))
  }

  func testTargetCanBeChangedAndClearedWhileRunning() throws {
    let controller = MeditationSessionController()
    controller.start(at: Date(timeIntervalSince1970: 1_000))

    controller.setTarget(durationSeconds: 300)
    XCTAssertEqual(try XCTUnwrap(controller.activeSession).targetDurationSeconds, 300)

    controller.setTarget(durationSeconds: nil)
    XCTAssertNil(try XCTUnwrap(controller.activeSession).targetDurationSeconds)
    XCTAssertEqual(controller.progress(), 0)
    XCTAssertFalse(controller.isDone())
  }

  func testEndReturnsFinishedSessionAndResetsState() throws {
    let controller = MeditationSessionController()
    controller.start(at: Date(timeIntervalSince1970: 1_000), targetDurationSeconds: 60)

    let finishedSession = try XCTUnwrap(controller.end())

    XCTAssertEqual(finishedSession.targetDurationSeconds, 60)
    XCTAssertFalse(controller.isRunning)
    XCTAssertNil(controller.activeSession)
    XCTAssertEqual(controller.elapsed(), 0)
  }

  func testElapsedFormattingMatchesExistingTimerPresentation() {
    XCTAssertEqual(MeditationSessionController.formatElapsed(61, showSeconds: true), "1:01")
    XCTAssertEqual(MeditationSessionController.formatElapsed(61, showSeconds: false), "1")
    XCTAssertEqual(MeditationSessionController.formatElapsed(-1, showSeconds: true), "0:00")
  }
}
