// Compile this Control Center widget only when the SDK provides ControlCenter
#if canImport(ControlCenter)
import AppIntents
import SwiftUI
import WidgetKit
import ControlCenter

@available(iOS 18.0, *)
struct MeditationControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    ControlWidgetConfiguration(kind: "MeditationControl") {
      Control("Start Meditation", systemImage: "brain.head.profile") {
        try await MeditationSessionIntent().perform()
      }
    }
  }
}

// Fallback for environments without the ControlCenter SDK
#endif
