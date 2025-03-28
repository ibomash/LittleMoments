//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

@main
struct LittleMomentsApp: App {
  init() {
    SoundManager.initialize()
  }

  var body: some Scene {
    WindowGroup {
      TimerStartView()
    }
  }

  func onExitCommand() {
    SoundManager.dispose()
  }
}
