import ActivityKit
import Foundation

// MARK: - Shared Timer Utility
public func timerDisplayFromSeconds(seconds: Double, showSeconds: Bool) -> String {
  let totalSeconds = Int(seconds)
  let minutes = totalSeconds / 60
  let secs = totalSeconds % 60

  if showSeconds {
    return String(format: "%d:%02d", minutes, secs)
  } else {
    return String(format: "%d", minutes)
  }
}

public struct MeditationLiveActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public var secondsElapsed: Double
    public var targetTimeInSeconds: Double?
    public var isCompleted: Bool
    public var showSeconds: Bool

    public init(
      secondsElapsed: Double, targetTimeInSeconds: Double? = nil, isCompleted: Bool = false, showSeconds: Bool = true
    ) {
      self.secondsElapsed = secondsElapsed
      self.targetTimeInSeconds = targetTimeInSeconds
      self.isCompleted = isCompleted
      self.showSeconds = showSeconds
    }
  }

  public var sessionName: String

  public init(sessionName: String) {
    self.sessionName = sessionName
  }
}

#if DEBUG
// MARK: - Live Activity Preview States
extension MeditationLiveActivityAttributes {
  public static var preview: MeditationLiveActivityAttributes {
    MeditationLiveActivityAttributes(sessionName: "Morning Meditation")
  }
  
  public static var previewState: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 180,  // 3 minutes
      targetTimeInSeconds: 600,  // 10 minutes
      isCompleted: false,
      showSeconds: true
    )
  }
  
  public static var previewStateCompleted: MeditationLiveActivityAttributes.ContentState {
    MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 600,  // 10 minutes (completed)
      targetTimeInSeconds: 600,  // 10 minutes
      isCompleted: true,
      showSeconds: true
    )
  }
}
#endif
