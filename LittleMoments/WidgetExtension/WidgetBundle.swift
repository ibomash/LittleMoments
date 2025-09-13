import ActivityKit
import SwiftUI
import WidgetKit

@main
struct MeditationWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    MeditationLiveActivityWidget()
    StartMeditationWidget()
    // Re-add iOS 18 Control Center control
    if #available(iOS 18.0, *) {
      StartMeditationControlWidget()
    }
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
            Text(
              timerDisplayFromSeconds(
                seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds)
            )
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
            if let url = URL(string: "littlemoments://finishSession") {
              Link(destination: url) {
                Label("Complete", systemImage: "checkmark.circle.fill")
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 6)
                  .background(Color.green.opacity(0.2))
                  .cornerRadius(8)
                  .foregroundColor(.green)
              }
            }

            // Cancel session link
            if let url = URL(string: "littlemoments://cancelSession") {
              Link(destination: url) {
                Label("Cancel", systemImage: "xmark.circle.fill")
                  .frame(maxWidth: .infinity)
                  .padding(.vertical, 6)
                  .background(Color.red.opacity(0.2))
                  .cornerRadius(8)
                  .foregroundColor(.red)
              }
            }
          }
          .padding(.horizontal)
        }
      } compactLeading: {
        Image(systemName: "timer")
      } compactTrailing: {
        Text(
          timerDisplayFromSeconds(
            seconds: context.state.secondsElapsed, showSeconds: context.state.showSeconds)
        )
        .monospacedDigit()
        .font(.caption2)
      } minimal: {
        Image(systemName: "timer")
      }
    }
  }
}

#if DEBUG
  // MARK: - Live Activity Previews

  // Shared preview view that uses the same logic as the real widget
  struct LiveActivityPreviewView: View {
    let state: MeditationLiveActivityAttributes.ContentState
    let attributes: MeditationLiveActivityAttributes
    @Environment(\.showsWidgetContainerBackground) var showsWidgetBackground

    var body: some View {
      ZStack {
        ContainerRelativeShape()
          .fill(showsWidgetBackground ? .clear : .black.opacity(0.1))

        VStack {
          Text("Meditation in progress")
            .font(.headline)

          HStack(spacing: 16) {
            // Timer display using shared logic
            VStack {
              Text(
                timerDisplayFromSeconds(
                  seconds: state.secondsElapsed, showSeconds: state.showSeconds)
              )
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .monospacedDigit()
              .minimumScaleFactor(0.5)
            }

            // Progress bar (for timed sessions)
            if let targetTime = state.targetTimeInSeconds, targetTime > 0 {
              ProgressView(value: min(state.secondsElapsed / targetTime, 1.0))
                .progressViewStyle(.circular)
                .frame(width: 40, height: 40)
            }
          }
          .padding(.vertical, 4)

          // Use links instead of buttons for deep linking
          HStack(spacing: 12) {
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
          }
        }
        .padding()
      }
    }
  }

  // Standard preview provider using shared logic
  struct LiveActivityPreviews: PreviewProvider {
    static var previews: some View {
      Group {
        // Preview in-progress with system background
        LiveActivityPreviewView(
          state: MeditationLiveActivityAttributes.previewState,
          attributes: MeditationLiveActivityAttributes.preview
        )
        .containerBackground(for: .widget) {
          Color(.systemBackground)
        }
        .previewDisplayName("Light Mode")
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        // Preview with dark background
        LiveActivityPreviewView(
          state: MeditationLiveActivityAttributes.previewState,
          attributes: MeditationLiveActivityAttributes.preview
        )
        .containerBackground(for: .widget) {
          Color.black
        }
        .previewDisplayName("Dark Mode")
        .previewContext(WidgetPreviewContext(family: .systemMedium))

        // Preview completed
        LiveActivityPreviewView(
          state: MeditationLiveActivityAttributes.previewStateCompleted,
          attributes: MeditationLiveActivityAttributes.preview
        )
        .containerBackground(for: .widget) {
          Color(.systemBackground)
        }
        .previewDisplayName("Completed")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      }
    }
  }
#endif
