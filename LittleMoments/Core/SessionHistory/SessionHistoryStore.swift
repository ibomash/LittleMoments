import Foundation
import SwiftData

struct PendingSessionHistorySnapshot: Sendable {
  let id: UUID
  let startDate: Date
  let endDate: Date
}

@MainActor
final class SessionHistoryStore {
  static let shared = SessionHistoryStore()

  static let cloudKitContainerIdentifier = "iCloud.net.bomash.illya.LittleMoments.v202602"
  private static let deviceIdentifierDefaultsKey = "sessionHistoryDeviceIdentifier"

  let modelContainer: ModelContainer
  private let userDefaults: UserDefaults

  init(
    modelContainer: ModelContainer? = nil,
    userDefaults: UserDefaults = .standard
  ) {
    self.modelContainer = modelContainer ?? SessionHistoryStore.makeDefaultModelContainer()
    self.userDefaults = userDefaults
  }

  var modelContext: ModelContext {
    modelContainer.mainContext
  }

  @discardableResult
  func recordCompletedSession(
    startDate: Date, endDate: Date, sourceDeviceId: String? = nil
  ) throws
    -> SessionHistoryEntry
  {
    let durationSeconds = max(0, Int(endDate.timeIntervalSince(startDate).rounded()))
    let entry = SessionHistoryEntry(
      startDate: startDate,
      endDate: endDate,
      durationSeconds: durationSeconds,
      sourceDeviceId: sourceDeviceId ?? deviceIdentifier()
    )
    modelContext.insert(entry)
    try modelContext.save()
    return entry
  }

  func fetchPendingEntries(limit: Int = 100) throws -> [SessionHistoryEntry] {
    var descriptor = FetchDescriptor<SessionHistoryEntry>(
      predicate: #Predicate {
        $0.healthWriteStatusRaw == "pending_health_write"
      },
      sortBy: [
        SortDescriptor(\SessionHistoryEntry.createdAt, order: .forward)
      ]
    )
    descriptor.fetchLimit = limit
    return try modelContext.fetch(descriptor)
  }

  func fetchPendingSnapshots(limit: Int = 100) throws -> [PendingSessionHistorySnapshot] {
    try fetchPendingEntries(limit: limit).map {
      PendingSessionHistorySnapshot(id: $0.id, startDate: $0.startDate, endDate: $0.endDate)
    }
  }

  func fetchAllEntriesNewestFirst(limit: Int? = nil) throws -> [SessionHistoryEntry] {
    var descriptor = FetchDescriptor<SessionHistoryEntry>(
      sortBy: [
        SortDescriptor(\SessionHistoryEntry.endDate, order: .reverse)
      ]
    )
    if let limit {
      descriptor.fetchLimit = limit
    }
    return try modelContext.fetch(descriptor)
  }

  func fetchEntry(id: UUID) throws -> SessionHistoryEntry? {
    let descriptor = FetchDescriptor<SessionHistoryEntry>(
      predicate: #Predicate {
        $0.id == id
      },
      sortBy: []
    )
    return try modelContext.fetch(descriptor).first
  }

  func markWritten(entryID: UUID, writtenAt: Date = Date()) throws {
    guard let entry = try fetchEntry(id: entryID) else { return }
    entry.healthWriteStatus = .writtenToHealth
    entry.healthWrittenAt = writtenAt
    entry.lastWriteAttemptAt = writtenAt
    entry.lastWriteErrorCode = nil
    try modelContext.save()
  }

  func markWriteAttempt(entryID: UUID, attemptedAt: Date = Date(), errorCode: String?) throws {
    guard let entry = try fetchEntry(id: entryID) else { return }
    entry.lastWriteAttemptAt = attemptedAt
    entry.lastWriteErrorCode = errorCode
    try modelContext.save()
  }

  func purgeAllEntries() throws {
    let descriptor = FetchDescriptor<SessionHistoryEntry>()
    let entries = try modelContext.fetch(descriptor)
    for entry in entries {
      modelContext.delete(entry)
    }
    try modelContext.save()
  }

  func deviceIdentifier() -> String {
    if let cached = userDefaults.string(forKey: Self.deviceIdentifierDefaultsKey), !cached.isEmpty {
      return cached
    }

    let generated = UUID().uuidString
    userDefaults.set(generated, forKey: Self.deviceIdentifierDefaultsKey)
    return generated
  }

  static func makeInMemoryModelContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(
      "SessionHistoryInMemory",
      isStoredInMemoryOnly: true,
      groupContainer: .none,
      cloudKitDatabase: .none
    )
    return try ModelContainer(for: SessionHistoryEntry.self, configurations: configuration)
  }

  static func makeDefaultModelContainer() -> ModelContainer {
    do {
      let configuration = try makeCloudKitConfiguration()
      return try ModelContainer(for: SessionHistoryEntry.self, configurations: configuration)
    } catch {
      print("SessionHistoryStore: falling back to local-only SwiftData store: \(error)")
      do {
        let fallbackConfiguration = try makeLocalConfiguration()
        return try ModelContainer(
          for: SessionHistoryEntry.self,
          configurations: fallbackConfiguration
        )
      } catch {
        fatalError("SessionHistoryStore: unable to initialize model container: \(error)")
      }
    }
  }

  private static func makeCloudKitConfiguration() throws -> ModelConfiguration {
    let storeURL = try makeStoreURL(fileName: "SessionHistory.store")
    return ModelConfiguration(
      "SessionHistory",
      url: storeURL,
      cloudKitDatabase: .private(cloudKitContainerIdentifier)
    )
  }

  private static func makeLocalConfiguration() throws -> ModelConfiguration {
    let storeURL = try makeStoreURL(fileName: "SessionHistoryLocal.store")
    return ModelConfiguration(
      "SessionHistoryLocal",
      url: storeURL,
      cloudKitDatabase: .none
    )
  }

  private static func makeStoreURL(fileName: String) throws -> URL {
    let appSupport = try FileManager.default.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    return appSupport.appendingPathComponent(fileName)
  }
}
