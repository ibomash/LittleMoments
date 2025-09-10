import AppIntents
import OSLog

// Shim for the widget extension so the type exists in both targets.
// The system will execute this intent in the app process when opening
// due to `openAppWhenRun = true`. The extension version does not touch UI.
@available(iOS 18.0, *)
struct StartMeditationOpenIntent: AppIntent {
  static var title: LocalizedStringResource { "Start Meditation" }
  static var openAppWhenRun: Bool { true }

  func perform() async throws -> some IntentResult {
    Logger(subsystem: "net.bomash.illya.LittleMoments", category: "Controls")
      .debug("StartMeditationOpenIntent.perform (extension shim) invoked")
    return .result()
  }
}
