import AVFoundation
import Foundation

protocol ScheduledAlert: Equatable {
  var name: String { get }
  var hasTarget: Bool { get }

  func getProgress(secondsElapsed: CGFloat) -> CGFloat
  func checkTrigger(secondsElapsed: CGFloat)
}

class OneTimeScheduledBellAlert: ScheduledAlert {
  static func == (lhs: OneTimeScheduledBellAlert, rhs: OneTimeScheduledBellAlert) -> Bool {
    return (lhs.targetTimeInSec == rhs.targetTimeInSec) && (lhs.name == rhs.name)
      && (lhs.hasTarget == rhs.hasTarget)
  }

  let targetTimeInSec: CGFloat
  let name: String
  var notificationDurationDescription: String {
    if Int(targetTimeInSec) % 60 == 0,
      let duration = try? MeditationDuration(minutes: Int(targetTimeInSec) / 60)
    {
      return duration.shortLabel
    }
    return name
  }

  var hasTriggered: Bool = false
  let hasTarget: Bool = true

  func getProgress(secondsElapsed: CGFloat) -> CGFloat {
    if secondsElapsed > targetTimeInSec {
      return 1.0
    }
    return CGFloat(secondsElapsed) / CGFloat(targetTimeInSec)
  }

  init(targetTimeInSec: Int, name: String) {
    self.targetTimeInSec = CGFloat(targetTimeInSec)
    self.name = name
  }

  init(targetTimeInMin: Int) {
    self.targetTimeInSec = CGFloat(targetTimeInMin) * 60
    self.name = "\(targetTimeInMin)"
  }

  func isDone(secondsElapsed: CGFloat) -> Bool {
    return secondsElapsed >= targetTimeInSec
  }

  func checkTrigger(secondsElapsed: CGFloat) {
    if hasTriggered {
      return
    }
    if self.isDone(secondsElapsed: secondsElapsed) {
      self.doTrigger(secondsElapsed: secondsElapsed)
      hasTriggered = true
    }
  }

  func doTrigger(secondsElapsed: CGFloat) {
    let maxDelay: CGFloat = 5.0
    if secondsElapsed - targetTimeInSec > maxDelay {
      print("Skipping sound due to delay")
      return
    }
    print("Triggered \(name) alert")
    Task { @MainActor in
      SoundManager.playSound()
    }
  }
}
