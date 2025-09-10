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
      intent: StartMeditationControlIntent.self
    ) { _ in
      // Use a Controls-specific button template that opens the deep link
      ControlWidgetButton(action: OpenURLIntent(URL(string: "littlemoments://startSession")!)) {
        Label("Start Meditation", systemImage: "play.fill")
      }
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
    // Open the app; the Control button itself performs the deep link
    return .result()
  }
}

#endif
