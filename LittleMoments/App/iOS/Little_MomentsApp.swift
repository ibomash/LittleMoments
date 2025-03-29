//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

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
    guard url.scheme == "littlemoments" else { return }
    
    if url.host == "endSession" {
      // End the current session if there is one active
      if appState.showTimerRunningView, let timerViewModel = getActiveTimerViewModel() {
        timerViewModel.endLiveActivity()
        timerViewModel.writeToHealthStore()
        timerViewModel.reset()
        appState.showTimerRunningView = false
      }
    }
  }
  
  func getActiveTimerViewModel() -> TimerViewModel? {
    // In a real implementation, we would need to access the active TimerViewModel
    // This is a simplified version for demonstration
    // We might need to refactor the app to make the active TimerViewModel accessible
    return nil
  }
}
