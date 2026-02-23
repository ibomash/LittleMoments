//
//  JustNowSettings.swift
//  Little Moments
//
//  Created during migration
//

import Foundation
import HealthKit
import SwiftUI

@MainActor
final class JustNowSettings: ObservableObject {
  static let shared = JustNowSettings()

  private let userDefaults = UserDefaults.standard

  var writeToHealth: Bool {
    get {
      return userDefaults.bool(forKey: "writeToHealth")
    }
    set {
      if newValue {
        HealthKitManager.shared.requestAuthorization { @Sendable (success, error) in
          if !success {
            print("HealthKit permission denied: ", error?.localizedDescription ?? "Unknown error")
            return
          }

          Task {
            await HealthWriteCoordinator.shared.triggerProcessing(.settingsChanged)
          }
        }
      }

      userDefaults.set(newValue, forKey: "writeToHealth")
      userDefaults.synchronize()

      Task {
        await HealthWriteCoordinator.shared.triggerProcessing(.settingsChanged)
      }
    }
  }

  var ringBellAtStart: Bool {
    get {
      if let value = userDefaults.object(forKey: "ringBellAtStart") as? Bool {
        return value
      } else {
        return true  // Default value
      }
    }
    set {
      userDefaults.set(newValue, forKey: "ringBellAtStart")
      userDefaults.synchronize()
    }
  }

  var showSeconds: Bool {
    get {
      if let value = userDefaults.object(forKey: "showSeconds") as? Bool {
        return value
      } else {
        return true  // Default value
      }
    }
    set {
      userDefaults.set(newValue, forKey: "showSeconds")
      userDefaults.synchronize()
    }
  }

  var enableLiveActivities: Bool {
    get {
      if let value = userDefaults.object(forKey: "enableLiveActivities") as? Bool {
        return value
      } else {
        return true  // Default value
      }
    }
    set {
      userDefaults.set(newValue, forKey: "enableLiveActivities")
      userDefaults.synchronize()
    }
  }

  private init() {}
}
