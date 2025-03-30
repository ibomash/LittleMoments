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

#if DEBUG
// MARK: - Live Activity Previews
extension MeditationLiveActivityAttributes {
  static var preview: MeditationLiveActivityAttributes {
    MeditationLiveActivityAttributes(sessionName: "Morning Meditation")
  }
  
  static var previewState: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 180,  // 3 minutes
      targetTimeInSeconds: 600,  // 10 minutes
      isCompleted: false,
      showSeconds: true
    )
  }
  
  static var previewStateCompleted: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 600,  // 10 minutes (completed)
      targetTimeInSeconds: 600,  // 10 minutes
      isCompleted: true,
      showSeconds: true
    )
  }
}

// Create a mock preview for Live Activities since we can't directly instantiate ActivityViewContext
struct LiveActivityPreviewView: View {
  let isCompleted: Bool
  
  var body: some View {
    VStack {
      Text("Meditation in progress")
        .font(.headline)

      HStack(spacing: 16) {
        // Timer display
        VStack {
          Text(isCompleted ? "10:00" : "3:00")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .monospacedDigit()
            .minimumScaleFactor(0.5)
        }

        // Progress bar (for timed sessions)
        ProgressView(value: isCompleted ? 1.0 : 0.3)
          .progressViewStyle(.circular)
          .frame(width: 40, height: 40)
      }
      .padding(.vertical, 4)

      // Deep linking buttons
      HStack(spacing: 12) {
        Link(destination: URL(string: "littlemoments://finishSession")!) {
          Text("Finish")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.green)
        }
        
        Link(destination: URL(string: "littlemoments://cancelSession")!) {
          Text("Cancel")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.red.opacity(0.2))
            .cornerRadius(8)
            .foregroundColor(.red)
        }
      }
    }
    .padding()
  }
}

// Standard preview provider that doesn't require ActivityViewContext
struct LiveActivityPreviews: PreviewProvider {
  static var previews: some View {
    Group {
      // Preview in-progress with system background
      LiveActivityPreviewView(isCompleted: false)
        .containerBackground(for: .widget) {
          Color(.systemBackground)
        }
        .previewDisplayName("Light Mode")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      
      // Preview with dark background
      LiveActivityPreviewView(isCompleted: false)
        .containerBackground(for: .widget) {
          Color.black
        }
        .previewDisplayName("Dark Mode")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
      
      // Preview completed
      LiveActivityPreviewView(isCompleted: true)
        .containerBackground(for: .widget) {
          Color(.systemBackground)
        }
        .previewDisplayName("Completed")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
#endif 