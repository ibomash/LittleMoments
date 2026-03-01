import Foundation
@preconcurrency import HealthKit

enum HealthWriteIneligibilityReason: String, Sendable {
  case healthDataUnavailable
  case settingDisabled
  case authorizationNotGranted
}

struct HealthWriteEligibilityState: Sendable {
  let isEligible: Bool
  let reason: HealthWriteIneligibilityReason?
}

@MainActor
final class HealthWriteEligibility {
  static let shared = HealthWriteEligibility()

  private init() {}

  func evaluate(
    settings: JustNowSettings = .shared,
    healthKitManager: HealthKitManager = .shared
  ) -> HealthWriteEligibilityState {
    guard healthKitManager.isHealthDataAvailable() else {
      return HealthWriteEligibilityState(
        isEligible: false,
        reason: .healthDataUnavailable
      )
    }

    guard settings.writeToHealth else {
      return HealthWriteEligibilityState(
        isEligible: false,
        reason: .settingDisabled
      )
    }

    guard healthKitManager.authorizationStatusForMindfulSession() == .sharingAuthorized else {
      return HealthWriteEligibilityState(
        isEligible: false,
        reason: .authorizationNotGranted
      )
    }

    return HealthWriteEligibilityState(isEligible: true, reason: nil)
  }
}
