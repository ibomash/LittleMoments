import AppIntents
import OSLog

// Open intent used by Control Center to foreground the app
// and present the running timer. Lives in the app target.
@available(iOS 18.0, *)
struct StartMeditationOpenIntent: AppIntent {
  static var title: LocalizedStringResource { "Start Meditation" }
  static var openAppWhenRun: Bool { true }
  // Hide this Control/Widget-focused intent from Shortcuts to avoid duplicates
  static var isDiscoverable: Bool { false }

  @MainActor
  func perform() async throws -> some IntentResult {
    Logger(subsystem: "net.bomash.illya.LittleMoments", category: "Controls")
      .notice("StartMeditationOpenIntent.perform (app) invoked — showing timer")
    // Drive UI in the app process
    AppState.shared.showTimerRunningView = true
    return .result()
  }
}
