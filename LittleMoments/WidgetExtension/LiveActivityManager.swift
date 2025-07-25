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
      print("⚠️ Widget: Live Activities not available or not enabled on this device")
      return
    }

    print("🔄 Widget: Starting Live Activity - Session: \(sessionName), Target time: \(targetTimeInSeconds ?? 0) seconds")
    
    // Configure initial state for the Live Activity
    let initialState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 0,
      targetTimeInSeconds: targetTimeInSeconds,
      isCompleted: false
    )

    // Create attributes object with session name
    let attributes = MeditationLiveActivityAttributes(sessionName: sessionName)

    do {
      print("🔄 Widget: Requesting Live Activity from system")
      // Request new Live Activity from the system
      let activityContent = ActivityContent(state: initialState, staleDate: nil)
      activity = try Activity.request(
        attributes: attributes, 
        content: activityContent,
        pushType: nil
      )
      print("✅ Widget: Live Activity successfully started with ID: \(activity?.id ?? "unknown")")
    } catch {
      print("❌ Widget: Error starting Live Activity: \(error.localizedDescription)")
    }
  }

  /// Updates an existing Live Activity with current session progress
  /// - Parameters:
  ///   - secondsElapsed: Current elapsed time of the session in seconds
  ///   - targetTimeInSeconds: Optional target duration in seconds (nil for untimed sessions)
  ///   - isCompleted: Whether the session has been completed
  func updateActivity(secondsElapsed: Double, targetTimeInSeconds: Double? = nil, isCompleted: Bool = false) {
    guard activity != nil else {
      // Only log this once in a while to avoid spamming
      if Int(secondsElapsed) % 30 == 0 {
        print("⚠️ Widget: Cannot update Live Activity - no active Live Activity found")
      }
      return
    }
    
    // Only log updates periodically to avoid spamming the console
    if Int(secondsElapsed) % 10 == 0 || isCompleted {
      print("🔄 Widget: Updating Live Activity - Time: \(Int(secondsElapsed))s, Target: \(targetTimeInSeconds ?? activity?.content.state.targetTimeInSeconds ?? 0)s, Completed: \(isCompleted)")
    }
    
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
      
      if isCompleted {
        print("✅ Widget: Live Activity marked as completed")
      }
    }
  }

  /// Ends the current Live Activity and removes it from display
  func endActivity() {
    guard activity != nil else {
      print("⚠️ Widget: Cannot end Live Activity - no active Live Activity found")
      return
    }
    
    print("🔄 Widget: Ending Live Activity")
    
    Task {
      // End the Live Activity with immediate dismissal
      if let activity = activity {
        let finalContent = ActivityContent(state: activity.content.state, staleDate: nil)
        await activity.end(finalContent, dismissalPolicy: .immediate)
        print("✅ Widget: Live Activity ended successfully")
      }
      
      // Clear the activity reference
      activity = nil
    }
  }
} 