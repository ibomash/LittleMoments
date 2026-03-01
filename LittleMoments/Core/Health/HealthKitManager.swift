//
//  HealthKitManager.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/12/23.
//

@preconcurrency import HealthKit

enum HealthKitManagerError: Error {
  case healthStoreUnavailable
  case mindfulSessionTypeUnavailable
}

@MainActor
final class HealthKitManager {

  static let shared = HealthKitManager()
  static let sessionSyncIdentifierMetadataKey = "net.bomash.illya.littlemoments.session_id"

  private var healthStore: HKHealthStore?

  private init() {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore = HKHealthStore()
    }
  }

  private var mindfulSessionType: HKCategoryType? {
    HKObjectType.categoryType(forIdentifier: .mindfulSession)
  }

  func isHealthDataAvailable() -> Bool {
    HKHealthStore.isHealthDataAvailable() && healthStore != nil
  }

  func authorizationStatusForMindfulSession() -> HKAuthorizationStatus {
    guard let mindfulSessionType, let healthStore else { return .notDetermined }
    return healthStore.authorizationStatus(for: mindfulSessionType)
  }

  func canWriteMindfulSession() -> Bool {
    isHealthDataAvailable() && authorizationStatusForMindfulSession() == .sharingAuthorized
  }

  func requestAuthorization(completion: @Sendable @escaping (Bool, Error?) -> Swift.Void) {
    guard let mindfulSessionType else {
      completion(false, HealthKitManagerError.mindfulSessionTypeUnavailable)
      return
    }

    guard let healthStore else {
      completion(false, HealthKitManagerError.healthStoreUnavailable)
      return
    }

    let healthKitTypesToWrite: Set<HKSampleType> = [mindfulSessionType]
    healthStore.requestAuthorization(
      toShare: healthKitTypesToWrite, read: nil, completion: completion)
  }

  func requestAuthorization() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      requestAuthorization { success, error in
        if let error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: success)
        }
      }
    }
  }

  func createMindfulSession(
    startDate: Date,
    endDate: Date,
    metadata: [String: Any]? = nil
  ) -> HKCategorySample? {
    guard let mindfulSessionType else { return nil }

    return HKCategorySample(
      type: mindfulSessionType,
      value: 0,
      start: startDate,
      end: endDate,
      metadata: metadata
    )
  }

  func saveMindfulSession(
    mindfulSession: HKCategorySample,
    completion: @Sendable @escaping (Bool, Error?) -> Swift.Void
  ) {
    guard let healthStore else {
      completion(false, HealthKitManagerError.healthStoreUnavailable)
      return
    }

    healthStore.save(mindfulSession, withCompletion: completion)
  }

  func saveMindfulSession(mindfulSession: HKCategorySample) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      saveMindfulSession(mindfulSession: mindfulSession) { success, error in
        if let error {
          continuation.resume(throwing: error)
        } else if success {
          continuation.resume(returning: ())
        } else {
          continuation.resume(throwing: HealthKitManagerError.healthStoreUnavailable)
        }
      }
    }
  }

  func fetchMindfulSessions(startDate: Date, endDate: Date) async throws -> [HKCategorySample] {
    guard let mindfulSessionType else {
      throw HealthKitManagerError.mindfulSessionTypeUnavailable
    }
    guard let healthStore else {
      throw HealthKitManagerError.healthStoreUnavailable
    }

    return try await withCheckedThrowingContinuation { continuation in
      let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
      let query = HKSampleQuery(
        sampleType: mindfulSessionType,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
      ) { _, samples, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        let mindfulSessions = (samples as? [HKCategorySample]) ?? []
        continuation.resume(returning: mindfulSessions)
      }

      healthStore.execute(query)
    }
  }

  func findExistingMindfulSession(
    sessionIdentifier: UUID,
    startDate: Date,
    endDate: Date,
    tolerance: TimeInterval = 5
  ) async throws -> HKCategorySample? {
    let windowStart = startDate.addingTimeInterval(-tolerance)
    let windowEnd = endDate.addingTimeInterval(tolerance)
    let sessions = try await fetchMindfulSessions(startDate: windowStart, endDate: windowEnd)

    let identifierString = sessionIdentifier.uuidString
    if let exactMatch = sessions.first(where: {
      ($0.metadata?[Self.sessionSyncIdentifierMetadataKey] as? String) == identifierString
    }) {
      return exactMatch
    }

    return sessions.first(where: { sample in
      abs(sample.startDate.timeIntervalSince(startDate)) <= tolerance
        && abs(sample.endDate.timeIntervalSince(endDate)) <= tolerance
    })
  }
}
