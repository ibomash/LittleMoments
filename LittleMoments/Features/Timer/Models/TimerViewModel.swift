//
//  TimerViewModel.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import Foundation
import SwiftUI
import UIKit
import ActivityKit

class TimerViewModel: ObservableObject {
  // Components of the TimerViewModel:
  // - A running timer. The timer is always running, but it might have been canceled as it's shutting down.
  // - A set of options for scheduled "end time" alerts.
  // - One optional scheduled "end time" alert.
  // - One optional "interval" bell manager (future state).

  @ObservedObject var settings: JustNowSettings = JustNowSettings.shared

  // Flag to indicate if session should be saved to HealthKit when it ends
  @Published var shouldSaveSession: Bool = false
  
  // Running timer
  private var startDate: Date?
  var timer: Timer?
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
  @Published var scheduledAlert: OneTimeScheduledBellAlert? {
    didSet {
      // Update Live Activity when timer duration changes
      if JustNowSettings.shared.enableLiveActivities {
        let targetSeconds = scheduledAlert?.targetTimeInSec != nil ? Double(scheduledAlert!.targetTimeInSec) : nil
        print("Updating live activity with new target seconds: \(targetSeconds ?? 0)")
        // We need to update the Live Activity with the new target time
        LiveActivityManager.shared.updateActivity(
          secondsElapsed: secondsElapsed,
          targetTimeInSeconds: targetSeconds
        )
      }
    }
  }

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

  // Add this property to store the startDate when a session is finishing
  private var sessionStartDateForFinish: Date?

  func writeToHealthStore() {
    if !JustNowSettings.shared.writeToHealth {
      print("Health integration disabled - skipping health store write")
      return
    }

    // First try using the stored session start date (used when finishing from Live Activity)
    let sessionStartDate = sessionStartDateForFinish ?? startDate
    
    guard let sessionStartDate else {
      print("Error: Cannot write to health store - startDate is nil")
      return
    }
    let endDate = Date()
    
    print("Writing to HealthKit - session from \(sessionStartDate) to \(endDate) (\(secondsElapsed) seconds)")

    // Create a new mindful session
    guard
      let mindfulSession = HealthKitManager.shared.createMindfulSession(
        startDate: sessionStartDate, endDate: endDate)
    else {
      print("Error: Failed to create mindful session")
      return
    }

    // Save the session to HealthKit
    HealthKitManager.shared.saveMindfulSession(mindfulSession: mindfulSession) {
      [weak self] success, error in
      guard let self = self else { return }
      
      if success {
        print("✅ Health integration - Mindful session of \(self.secondsElapsed) seconds saved successfully")
      } else {
        print("❌ Health integration - Failed to save mindful session: \(error?.localizedDescription ?? "Unknown error")")
      }
      
      // Clear the stored session start date after saving
      self.sessionStartDateForFinish = nil
    }
  }

  // Add a function to safely store the start date before finishing
  func prepareSessionForFinish() {
    print("Preparing session for finish - storing startDate for health store")
    // Always mark that this session should be saved
    shouldSaveSession = true
    print("📱 TimerViewModel.prepareSessionForFinish - Setting shouldSaveSession to true")
    
    // Store the current startDate for Health integration
    if sessionStartDateForFinish == nil {
      sessionStartDateForFinish = startDate
      if let startDate = startDate {
        print("Session start date preserved: \(startDate)")
      } else {
        print("Warning: No start date to preserve")
      }
    }
  }

  // Live Activity functions
  func startLiveActivity() {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    let targetSeconds = scheduledAlert?.targetTimeInSec != nil ? Double(scheduledAlert!.targetTimeInSec) : nil
    print("Starting live activity with target seconds: \(targetSeconds ?? 0)")
    LiveActivityManager.shared.startActivity(
      sessionName: "Meditation",
      targetTimeInSeconds: targetSeconds
    )
  }
  
  func updateLiveActivity() {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    // Don't update if the timer has been reset
    guard timer != nil else { return }
    
    LiveActivityManager.shared.updateActivity(secondsElapsed: secondsElapsed)
  }
  
  func endLiveActivity(completed: Bool = true) {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    if completed {
      // Mark that we should save this session to HealthKit
      print("📱 TimerViewModel.endLiveActivity - Setting shouldSaveSession to true for completed session")
      shouldSaveSession = true
      
      LiveActivityManager.shared.updateActivity(
        secondsElapsed: secondsElapsed,
        isCompleted: true
      )
    } else {
      // If cancelling, make sure we don't save to HealthKit
      print("📱 TimerViewModel.endLiveActivity - Setting shouldSaveSession to false for cancelled session")
      shouldSaveSession = false
    }
    
    LiveActivityManager.shared.endActivity()
  }

  // LiveActivity notification observers
  private var finishObserver: NSObjectProtocol?
  private var cancelObserver: NSObjectProtocol?

  init() {
    // Initialize scheduledAlertOptions with default values
    self.scheduledAlertOptions = [
      OneTimeScheduledBellAlert(targetTimeInMin: 1),
      OneTimeScheduledBellAlert(targetTimeInMin: 5),
      OneTimeScheduledBellAlert(targetTimeInMin: 10),
      OneTimeScheduledBellAlert(targetTimeInMin: 15),
      OneTimeScheduledBellAlert(targetTimeInMin: 20),
      OneTimeScheduledBellAlert(targetTimeInMin: 30),
      OneTimeScheduledBellAlert(targetTimeInMin: 45),
      OneTimeScheduledBellAlert(targetTimeInMin: 60),
    ]
    
    #if targetEnvironment(simulator)
      // Add a short 5-second option for testing in simulator
      scheduledAlertOptions[0] = OneTimeScheduledBellAlert(targetTimeInSec: 5, name: "5 sec")
    #endif
    
    // Register for notifications from Live Activity
    setupNotificationObservers()
  }
  
  deinit {
    // Remove notification observers when deallocated
    if let finishObserver = finishObserver {
      NotificationCenter.default.removeObserver(finishObserver)
    }
    if let cancelObserver = cancelObserver {
      NotificationCenter.default.removeObserver(cancelObserver)
    }
  }
  
  private func setupNotificationObservers() {
    // Listen for finish notification
    finishObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("com.littlemoments.finishSession"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      
      print("📱 Received finishSession notification from Live Activity")
      // Store the start date for later use
      self.prepareSessionForFinish()
      
      // Explicitly ensure shouldSaveSession is set to true
      self.shouldSaveSession = true
      print("📱 Set shouldSaveSession to true from finishSession notification")
      
      // End the Live Activity
      self.endLiveActivity(completed: true)
      
      // Since onDisappear will handle writing to health store, we don't do it here
      // Just reset the timer
      self.reset()
    }
    
    // Listen for cancel notification
    cancelObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("com.littlemoments.cancelSession"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      print("📱 Received cancelSession notification from Live Activity")
      // Ensure session won't be saved to HealthKit
      self.shouldSaveSession = false
      self.endLiveActivity(completed: false)
      self.reset(resetSaveFlag: true)
    }
  }

  func reset(resetSaveFlag: Bool = false) {
    print("Timer reset - clearing timer state and canceling timer")
    timer?.invalidate()
    timer = nil
    startDate = nil
    
    // Only reset the save state if explicitly requested
    if resetSaveFlag {
      print("📱 TimerViewModel.reset - Resetting shouldSaveSession flag")
      shouldSaveSession = false
    }
    
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    UIApplication.shared.isIdleTimerDisabled = false
  }
}
