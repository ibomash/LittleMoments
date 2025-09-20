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

        // Replace single button with two buttons
        HStack(spacing: 12) {
          Button("Cancel") {
            // This will be handled by deeplink
          }
          .buttonStyle(.bordered)
          .tint(.red)
          .widgetURL(URL(string: "littlemoments://cancelSession"))

          Button("Finish") {
            // This will be handled by deeplink
          }
          .buttonStyle(.bordered)
          .tint(.green)
          .widgetURL(URL(string: "littlemoments://finishSession"))
        }
      }
      .padding()
    }
  }

  private var timerDisplay: String {
    return timerDisplayFromSeconds(
      seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds)
  }
}
