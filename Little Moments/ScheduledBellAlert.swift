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
    let MAX_DELAY: CGFloat = 5.0
    if secondsElapsed - targetTimeInSec > MAX_DELAY {
      print("Skipping sound due to delay")
      return
    }
    print("Triggered \(name) alert")
    SoundManager.playSound()
  }
}

class RecurringScheduledBellAlert: ScheduledAlert {
  static func == (lhs: RecurringScheduledBellAlert, rhs: RecurringScheduledBellAlert) -> Bool {
    return (lhs.targetTimeInSec == rhs.targetTimeInSec) && (lhs.name == rhs.name)
      && (lhs.hasTarget == rhs.hasTarget) && (lhs.intervalInSec == rhs.intervalInSec)
  }

  var targetTimeInSec: CGFloat
  var name: String
  var hasTriggered: Bool = false
  let hasTarget: Bool = false
  var intervalInSec: CGFloat

  init(name: String, intervalInSec: Int) {
    // Raise an exception if intervalInSec is not greater than zero
    assert(intervalInSec > 0)

    self.name = name
    self.targetTimeInSec = CGFloat(intervalInSec)
    self.intervalInSec = CGFloat(intervalInSec)
  }

  func getProgress(secondsElapsed: CGFloat) -> CGFloat {
    let timeUntilNextTrigger = (targetTimeInSec - secondsElapsed).truncatingRemainder(
      dividingBy: intervalInSec)
    return CGFloat(timeUntilNextTrigger) / CGFloat(intervalInSec)
  }

  func checkTrigger(secondsElapsed: CGFloat) {
    if !hasTriggered && secondsElapsed >= targetTimeInSec {
      doTrigger()
      targetTimeInSec += intervalInSec
      // If we've missed a trigger, catch up (shouldn't normally happen)
      while targetTimeInSec < secondsElapsed {
        targetTimeInSec += intervalInSec
      }
    }
  }

  func doTrigger() {
    print("Triggered \(name) alert")
    SoundManager.playSound()
  }
}
