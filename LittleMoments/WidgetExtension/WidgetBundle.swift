import ActivityKit
import SwiftUI
import WidgetKit

@main
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
            Text(timerDisplayFromSeconds(seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds))
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
          HStack(spacing: 12) {
            // Complete session link
            Link(destination: URL(string: "littlemoments://finishSession")!) {
              Label("Complete", systemImage: "checkmark.circle.fill")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.green)
            }
            
            // Cancel session link
            Link(destination: URL(string: "littlemoments://cancelSession")!) {
              Label("Cancel", systemImage: "xmark.circle.fill")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.red)
            }
          }
          .padding(.horizontal)
        }
      } compactLeading: {
        Image(systemName: "timer")
      } compactTrailing: {
        Text(timerDisplayFromSeconds(seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds))
          .monospacedDigit()
          .font(.caption2)
      } minimal: {
        Image(systemName: "timer")
      }
    }
  }

  private func timerDisplayFromSeconds(seconds: Double, showSeconds: Bool) -> String {
    let totalSeconds = Int(seconds)
    let minutes = totalSeconds / 60
    let secs = totalSeconds % 60

    if showSeconds {
      return String(format: "%d:%02d", minutes, secs)
    } else {
      return String(format: "%d", minutes)
    }
  }
} 