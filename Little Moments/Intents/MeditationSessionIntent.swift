import SwiftUI
import AppIntents

struct MeditationSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Meditation Session"

    func perform() async throws -> some IntentResult {
        return .result(dialog: "Starting meditation session...", view: TimerRunningView())
    }
}
