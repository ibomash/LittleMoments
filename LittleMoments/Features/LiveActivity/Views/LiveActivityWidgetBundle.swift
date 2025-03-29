import ActivityKit
import SwiftUI
import WidgetKit

struct MeditationWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    MeditationLiveActivityWidget()
  }
}

struct MeditationLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: MeditationLiveActivityAttributes.self) { context in
      MeditationLiveActivityView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded UI
        DynamicIslandExpandedRegion(.leading) {
          Label {
            Text(timerDisplayFromSeconds(context.state.secondsElapsed))
              .monospacedDigit()
              .font(.title2)
          } icon: {
            Image(systemName: "timer")
          }
          .padding(.leading)
        }

        DynamicIslandExpandedRegion(.trailing) {
          if let targetTime = context.state.targetTimeInSeconds {
            ProgressView(value: min(context.state.secondsElapsed / targetTime, 1.0))
              .progressViewStyle(.circular)
              .frame(width: 40, height: 40)
              .padding(.trailing)
          }
        }

        DynamicIslandExpandedRegion(.bottom) {
          Button("End Session") {
            // Will be handled via deep link
          }
          .buttonStyle(.bordered)
          .tint(.blue)
        }
      } compactLeading: {
        Image(systemName: "timer")
      } compactTrailing: {
        Text(timerDisplayFromSeconds(context.state.secondsElapsed))
          .monospacedDigit()
          .font(.caption2)
      } minimal: {
        Image(systemName: "timer")
      }
    }
  }

  private func timerDisplayFromSeconds(_ seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let secs = totalSeconds % 60

    return String(format: "%d:%02d", minutes, secs)
  }
}
