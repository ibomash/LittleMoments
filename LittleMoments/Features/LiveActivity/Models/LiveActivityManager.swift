import ActivityKit
import Foundation

/// Manager class responsible for handling Live Activity lifecycle for meditation sessions.
/// This provides a centralized way to start, update, and end Live Activities that display
/// meditation session information on the Lock Screen and in Dynamic Island.
class LiveActivityManager {
  /// Shared singleton instance for app-wide access
  static let shared = LiveActivityManager()

  /// Current active Live Activity, if one exists
  private var activity: Activity<MeditationLiveActivityAttributes>?

  /// Private initializer to enforce singleton pattern
  private init() {}

  /// Starts a new Live Activity for a meditation session
  /// - Parameters:
  ///   - sessionName: Name or title of the meditation session
  ///   - targetTimeInSeconds: Optional target duration in seconds (nil for untimed sessions)
  func startActivity(sessionName: String, targetTimeInSeconds: Double?) {
    // Check if Live Activities are available and enabled on this device
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      print("Live Activities not available")
      return
    }

    // Configure initial state for the Live Activity
    let initialState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 0,
      targetTimeInSeconds: targetTimeInSeconds,
      isCompleted: false
    )

    // Create attributes object with session name
    let attributes = MeditationLiveActivityAttributes(sessionName: sessionName)

    do {
      print("Requesting live activity from system")
      // Request new Live Activity from the system
      let activityContent = ActivityContent(state: initialState, staleDate: nil)
      activity = try Activity.request(
        attributes: attributes, 
        content: activityContent,
        pushType: nil
      )
      print("Live activity successfully requested: \(String(describing: activity?.id))")
    } catch {
      print("Error starting live activity: \(error)")
    }
  }

  /// Updates an existing Live Activity with current session progress
  /// - Parameters:
  ///   - secondsElapsed: Current elapsed time of the session in seconds
  ///   - targetTimeInSeconds: Optional target duration in seconds (nil for untimed sessions)
  ///   - isCompleted: Whether the session has been completed
  func updateActivity(secondsElapsed: Double, targetTimeInSeconds: Double? = nil, isCompleted: Bool = false) {
    print("Updating live activity with seconds elapsed: \(secondsElapsed), isCompleted: \(isCompleted)")
    Task {
      // Create updated state with new time and completion status
      let updatedState = MeditationLiveActivityAttributes.ContentState(
        secondsElapsed: secondsElapsed,
        targetTimeInSeconds: targetTimeInSeconds ?? activity?.content.state.targetTimeInSeconds,
        isCompleted: isCompleted
      )

      // Update the Live Activity asynchronously
      let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
      await activity?.update(updatedContent)
    }
  }

  /// Ends the current Live Activity and removes it from display
  func endActivity() {
    Task {
      // End the Live Activity with immediate dismissal
      await activity?.end(dismissalPolicy: .immediate)
      
      // Clear the activity reference
      activity = nil
    }
  }
}
