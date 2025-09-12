import AppIntents
import SwiftUI

struct MeditationSessionIntent: AppIntent {
  static var title: LocalizedStringResource { "Start Meditation Session" }

  @Parameter(title: "Duration", description: "Optional duration in minutes")
  var durationMinutes: Int?

  static var parameterSummary: some ParameterSummary {
    Summary("Start a session for \(\.$durationMinutes) minutes")
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    if let durationMinutes {
      AppState.shared.pendingStartDurationSeconds = durationMinutes * 60
    }
    AppState.shared.showTimerRunningView = true
    return .result()
  }

  static var openAppWhenRun: Bool { true }
}
