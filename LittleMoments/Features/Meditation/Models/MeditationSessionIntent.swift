import AppIntents
import SwiftUI

struct MeditationSessionIntent: AppIntent {
  static var title: LocalizedStringResource { "Start Meditation Session" }
  static var description = IntentDescription(
    "Start a meditation session",
    categoryName: "Meditation",
    searchKeywords: [
      "meditate", "meditation", "mindfulness", "breathe", "breathing",
      "timer", "untimed", "bells", "focus"
    ]
  )

  @Parameter(title: "Duration", description: "Optional duration in minutes")
  var durationMinutes: Int?

  static var parameterSummary: some ParameterSummary {
    When(\.$durationMinutes, .hasNoValue) {
      Summary("Start an untimed meditation")
    } otherwise: {
      Summary("Start a meditation for \(\.$durationMinutes) minutes")
    }
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
