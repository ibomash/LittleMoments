import ActivityKit
import Foundation

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