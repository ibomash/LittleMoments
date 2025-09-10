// Control Center control to start a meditation session
// Guarded by availability as Controls API is iOS 18+
import SwiftUI
import WidgetKit
import AppIntents

#if swift(>=6.0)

@available(iOS 18.0, *)
struct StartMeditationControlWidget: ControlWidget {
  var body: some ControlWidgetConfiguration {
    AppIntentControlConfiguration(
      kind: "net.bomash.illya.LittleMoments.controls.startMeditation",
      intent: StartMeditationControlIntent()
    ) {
      Label("Start Meditation", systemImage: "play.circle.fill")
    }
    .displayName("Start Meditation")
    .description("Begin a quick meditation session")
  }
}

// A lightweight intent that opens the app and deep-links to start the session
@available(iOS 18.0, *)
struct StartMeditationControlIntent: AppIntent {
  static var title: LocalizedStringResource = "Start Meditation Session"
  static var openAppWhenRun: Bool = true

  @MainActor
  func perform() async throws -> some IntentResult {
    // Prefer to deep link so the app immediately shows TimerRunningView
    if let url = URL(string: "littlemoments://startSession") {
      // Returning a result that redirects to a URL hints the system to open this deep link
      // If unsupported, the app will still open due to openAppWhenRun
      return .result(redirectingTo: url)
    }
    return .result()
  }
}

#endif
