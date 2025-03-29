//
//  HealthKitManager.swift
//  Just Now
//
//  Created by Illya Bomash on 5/12/23.
//

// import Foundation
import HealthKit

class HealthKitManager {

  static let shared = HealthKitManager()

  private var healthStore: HKHealthStore?

  private init() {
    if HKHealthStore.isHealthDataAvailable() {
      healthStore = HKHealthStore()
    }
  }

  // Request Authorization
  func requestAuthorization(completion: @escaping (Bool, Error?) -> Swift.Void) {
    // Define the data types that the app needs access to
    guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
      print("Error: Failed to create mindful session category type for authorization")
      completion(false, nil)
      return
    }
    
    let healthKitTypesToWrite: Set<HKSampleType> = [mindfulType]

    // Request authorization
    healthStore?.requestAuthorization(
      toShare: healthKitTypesToWrite, read: nil, completion: completion)
  }

  // Create a Mindful Session with start and end date
  func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample? {
    // Define the mindful session type
    guard let mindfulSessionType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
      print("Error: Failed to create mindful session category type")
      return nil
    }

    // Create a mindful session instance
    let mindfulSessionInstance = HKCategorySample(
      type: mindfulSessionType, value: 0, start: startDate, end: endDate)

    return mindfulSessionInstance
  }

  // Save a Mindful Session to HealthKit
  func saveMindfulSession(
    mindfulSession: HKCategorySample, completion: @escaping (Bool, Error?) -> Swift.Void
  ) {
    healthStore?.save(mindfulSession, withCompletion: completion)
  }
}
