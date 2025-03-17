//
//  TimerViewModel.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

// Add import for JustNowSettings
import Foundation
import SwiftUI
import UIKit

class TimerViewModel: ObservableObject {
  // Components of the TimerViewModel:
  // - A running timer. The timer is always running, but it might have been canceled as it's shutting down.
  // - A set of options for scheduled "end time" alerts.
  // - One optional scheduled "end time" alert.
  // - One optional "interval" bell manager (future state).

  @ObservedObject var settings: JustNowSettings = JustNowSettings.shared

  // Running timer
  private var startDate: Date? = nil
  var timer: Timer? = nil
  var backgroundTask: UIBackgroundTaskIdentifier = .invalid
  var timeElapsedFormatted: String {
    return getTimeElapsedFormatted()
  }

  var secondsElapsed: CGFloat {
    guard let startDate else { return 0 }
    return -startDate.timeIntervalSinceNow
  }

  // Options for and actually scheduled "end time" alert
  @Published var scheduledAlertOptions: [OneTimeScheduledBellAlert]
  @Published var scheduledAlert: OneTimeScheduledBellAlert?

  var hasEndTarget: Bool {
    if let scheduledAlert { return scheduledAlert.hasTarget } else { return false }
  }

  var isDone: Bool {
    if !hasEndTarget {
      return false
    }
    return scheduledAlert?.isDone(secondsElapsed: secondsElapsed) ?? false
  }

  var progress: CGFloat {
    if !hasEndTarget {
      return 0.0
    }
    return scheduledAlert?.getProgress(secondsElapsed: secondsElapsed) ?? 0.0
  }

  func getTimeElapsedFormatted() -> String {
    let fullSecondsElapsed = Int(secondsElapsed)
    let minutes = fullSecondsElapsed / 60
    let seconds = fullSecondsElapsed % 60

    if settings.showSeconds {
      return String(format: "%d:%02d", minutes, seconds)
    } else {
      return String(format: "%d", minutes)
    }
  }

  func start() {
    timer?.invalidate()
    startDate = Date()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      if let self {
        self.scheduledAlert?.checkTrigger(secondsElapsed: self.secondsElapsed)
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
    if !JustNowSettings.shared.writeToHealth {
      return
    }

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

  init() {
    scheduledAlertOptions = [3, 5, 10, 15, 20, 25, 30, 45].map({
      OneTimeScheduledBellAlert(targetTimeInMin: $0)
    })
    #if targetEnvironment(simulator)
      scheduledAlertOptions[0] = OneTimeScheduledBellAlert(targetTimeInSec: 5, name: "5 sec")
    #endif
  }
}
