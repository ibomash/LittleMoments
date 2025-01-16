import AppIntents
import SwiftUI

struct MeditationSessionIntent: AppIntent {
  static var title: LocalizedStringResource = "Start Meditation Session"

  @MainActor
  func perform() async throws -> some IntentResult {
    AppState.shared.showTimerRunningView = true
    return await .result()
  }

  static var openAppWhenRun: Bool = true
}
