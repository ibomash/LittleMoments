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
            LiveActivityElapsedTimeView(state: context.state)
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .monospacedDigit()
              .minimumScaleFactor(0.5)
          }

          // Progress bar (for timed sessions)
          if context.state.targetTimeInSeconds != nil {
            LiveActivityProgressView(state: context.state)
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

}

struct LiveActivityElapsedTimeView: View {
  let state: MeditationLiveActivityAttributes.ContentState

  @ViewBuilder
  var body: some View {
    if state.isCompleted {
      Text(
        timerDisplayFromSeconds(
          seconds: state.secondsElapsed,
          showSeconds: state.showSeconds
        )
      )
    } else if state.showSeconds {
      Text(state.startDate, style: .timer)
    } else {
      Text(state.startDate, style: .relative)
    }
  }
}

struct LiveActivityProgressView: View {
  let state: MeditationLiveActivityAttributes.ContentState

  @ViewBuilder
  var body: some View {
    if state.isCompleted, let targetTime = state.targetTimeInSeconds, targetTime > 0 {
      ProgressView(value: min(state.secondsElapsed / targetTime, 1.0))
    } else if let targetEndDate = state.targetEndDate, targetEndDate > state.startDate {
      ProgressView(
        timerInterval: state.startDate...targetEndDate,
        countsDown: false
      )
    } else {
      ProgressView(value: 0)
    }
  }
}
