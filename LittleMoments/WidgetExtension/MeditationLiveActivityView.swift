import ActivityKit
import SwiftUI
import WidgetKit

struct MeditationLiveActivityView: View {
  let context: ActivityViewContext<MeditationLiveActivityAttributes>
  @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

  @ViewBuilder
  var body: some View {
    let content = ZStack {
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

        // Use links instead of buttons for deep linking
        HStack(spacing: 12) {
          if let url = URL(string: "littlemoments://cancelSession") {
            Link(destination: url) {
              Text("Cancel")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.red)
            }
          }

          if let url = URL(string: "littlemoments://finishSession") {
            Link(destination: url) {
              Text("Finish")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.green)
            }
          }
        }
      }
      .padding()
    }

    if #available(iOS 17.0, *) {
      content
        .containerBackground(for: .widget) { Color.clear }
    } else {
      content
    }
  }

  private var timerDisplay: String {
    return timerDisplayFromSeconds(
      seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds)
  }
}
