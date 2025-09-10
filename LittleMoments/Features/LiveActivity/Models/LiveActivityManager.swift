@preconcurrency import ActivityKit
import Foundation

/// Manager class responsible for handling Live Activity lifecycle for meditation sessions.
/// This provides a centralized way to start, update, and end Live Activities that display
/// meditation session information on the Lock Screen and in Dynamic Island.
@MainActor
final class LiveActivityManager {
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
      print("⚠️ Live Activities not available or not enabled on this device")
      return
    }

    // Get the showSeconds setting
    let showSeconds = JustNowSettings.shared.showSeconds

    print(
      "🔄 Starting Live Activity - Session: \(sessionName), Target time: \(targetTimeInSeconds ?? 0) seconds, Show seconds: \(showSeconds)"
    )

    // Configure initial state for the Live Activity
    let initialState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 0,
      targetTimeInSeconds: targetTimeInSeconds,
      isCompleted: false,
      showSeconds: showSeconds
    )

    // Create attributes object with session name
    let attributes = MeditationLiveActivityAttributes(sessionName: sessionName)

    do {
      print("🔄 Requesting Live Activity from system")
      // Request new Live Activity from the system
      let activityContent = ActivityContent(state: initialState, staleDate: nil)
      activity = try Activity.request(
        attributes: attributes,
        content: activityContent,
        pushType: nil
      )
      print("✅ Live Activity successfully started with ID: \(activity?.id ?? "unknown")")
    } catch {
      print("❌ Error starting Live Activity: \(error.localizedDescription)")
    }
  }

  /// Updates an existing Live Activity with current session progress
  /// - Parameters:
  ///   - secondsElapsed: Current elapsed time of the session in seconds
  ///   - targetTimeInSeconds: Optional target duration in seconds (nil for untimed sessions)
  ///   - isCompleted: Whether the session has been completed
  func updateActivity(
    secondsElapsed: Double, targetTimeInSeconds: Double? = nil, isCompleted: Bool = false
  ) async {
    guard activity != nil else {
      // Only log this once in a while to avoid spamming
      if Int(secondsElapsed) % 30 == 0 {
        print("⚠️ Cannot update Live Activity - no active Live Activity found")
      }
      return
    }

    // Get the current showSeconds setting which might have changed
    let showSeconds = JustNowSettings.shared.showSeconds

    // Only log updates periodically to avoid spamming the console
    if Int(secondsElapsed) % 10 == 0 || isCompleted {
      print(
        "🔄 Updating Live Activity - Time: \(Int(secondsElapsed))s, Target: \(targetTimeInSeconds ?? activity?.content.state.targetTimeInSeconds ?? 0)s, Completed: \(isCompleted), Show seconds: \(showSeconds)"
      )
    }

    // Create updated state with new time and completion status
    let updatedState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: secondsElapsed,
      targetTimeInSeconds: targetTimeInSeconds ?? activity?.content.state.targetTimeInSeconds,
      isCompleted: isCompleted,
      showSeconds: showSeconds
    )

    // Update the Live Activity asynchronously
    let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
    await activity?.update(updatedContent)

    if isCompleted {
      print("✅ Live Activity marked as completed")
    }
  }

  /// Ends the current Live Activity and removes it from display
  func endActivity() async {
    guard activity != nil else {
      print("⚠️ Cannot end Live Activity - no active Live Activity found")
      return
    }

    print("🔄 Ending Live Activity")

    // End the Live Activity with immediate dismissal
    if let activity = activity {
      let finalContent = ActivityContent(state: activity.content.state, staleDate: nil)
      await activity.end(finalContent, dismissalPolicy: .immediate)
      print("✅ Live Activity ended successfully")
    }

    // Clear the activity reference
    activity = nil
  }

  /// Provides haptic feedback for session completion
  /// This method delegates to HapticFeedbackManager for tactile feedback
  func provideSessionCompletionFeedback() {
    HapticFeedbackManager.shared.provideCompletionFeedback()
  }

  /// Completes a session with haptic feedback
  /// This method combines session completion with appropriate tactile feedback
  func completeSessionWithFeedback() {
    // Provide haptic feedback for successful completion
    provideSessionCompletionFeedback()
  }
}
