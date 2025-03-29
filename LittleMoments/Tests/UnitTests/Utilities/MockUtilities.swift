import AVFoundation
import Foundation
import HealthKit

@testable import LittleMoments

/// Mock implementation of AVAudioPlayer for testing
class MockAVAudioPlayer: PlaybackDelegate {
  var playWasCalled = false
  var stopWasCalled = false

  func play() -> Bool {
    playWasCalled = true
    return true
  }

  func stop() {
    stopWasCalled = true
  }
}

/// Mock implementation of HealthKitManager for testing
class MockHealthKitManager {
  var saveWasCalled = false
  var requestAuthorizationWasCalled = false
  var lastSavedSession: HKCategorySample?

  init() {
    // No need to call super.init() since we're not inheriting
  }

  func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample {
    let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
    return HKCategorySample(type: mindfulType, value: 0, start: startDate, end: endDate)
  }

  func saveMindfulSession(
    startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void
  ) {
    saveWasCalled = true
    let session = createMindfulSession(startDate: startDate, endDate: endDate)
    lastSavedSession = session
    completion(true, nil)
  }

  func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
    requestAuthorizationWasCalled = true
    completion(true, nil)
  }
}

/// Utility for resetting UserDefaults between tests
class UserDefaultsReset {
  static func resetDefaults() {
    let keys = ["writeToHealth", "ringBellAtStart", "showSeconds"]
    keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
  }
}
