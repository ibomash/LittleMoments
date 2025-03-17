//
//  SettingsService.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation

/// Protocol defining the settings service functionality
protocol SettingsServiceProtocol {
    /// Whether to write meditation sessions to HealthKit
    var writeToHealth: Bool { get set }
    
    /// Whether to ring the bell at the start of a session
    var ringBellAtStart: Bool { get set }
    
    /// Whether to show seconds in the timer display
    var showSeconds: Bool { get set }
}

/// Concrete implementation of the SettingsServiceProtocol
final class SettingsServiceImpl: SettingsServiceProtocol, ObservableObject {
    /// Singleton instance for backward compatibility 
    /// Will be deprecated after refactoring is complete
    static let shared = SettingsServiceImpl()
    
    /// UserDefaults instance for storing settings
    private let userDefaults: UserDefaults
    
    /// HealthKit service dependency
    private let healthKitService: HealthKitServiceProtocol?
    
    /// Initializes a new settings service
    /// - Parameters:
    ///   - userDefaults: The UserDefaults instance to use
    ///   - healthKitService: The HealthKit service to use
    init(
        userDefaults: UserDefaults = .standard,
        healthKitService: HealthKitServiceProtocol? = nil
    ) {
        self.userDefaults = userDefaults
        self.healthKitService = healthKitService
    }
    
    /// Whether to write meditation sessions to HealthKit
    var writeToHealth: Bool {
        get {
            return userDefaults.bool(forKey: "writeToHealth")
        }
        set {
            if newValue {
                healthKitService?.requestAuthorization { success, error in
                    if !success {
                        print("HealthKit permission denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
            userDefaults.set(newValue, forKey: "writeToHealth")
            userDefaults.synchronize()
        }
    }
    
    /// Whether to ring the bell at the start of a session
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
    
    /// Whether to show seconds in the timer display
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
} 