//
//  HealthKitService.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation
import HealthKit

/// Protocol defining the HealthKit service functionality
protocol HealthKitServiceProtocol {
    /// Requests authorization to access HealthKit data
    /// - Parameter completion: Closure called when authorization request completes
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    
    /// Creates a mindful session with start and end dates
    /// - Parameters:
    ///   - startDate: Start date of the session
    ///   - endDate: End date of the session
    /// - Returns: A HealthKit sample representing the mindful session
    func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample
    
    /// Saves a mindful session to HealthKit
    /// - Parameters:
    ///   - mindfulSession: The session to save
    ///   - completion: Closure called when save operation completes
    func saveMindfulSession(mindfulSession: HKCategorySample, completion: @escaping (Bool, Error?) -> Void)
}

/// Concrete implementation of the HealthKitServiceProtocol
final class HealthKitServiceImpl: HealthKitServiceProtocol {
    /// Singleton instance for backward compatibility
    /// Will be deprecated after refactoring is complete
    static let shared = HealthKitServiceImpl()
    
    /// The HealthKit store used to access health data
    private var healthStore: HKHealthStore?
    
    /// Initializes a new HealthKit service
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    /// Requests authorization to access HealthKit data
    /// - Parameter completion: Closure called when authorization request completes
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Define the data types that the app needs access to
        let healthKitTypesToWrite: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        ]
        
        // Request authorization
        healthStore?.requestAuthorization(
            toShare: healthKitTypesToWrite, read: nil, completion: completion)
    }
    
    /// Creates a mindful session with start and end dates
    /// - Parameters:
    ///   - startDate: Start date of the session
    ///   - endDate: End date of the session
    /// - Returns: A HealthKit sample representing the mindful session
    func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample {
        // Define the mindful session type
        let mindfulSessionType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        
        // Create a mindful session instance
        let mindfulSessionInstance = HKCategorySample(
            type: mindfulSessionType, value: 0, start: startDate, end: endDate)
        
        return mindfulSessionInstance
    }
    
    /// Saves a mindful session to HealthKit
    /// - Parameters:
    ///   - mindfulSession: The session to save
    ///   - completion: Closure called when save operation completes
    func saveMindfulSession(
        mindfulSession: HKCategorySample, completion: @escaping (Bool, Error?) -> Void
    ) {
        healthStore?.save(mindfulSession, withCompletion: completion)
    }
} 