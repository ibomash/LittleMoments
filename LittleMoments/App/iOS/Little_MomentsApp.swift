//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI
import UIKit
import ActivityKit

// Keep track of the active timer view model for deep link handling
private var activeTimerViewModel: Any? = nil
// Global flag to track if a session was recently canceled, to prevent race conditions
private var sessionWasRecentlyCanceled = false
private var lastCancelationTime: Date?

@main
struct LittleMomentsApp: App {
  @StateObject private var appState = AppState.shared
  
  init() {
    SoundManager.initialize()
  }

  var body: some Scene {
    WindowGroup {
      TimerStartView()
        .onOpenURL { url in
          handleDeepLink(url: url)
        }
    }
  }

  func onExitCommand() {
    SoundManager.dispose()
  }
  
  func handleDeepLink(url: URL) {
    print("📲 Received deep link: \(url)")
    print("📲 URL scheme: \(url.scheme ?? "nil"), host: \(url.host ?? "nil"), path: \(url.path)")
    
    guard url.scheme == "littlemoments" else { 
      print("❌ Deep link ignored - wrong scheme: \(url.scheme ?? "nil")")
      return 
    }
    
    if url.host == "finishSession" {
      print("📲 Processing finishSession deep link")
      
      // Check if we've recently received a cancel notification
      if sessionWasRecentlyCanceled {
        print("⛔️ BLOCKED finishSession - session was recently canceled")
        
        // Extra protection: Check timestamp if available
        if let lastCancel = lastCancelationTime {
          let timeGap = Date().timeIntervalSince(lastCancel)
          print("⛔️ Cancel happened \(String(format: "%.2f", timeGap)) seconds ago")
        }
        
        // Still close the view if needed
        if appState.showTimerRunningView {
          print("📲 Closing timer view (but NOT saving to HealthKit)")
          appState.showTimerRunningView = false
        }
        
        return
      }
      
      // Complete the current session if there is one active
      if appState.showTimerRunningView {
        print("📲 Timer is active - preparing to finish session via deep link")
        // First try to get an active timer view model to prepare the session
        // This ensures we capture the startDate before we close the view
        if let activeTimerVC = getActiveTimerViewController(),
           let timerRunningView = findTimerRunningView(in: activeTimerVC) {
          // Access the timer view model directly
          timerRunningView.timerViewModel.prepareSessionForFinish()
          
          // Write to HealthKit directly
          print("📲 Writing to HealthKit from deep link")
          timerRunningView.timerViewModel.writeToHealthStore()
          
          // Provide haptic feedback for successful session completion
          print("📲 Providing haptic feedback for session completion")
          LiveActivityManager.shared.provideSessionCompletionFeedback()
          
          print("📲 Found active timer view model - session data saved")
        } else {
          print("⚠️ Could not access timer view model directly - will try via notification")
        }
        
        // Post a notification to finish the session
        // Other components will observe this notification
        print("📲 Posting finishSession notification")
        NotificationCenter.default.post(
          name: Notification.Name("com.littlemoments.finishSession"),
          object: nil
        )
        
        // Close the timer view
        print("📲 Closing timer view")
        appState.showTimerRunningView = false
      } else {
        print("⚠️ Received finishSession deep link, but no active timer session found")
      }
    } else if url.host == "cancelSession" || url.host == "cancel" || url.path == "/cancel" {
      print("📲 Processing cancel request from Live Activity")
      // Cancel the current session if there is one active
      if appState.showTimerRunningView {
        // Set the global cancellation flag
        sessionWasRecentlyCanceled = true
        lastCancelationTime = Date()
        
        // For cancellation, we want to make sure we don't accidentally save to HealthKit
        // Post a notification that will be observed by the timer view model
        print("📲 Posting cancelSession notification")
        NotificationCenter.default.post(
          name: Notification.Name("com.littlemoments.cancelSession"),
          object: nil
        )
        
        // Close the timer view
        print("📲 Closing timer view (session will NOT be saved to HealthKit)")
        appState.showTimerRunningView = false
        
        // Reset the cancel flag after a delay (as a safety measure)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
          sessionWasRecentlyCanceled = false
        }
      } else {
        print("⚠️ Received cancel request, but no active timer session found")
      }
    } else if url.host == "startSession" || url.host == "start" || url.path == "/start" {
      print("📲 Processing startSession deep link")
      // Present the running timer view immediately
      appState.showTimerRunningView = true
    } else {
      print("❌ Unknown deep link host: \(url.host ?? "nil")")
    }
  }
  
  // Helper method to find the active timer view controller
  func getActiveTimerViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      return nil
    }
    
    // Check for presented view controller
    if let presentedVC = rootViewController.presentedViewController {
      return presentedVC
    }
    
    return nil
  }
  
  // Helper method to find TimerRunningView in a view controller's view hierarchy
  func findTimerRunningView(in viewController: UIViewController) -> TimerRunningView? {
    // This is a simplification since we can't directly inspect SwiftUI view hierarchy
    // In a real implementation, we would need a more robust approach
    // that might involve a shared state object or other architectural patterns
    return nil
  }
}
