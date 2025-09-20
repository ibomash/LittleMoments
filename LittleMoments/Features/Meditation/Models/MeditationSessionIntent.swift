import AppIntents
import SwiftUI

public struct MeditationSessionIntent: AppIntent {
  public init() {}
  public static var title: LocalizedStringResource { "Start Meditation Session" }
  public static let description = IntentDescription(
    "Start a meditation session",
    categoryName: "Meditation",
    searchKeywords: [
      "meditate", "meditation", "mindfulness", "breathe", "breathing",
      "timer", "untimed", "bells", "focus",
    ]
  )

  @Parameter(title: "Duration", description: "Optional duration in minutes")
  public var durationMinutes: Int?

  public static var parameterSummary: some ParameterSummary {
    When(\.$durationMinutes, .hasNoValue) {
      Summary("Start an untimed meditation")
    } otherwise: {
      Summary("Start a meditation for \(\.$durationMinutes) minutes")
    }
  }

  @MainActor
  public func perform() async throws -> some IntentResult {
    if let durationMinutes {
      AppState.shared.pendingStartDurationSeconds = durationMinutes * 60
    }
    AppState.shared.showTimerRunningView = true
    return .result()
  }

  public static var openAppWhenRun: Bool { true }
}
