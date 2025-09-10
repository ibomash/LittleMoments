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

