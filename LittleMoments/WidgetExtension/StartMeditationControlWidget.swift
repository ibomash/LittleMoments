// Control Center control to start a meditation session
// Guarded by availability as Controls API is iOS 18+
import SwiftUI
import WidgetKit
import AppIntents

#if swift(>=6.0) && false // Temporarily disabled pending proper Controls API implementation

@available(iOS 18.0, *)
struct StartMeditationControlWidget: ControlWidget {
  var body: some ControlWidgetConfiguration {
    AppIntentControlConfiguration(
      kind: "net.bomash.illya.LittleMoments.controls.startMeditation",
      intent: StartMeditationControlIntent.self
    ) { _ in
      Label("Start Meditation", systemImage: "play.circle.fill")
    }
    .displayName("Start Meditation")
    .description("Begin a quick meditation session")
  }
}

// A lightweight intent that opens the app and deep-links to start the session
@available(iOS 18.0, *)
struct StartMeditationControlIntent: ControlConfigurationIntent {
  static var title: LocalizedStringResource { "Start Meditation Session" }
  static var openAppWhenRun: Bool { true }

  @MainActor
  func perform() async throws -> some IntentResult {
    // Prefer to deep link so the app immediately shows TimerRunningView
    // Open the app; deep link handled by openURL from Control routing when available
    return .result()
  }
}

#endif
