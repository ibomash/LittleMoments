//
//  StartTimerIntent.swift
//  Little Moments
//
//  Created by Illya Bomash on 6/14/23.
//

import AppIntents
import Foundation

struct StartTimer: AppIntent {
  static var title: LocalizedStringResource = "Start a moment"
  static var description = IntentDescription("Start a timer for a new mindfulness moment")

  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult & ReturnsValue {
    AppViewModel.shared.showTimerRunningView = true
    return .result()
  }

}
