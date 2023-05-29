//
//  TimerViewModel.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import Foundation
import UIKit

class TimerViewModel: ObservableObject {
  @Published var timeElapsedFormatted: String = "0:00"
  var startDate: Date? = nil
  var scheduledAlert: ScheduledAlert?
  var timer: Timer? = nil
  var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  var secondsElapsed: Int {
    guard let startDate else { return 0 }
    return Int(-startDate.timeIntervalSinceNow)
  }

  var hasEndTarget: Bool {
    if let scheduledAlert { return scheduledAlert.hasTarget } else { return false }
  }

  var progress: CGFloat {
    if !hasEndTarget {
      return 0.0
    }
    return scheduledAlert?.getProgress(numSecondsElapsed: secondsElapsed) ?? 0.0
  }

  func getTimeElapsedFormatted() -> String {
    let minutes = secondsElapsed / 60
    let seconds = secondsElapsed % 60
    return String(format: "%d:%02d", minutes, seconds)
  }

  func start() {
    timer?.invalidate()
    startDate = Date()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      if let self {
        self.scheduledAlert?.checkTrigger(numSecondsElapsed: self.secondsElapsed)
        self.timeElapsedFormatted = self.getTimeElapsedFormatted()
      }
    }
    self.backgroundTask = UIApplication.shared.beginBackgroundTask(
      withName: "Timer Background Task"
    ) {
      UIApplication.shared.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
  }

  func reset() {
    timer?.invalidate()
    timer = nil
    startDate = nil
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
  }

  func writeToHealthStore() {
    guard let startDate else { return }
    let endDate = Date()

    // Create a new mindful session
    let mindfulSession = HealthKitManager.shared.createMindfulSession(
      startDate: startDate, endDate: endDate)

    // Save the session to HealthKit
    HealthKitManager.shared.saveMindfulSession(mindfulSession: mindfulSession) {
      [self] (success, error) in
      if success {
        print("Mindful session of \(secondsElapsed) seconds saved successfully: \(mindfulSession)")
      } else {
        print("Failed to save mindful session: ", error?.localizedDescription ?? "Unknown error")
      }
    }
  }
}
