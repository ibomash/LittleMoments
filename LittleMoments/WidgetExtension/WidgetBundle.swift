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
            LiveActivityElapsedTimeView(state: context.state)
              .monospacedDigit()
              .font(.title2)
          } icon: {
            Image(systemName: "timer")
          }
          .padding(.leading)
        }

        DynamicIslandExpandedRegion(.trailing) {
          if context.state.targetTimeInSeconds != nil {
            LiveActivityProgressView(state: context.state)
              .progressViewStyle(.circular)
              .frame(width: 40, height: 40)
              .padding(.trailing)
          }
        }

        DynamicIslandExpandedRegion(.bottom) {
          HStack(spacing: 12) {
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
          }
          .padding(.horizontal)
        }
      } compactLeading: {
        Image(systemName: "timer")
      } compactTrailing: {
        LiveActivityElapsedTimeView(state: context.state)
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

  private var previewStateWithoutSeconds: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 185,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: false
    )
  }

  private var previewStateUntimed: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 185,
      isCompleted: false,
      showSeconds: true
    )
  }

  #Preview(
    "Lock Screen · Seconds",
    as: .content,
    using: MeditationLiveActivityAttributes.preview
  ) {
    MeditationLiveActivityWidget()
  } contentStates: {
    MeditationLiveActivityAttributes.previewState
  }

  #Preview(
    "Lock Screen · Minutes",
    as: .content,
    using: MeditationLiveActivityAttributes.preview
  ) {
    MeditationLiveActivityWidget()
  } contentStates: {
    previewStateWithoutSeconds
  }

  #Preview(
    "Lock Screen · Untimed",
    as: .content,
    using: MeditationLiveActivityAttributes.preview
  ) {
    MeditationLiveActivityWidget()
  } contentStates: {
    previewStateUntimed
  }

  #Preview(
    "Lock Screen · Complete",
    as: .content,
    using: MeditationLiveActivityAttributes.preview
  ) {
    MeditationLiveActivityWidget()
  } contentStates: {
    MeditationLiveActivityAttributes.previewStateCompleted
  }
#endif
