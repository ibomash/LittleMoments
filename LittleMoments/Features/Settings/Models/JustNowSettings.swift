//
//  JustNowSettings.swift
//  Little Moments
//
//  Created during migration
//

// import Foundation
// Add import for HealthKitManager which is in Core/Health
import HealthKit
import SwiftUI

class JustNowSettings: ObservableObject {
  static let shared = JustNowSettings()

  private let userDefaults = UserDefaults.standard

  var writeToHealth: Bool {
    get {
      return userDefaults.bool(forKey: "writeToHealth")
    }
    set {
      if newValue {
        HealthKitManager.shared.requestAuthorization { (success, error) in
          if !success {
            print("HealthKit permission denied: ", error?.localizedDescription ?? "Unknown error")
            return
          }
        }
      }
      userDefaults.set(newValue, forKey: "writeToHealth")
      userDefaults.synchronize()
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
