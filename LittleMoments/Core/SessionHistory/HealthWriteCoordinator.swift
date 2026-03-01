import Foundation
@preconcurrency import HealthKit

enum HealthWriteProcessingTrigger: String, Sendable {
  case appLaunch
  case appBecameActive
  case sessionCompleted
  case settingsChanged
}

actor HealthWriteCoordinator {
  static let shared = HealthWriteCoordinator()

  private enum SnapshotResult {
    case wroteOrAlreadyExists
    case transientFailure
    case pauseForEligibility
  }

  private struct BatchResult {
    let encounteredTransientError: Bool
    let pauseForEligibility: Bool
  }

  private var isProcessing = false
  private var nextAllowedRunAt: Date?
  private var transientFailureCount = 0

  private init() {}

  func triggerProcessing(_ trigger: HealthWriteProcessingTrigger) {
    Task {
      await processPendingSessions(trigger: trigger)
    }
  }

  func processPendingSessions(trigger: HealthWriteProcessingTrigger) async {
    print("HealthWriteCoordinator triggered by: \(trigger.rawValue)")

    if isProcessing {
      return
    }

    if let nextAllowedRunAt, nextAllowedRunAt > Date() {
      return
    }

    isProcessing = true
    defer { isProcessing = false }

    let eligibility = await HealthWriteEligibility.shared.evaluate()

    guard eligibility.isEligible else {
      resetBackoff()
      return
    }

    do {
      let snapshots = try await SessionHistoryStore.shared.fetchPendingSnapshots(limit: 200)

      if snapshots.isEmpty {
        resetBackoff()
        return
      }

      let result = await processSnapshots(snapshots)

      if result.pauseForEligibility {
        resetBackoff()
      } else if result.encounteredTransientError {
        scheduleBackoff()
      } else {
        resetBackoff()
      }
    } catch {
      scheduleBackoff()
    }
  }

  private func processSnapshots(_ snapshots: [PendingSessionHistorySnapshot]) async -> BatchResult {
    var encounteredTransientError = false

    for snapshot in snapshots {
      let result = await processSnapshot(snapshot)
      switch result {
      case .wroteOrAlreadyExists:
        continue
      case .transientFailure:
        encounteredTransientError = true
      case .pauseForEligibility:
        return BatchResult(
          encounteredTransientError: encounteredTransientError, pauseForEligibility: true)
      }
    }

    return BatchResult(
      encounteredTransientError: encounteredTransientError, pauseForEligibility: false)
  }

  private func processSnapshot(_ snapshot: PendingSessionHistorySnapshot) async -> SnapshotResult {
    do {
      let existingSession = try await HealthKitManager.shared.findExistingMindfulSession(
        sessionIdentifier: snapshot.id,
        startDate: snapshot.startDate,
        endDate: snapshot.endDate
      )

      if existingSession != nil {
        try await SessionHistoryStore.shared.markWritten(entryID: snapshot.id)
        return .wroteOrAlreadyExists
      }

      guard
        let sample = await HealthKitManager.shared.createMindfulSession(
          startDate: snapshot.startDate,
          endDate: snapshot.endDate,
          metadata: [
            HealthKitManager.sessionSyncIdentifierMetadataKey: snapshot.id.uuidString
          ]
        )
      else {
        try? await SessionHistoryStore.shared.markWriteAttempt(
          entryID: snapshot.id,
          errorCode: String(describing: HealthKitManagerError.mindfulSessionTypeUnavailable)
        )
        return .pauseForEligibility
      }

      try await HealthKitManager.shared.saveMindfulSession(mindfulSession: sample)
      try await SessionHistoryStore.shared.markWritten(entryID: snapshot.id)
      return .wroteOrAlreadyExists
    } catch {
      try? await SessionHistoryStore.shared.markWriteAttempt(
        entryID: snapshot.id,
        errorCode: errorCode(for: error)
      )

      if shouldPauseForEligibility(error: error) {
        return .pauseForEligibility
      }

      return .transientFailure
    }
  }

  private func scheduleBackoff() {
    transientFailureCount += 1
    let interval = min(pow(2, Double(transientFailureCount)) * 10, 10 * 60)
    nextAllowedRunAt = Date().addingTimeInterval(interval)
  }

  private func resetBackoff() {
    transientFailureCount = 0
    nextAllowedRunAt = nil
  }

  private func shouldPauseForEligibility(error: Error) -> Bool {
    if let managerError = error as? HealthKitManagerError {
      switch managerError {
      case .healthStoreUnavailable, .mindfulSessionTypeUnavailable:
        return true
      }
    }

    let nsError = error as NSError
    if nsError.domain == HKError.errorDomain {
      return nsError.code == HKError.errorAuthorizationDenied.rawValue
        || nsError.code == HKError.errorHealthDataUnavailable.rawValue
    }

    return false
  }

  private func errorCode(for error: Error) -> String {
    let nsError = error as NSError
    return "\(nsError.domain):\(nsError.code)"
  }
}
