//
//  ScheduledBellAlert.swift
//  Just Now
//
//  Created by Illya Bomash on 5/27/23.
//

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

  func checkTrigger(secondsElapsed: CGFloat) {
    if hasTriggered {
      return
    }
    if secondsElapsed >= targetTimeInSec {
      self.doTrigger()
      hasTriggered = true
    }
  }

  func doTrigger() {
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
