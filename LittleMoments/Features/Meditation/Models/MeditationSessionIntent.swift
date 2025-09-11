import AppIntents
import SwiftUI

struct MeditationSessionIntent: AppIntent {
  static var title: LocalizedStringResource { "Start Meditation Session" }

  @Parameter(title: "Duration", description: "Optional duration in seconds")
  var durationSeconds: Int?

  static var parameterSummary: some ParameterSummary {
    Summary("Start a session for \(\.$durationSeconds)")
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    if let durationSeconds {
      AppState.shared.pendingStartDurationSeconds = durationSeconds
    }
    AppState.shared.showTimerRunningView = true
    return .result()
  }

  static var openAppWhenRun: Bool { true }
}
