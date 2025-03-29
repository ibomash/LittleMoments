import ActivityKit
import SwiftUI
import WidgetKit

struct MeditationLiveActivityView: View {
  let context: ActivityViewContext<MeditationLiveActivityAttributes>
  @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

  var body: some View {
    ZStack {
      ContainerRelativeShape()
        .fill(showsWidgetBackground ? .clear : .black.opacity(0.1))

      VStack {
        Text("Meditation in progress")
          .font(.headline)

        HStack(spacing: 16) {
          // Timer display
          VStack {
            Text(timerDisplay)
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .monospacedDigit()
              .minimumScaleFactor(0.5)
          }

          // Progress bar (for timed sessions)
          if let targetTime = context.state.targetTimeInSeconds, targetTime > 0 {
            ProgressView(value: min(context.state.secondsElapsed / targetTime, 1.0))
              .progressViewStyle(.circular)
              .frame(width: 40, height: 40)
          }
        }
        .padding(.vertical, 4)

        // End session button
        Button("End Session") {
          // This will be handled by deeplink
        }
        .buttonStyle(.bordered)
        .tint(.blue)
        .widgetURL(URL(string: "littlemoments://endSession"))
      }
      .padding()
    }
  }

  private var timerDisplay: String {
    let totalSeconds = Int(context.state.secondsElapsed)
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60

    return String(format: "%d:%02d", minutes, seconds)
  }
} 