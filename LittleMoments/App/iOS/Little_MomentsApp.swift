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
    guard url.scheme == "littlemoments" else { 
      print("❌ Deep link ignored - wrong scheme: \(url.scheme ?? "nil")")
      return 
    }
    
    if url.host == "finishSession" {
      print("📲 Processing finishSession deep link")
      // Complete the current session if there is one active
      if appState.showTimerRunningView {
        print("📲 Timer is active - preparing to finish session via deep link")
        // First try to get an active timer view model to prepare the session
        // This ensures we capture the startDate before we close the view
        if let activeTimerVC = getActiveTimerViewController(),
           let timerRunningView = findTimerRunningView(in: activeTimerVC) {
          // Access the timer view model directly
          timerRunningView.timerViewModel.prepareSessionForFinish()
          print("📲 Found active timer view model - preserving session data")
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
    } else if url.host == "cancelSession" {
      print("📲 Processing cancelSession deep link")
      // Cancel the current session if there is one active
      if appState.showTimerRunningView {
        // First try to get an active timer view model to mark session as cancelled
        if let activeTimerVC = getActiveTimerViewController(),
           let timerRunningView = findTimerRunningView(in: activeTimerVC) {
          // Access the timer view model directly and mark as not to be saved
          timerRunningView.timerViewModel.shouldSaveSession = false
          print("📲 Found active timer view model - marked session to not save to health")
        }
        
        // Post a notification to cancel the session
        // Other components will observe this notification
        print("📲 Posting cancelSession notification")
        NotificationCenter.default.post(
          name: Notification.Name("com.littlemoments.cancelSession"),
          object: nil
        )
        
        // Close the timer view
        print("📲 Closing timer view")
        appState.showTimerRunningView = false
      } else {
        print("⚠️ Received cancelSession deep link, but no active timer session found")
      }
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
