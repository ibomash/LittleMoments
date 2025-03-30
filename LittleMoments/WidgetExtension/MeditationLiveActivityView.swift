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

        // Use Links in a horizontal layout like before
        HStack(spacing: 12) {
          // Complete button
          Link(destination: URL(string: "littlemoments://finishSession")!) {
            HStack {
              Image(systemName: "checkmark.circle.fill")
              Text("Complete")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.green)
          }
          
          // Cancel button
          Link(destination: URL(string: "littlemoments://cancel/session")!) {
            HStack {
              Image(systemName: "xmark.circle.fill")
              Text("Cancel")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.red)
          }
        }
        .padding(.horizontal)
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