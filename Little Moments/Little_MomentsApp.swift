//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

class AppViewModel: ObservableObject {

  static let shared = AppViewModel()

  @Published var showTimerRunningView: Bool = false
  @Published var showSettingsView: Bool = false

}

@main
struct Little_MomentsApp: App {
  @StateObject var vm = AppViewModel.shared

  init() {
    SoundManager.initialize()
  }

  var body: some Scene {
    WindowGroup {
      TimerStartView()
        .environmentObject(vm)
    }
  }

  func onExitCommand() {
    SoundManager.dispose()
  }
}
