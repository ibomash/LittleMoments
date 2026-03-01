import Foundation
import SwiftData
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class SessionHistoryStoreTests: XCTestCase {
  private var modelContainer: ModelContainer!
  private var userDefaults: UserDefaults!
  private var store: SessionHistoryStore!
  private var userDefaultsSuiteName: String!

  @MainActor override func setUp() async throws {
    try await super.setUp()
    modelContainer = try SessionHistoryStore.makeInMemoryModelContainer()

    userDefaultsSuiteName = "SessionHistoryStoreTests-\(UUID().uuidString)"
    userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
    userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)

    store = SessionHistoryStore(
      modelContainer: modelContainer,
      userDefaults: userDefaults
    )
  }

  @MainActor override func tearDown() async throws {
    if let userDefaults, let userDefaultsSuiteName {
      userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }

    store = nil
    userDefaults = nil
    modelContainer = nil
    userDefaultsSuiteName = nil
    try await super.tearDown()
  }

  func testRecordCompletedSessionPersistsPendingEntry() throws {
    let startDate = Date(timeIntervalSince1970: 1_000)
    let endDate = startDate.addingTimeInterval(125)

    let entry = try store.recordCompletedSession(startDate: startDate, endDate: endDate)

    XCTAssertEqual(entry.startDate, startDate)
    XCTAssertEqual(entry.endDate, endDate)
    XCTAssertEqual(entry.durationSeconds, 125)
    XCTAssertEqual(entry.healthWriteStatus, .pendingHealthWrite)
    XCTAssertFalse(entry.sourceDeviceId.isEmpty)

    let pending = try store.fetchPendingEntries()
    XCTAssertEqual(pending.count, 1)
    XCTAssertEqual(pending.first?.id, entry.id)
  }

  func testMarkWriteAttemptAndMarkWrittenTransitionState() throws {
    let startDate = Date(timeIntervalSince1970: 2_000)
    let endDate = startDate.addingTimeInterval(60)
    let entry = try store.recordCompletedSession(startDate: startDate, endDate: endDate)

    let attemptDate = Date(timeIntervalSince1970: 3_000)
    try store.markWriteAttempt(entryID: entry.id, attemptedAt: attemptDate, errorCode: "hk:error")

    let afterAttempt = try XCTUnwrap(store.fetchEntry(id: entry.id))
    XCTAssertEqual(afterAttempt.healthWriteStatus, .pendingHealthWrite)
    XCTAssertEqual(afterAttempt.lastWriteAttemptAt, attemptDate)
    XCTAssertEqual(afterAttempt.lastWriteErrorCode, "hk:error")

    let writtenAt = Date(timeIntervalSince1970: 4_000)
    try store.markWritten(entryID: entry.id, writtenAt: writtenAt)

    let afterWritten = try XCTUnwrap(store.fetchEntry(id: entry.id))
    XCTAssertEqual(afterWritten.healthWriteStatus, .writtenToHealth)
    XCTAssertEqual(afterWritten.healthWrittenAt, writtenAt)
    XCTAssertEqual(afterWritten.lastWriteAttemptAt, writtenAt)
    XCTAssertNil(afterWritten.lastWriteErrorCode)
  }

  func testFetchPendingSnapshotsOnlyReturnsPendingEntries() throws {
    let startDate = Date(timeIntervalSince1970: 10_000)
    let first = try store.recordCompletedSession(
      startDate: startDate,
      endDate: startDate.addingTimeInterval(30)
    )
    let second = try store.recordCompletedSession(
      startDate: startDate.addingTimeInterval(120),
      endDate: startDate.addingTimeInterval(180)
    )

    try store.markWritten(entryID: first.id)
    let snapshots = try store.fetchPendingSnapshots(limit: 10)

    XCTAssertEqual(snapshots.count, 1)
    XCTAssertEqual(snapshots.first?.id, second.id)
  }

  func testDeviceIdentifierPersistsForSameUserDefaults() throws {
    let firstIdentifier = store.deviceIdentifier()
    let secondStore = SessionHistoryStore(
      modelContainer: modelContainer,
      userDefaults: userDefaults
    )

    XCTAssertEqual(firstIdentifier, secondStore.deviceIdentifier())
  }
}
