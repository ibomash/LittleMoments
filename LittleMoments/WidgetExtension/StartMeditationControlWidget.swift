import AppIntents
import OSLog
// Control Center control to start a meditation session
// Guarded by availability as Controls API is iOS 18+
import SwiftUI
import WidgetKit

#if swift(>=6.0)

  @available(iOS 18.0, *)
  private let controlsLogger = Logger(
    subsystem: "net.bomash.illya.LittleMoments", category: "Controls")

  @available(iOS 18.0, *)
  struct StartMeditationControlWidget: ControlWidget {
    init() {
      controlsLogger.debug("StartMeditationControlWidget init")
    }
    var body: some ControlWidgetConfiguration {
      AppIntentControlConfiguration(
        kind: "net.bomash.illya.LittleMoments.controls.startMeditation",
        intent: StartMeditationControlIntent.self
      ) { _ in
        ControlWidgetButton(action: StartMeditationOpenIntent()) {
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
      controlsLogger.notice(
        "StartMeditationControlIntent.perform invoked - will open app (openAppWhenRun=true)")
      // Note: The ControlWidgetButton handles deep linking via OpenURLIntent.
      // The configuration intent opens the app when the tile is tapped anywhere.
      // Open the app; the Control button itself performs the deep link
      return .result()
    }
  }

#endif
