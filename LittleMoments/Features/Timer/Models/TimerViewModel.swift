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

@MainActor
class TimerViewModel: ObservableObject {
  // Components of the TimerViewModel:
  // - A running timer. The timer is always running, but it might have been canceled as it's shutting down.
  // - A set of options for scheduled "end time" alerts.
  // - One optional scheduled "end time" alert.
  // - One optional "interval" bell manager (future state).

  @ObservedObject var settings: JustNowSettings = JustNowSettings.shared

  // Flag to track if session was cancelled via notification
  private var wasCancelled = false
  // Timestamp of the last cancelSession notification
  private var lastCancelTime: Date?

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
        Task { await LiveActivityManager.shared.updateActivity(
          secondsElapsed: secondsElapsed,
          targetTimeInSeconds: targetSeconds
        )}
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
      Task { @MainActor in
        guard let self else { return }
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

    // Check if session was cancelled
    if wasCancelled {
      print("❌❌❌ BLOCKED HEALTH WRITE - Session was cancelled")
      if let lastCancelTime = lastCancelTime {
        print("❌❌❌ Last cancellation was at \(lastCancelTime)")
      }
      return
    }
    
    // First try using the stored session start date (used when finishing from Live Activity)
    let sessionStartDate = sessionStartDateForFinish ?? startDate
    
    guard let sessionStartDate else {
      print("Error: Cannot write to health store - startDate is nil")
      return
    }
    let endDate = Date()
    
    print("Writing to HealthKit - session from \(sessionStartDate) to \(endDate) (duration: \(endDate.timeIntervalSince(sessionStartDate)) seconds)")

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
      Task { @MainActor in
        guard let self = self else { return }
        
        if success {
          let sessionDuration = endDate.timeIntervalSince(sessionStartDate)
          print("✅ Health integration - Mindful session of \(Int(sessionDuration)) seconds saved successfully")
        } else {
          print("❌ Health integration - Failed to save mindful session: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        // Clear the stored session start date after saving
        self.sessionStartDateForFinish = nil
      }
    }
  }

  // Add a function to safely store the start date before finishing
  func prepareSessionForFinish() {
    print("Preparing session for finish - storing startDate for health store")
    
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
    
    Task { await LiveActivityManager.shared.updateActivity(secondsElapsed: secondsElapsed) }
  }
  
  func endLiveActivity(completed: Bool = true) {
    guard JustNowSettings.shared.enableLiveActivities else { return }
    
    if completed {
      Task { await LiveActivityManager.shared.updateActivity(
        secondsElapsed: secondsElapsed,
        isCompleted: true
      )}
    }
    
    Task { await LiveActivityManager.shared.endActivity() }
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
  
  // Note: Block-based observers are added with [weak self] and will be cleaned up with the object lifecycle.
  
  private func setupNotificationObservers() {
    print("📱 Setting up notification observers")
    
    // Listen for finish notification
    finishObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("com.littlemoments.finishSession"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        guard let self = self else { return }
        
        let now = Date()
        
        // Skip if this session was already cancelled
        if self.wasCancelled {
          print("📱 BLOCKED FINISH - Ignoring finishSession notification - session was already cancelled")
          return
        }
        
        // Check if a cancellation happened within the last 2 seconds (race condition protection)
        if let lastCancel = self.lastCancelTime, now.timeIntervalSince(lastCancel) < 5.0 {
          print("📱 BLOCKED FINISH - Ignoring finishSession notification - cancelSession was received within the last 5 seconds")
          print("📱 Time since cancel: \(String(format: "%.2f", now.timeIntervalSince(lastCancel))) seconds")
          return
        }
        
        print("📱 Received finishSession notification from Live Activity")
        print("📱 Current wasCancelled state: \(self.wasCancelled)")
        if let lastCancelTime = self.lastCancelTime {
          print("📱 Last cancel time: \(lastCancelTime), time since: \(String(format: "%.2f", now.timeIntervalSince(lastCancelTime))) seconds")
        }
        
        // Store the start date for later use
        self.prepareSessionForFinish()
        
        // Write to HealthKit directly
        print("📱 Writing to HealthKit from finishSession notification")
        self.writeToHealthStore()
        
        // Provide haptic feedback for successful session completion
        print("📱 Providing haptic feedback for session completion")
        LiveActivityManager.shared.provideSessionCompletionFeedback()
        
        // End the Live Activity
        self.endLiveActivity(completed: true)
        
        // Reset the timer
        self.reset()
      }
    }
    
    // Listen for cancel notification
    cancelObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name("com.littlemoments.cancelSession"),
      object: nil,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        guard let self = self else { return }
        print("📱 Received cancelSession notification from Live Activity")
        
        // Mark session as cancelled and record the time
        self.wasCancelled = true
        self.lastCancelTime = Date()
        print("📱 CANCEL TRIGGERED - Setting wasCancelled to true to block any finishSession notifications")
        print("📱 Marked session as cancelled at \(self.lastCancelTime!) to prevent health write")
        
        // For cancel, just end Live Activity and reset - no HealthKit write
        self.endLiveActivity(completed: false)
        self.reset()
      }
    }
  }

  func reset() {
    print("Timer reset - clearing timer state and canceling timer")
    timer?.invalidate()
    timer = nil
    startDate = nil
    
    // Reset the cancelled flag and timestamp for future sessions
    wasCancelled = false
    lastCancelTime = nil
    
    if backgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    UIApplication.shared.isIdleTimerDisabled = false
  }
}
