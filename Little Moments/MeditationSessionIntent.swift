import AppIntents
import SwiftUI

struct MeditationSessionIntent: AppIntent {
  static var title: LocalizedStringResource = "Start Meditation Session"

  func perform() async throws -> some IntentResult {
    return await .result(dialog: "Starting meditation session...", view: TimerRunningView())
  }
}
