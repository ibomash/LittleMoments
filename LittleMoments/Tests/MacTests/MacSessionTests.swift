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

@MainActor
final class MacSessionPersistenceTests: XCTestCase {
  private enum SaveError: Error {
    case unavailable
  }

  private func makeModel(
    saveSession: @escaping (Date, Date) throws -> Void
  ) throws -> MacSessionModel {
    let historyStore = SessionHistoryStore(
      modelContainer: try SessionHistoryStore.makeInMemoryModelContainer()
    )
    return MacSessionModel(historyStore: historyStore, saveSession: saveSession)
  }

  func testFailedCompletionPreservesSessionAndCanBeRetried() throws {
    var shouldFail = true
    var savedSessions = 0
    let model = try makeModel { _, _ in
      if shouldFail { throw SaveError.unavailable }
      savedSessions += 1
    }
    model.start()
    let originalSession = try XCTUnwrap(model.sessionController.activeSession)

    XCTAssertFalse(model.complete())
    XCTAssertEqual(model.sessionController.activeSession, originalSession)
    XCTAssertNotNil(model.errorMessage)
    XCTAssertEqual(savedSessions, 0)

    shouldFail = false
    XCTAssertTrue(model.complete())
    XCTAssertFalse(model.isRunning)
    XCTAssertNil(model.errorMessage)
    XCTAssertEqual(savedSessions, 1)
    XCTAssertFalse(model.complete())
    XCTAssertEqual(savedSessions, 1)
  }

  func testCompleteAndQuitRequiresSuccessfulSave() throws {
    var shouldFail = true
    let model = try makeModel { _, _ in
      if shouldFail { throw SaveError.unavailable }
    }
    let coordinator = MacTerminationCoordinator(model: model)
    model.start()

    XCTAssertFalse(coordinator.completeSessionForTermination())
    XCTAssertTrue(model.isRunning)
    XCTAssertNotNil(model.errorMessage)

    shouldFail = false
    XCTAssertTrue(coordinator.completeSessionForTermination())
    XCTAssertFalse(model.isRunning)
    XCTAssertEqual(coordinator.applicationShouldTerminate(), .terminateNow)
  }

  func testCancelAfterFailedSaveDiscardsSessionAndClearsError() throws {
    let model = try makeModel { _, _ in throw SaveError.unavailable }
    model.start()
    XCTAssertFalse(model.complete())

    model.cancel()

    XCTAssertFalse(model.isRunning)
    XCTAssertNil(model.errorMessage)
  }

  func testCompletionPersistsOriginalStartAndRequestedEnd() throws {
    var savedStart: Date?
    var savedEnd: Date?
    let model = try makeModel { startDate, endDate in
      savedStart = startDate
      savedEnd = endDate
    }
    let start = Date(timeIntervalSince1970: 1_000)
    let end = start.addingTimeInterval(60)
    model.start(at: start)

    XCTAssertTrue(model.complete(at: end))
    XCTAssertEqual(savedStart, start)
    XCTAssertEqual(savedEnd, end)
  }
}
