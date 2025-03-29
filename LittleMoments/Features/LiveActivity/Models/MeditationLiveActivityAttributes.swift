import ActivityKit
import Foundation

public struct MeditationLiveActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public var secondsElapsed: Double
    public var targetTimeInSeconds: Double?
    public var isCompleted: Bool

    public init(
      secondsElapsed: Double, targetTimeInSeconds: Double? = nil, isCompleted: Bool = false
    ) {
      self.secondsElapsed = secondsElapsed
      self.targetTimeInSeconds = targetTimeInSeconds
      self.isCompleted = isCompleted
    }
  }

  public var sessionName: String

  public init(sessionName: String) {
    self.sessionName = sessionName
  }
}
