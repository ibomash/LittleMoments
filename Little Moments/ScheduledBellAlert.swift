//
//  ScheduledBellAlert.swift
//  Just Now
//
//  Created by Illya Bomash on 5/27/23.
//

import Foundation

protocol ScheduledAlert {
  var name: String { get }
  var hasTarget: Bool { get }

  func getProgress(numSecondsElapsed: Int) -> CGFloat
  func checkTrigger(numSecondsElapsed: Int)
}

class OneTimeScheduledBellAlert: ScheduledAlert {
  let targetTimeInSec: Int
  let name: String
  var hasTriggered: Bool = false
  let hasTarget: Bool = true

  func getProgress(numSecondsElapsed: Int) -> CGFloat {
    if numSecondsElapsed > targetTimeInSec {
      return 1.0
    }
    return CGFloat(numSecondsElapsed) / CGFloat(targetTimeInSec)
  }

  init(targetTimeInSec: Int, name: String) {
    self.targetTimeInSec = targetTimeInSec
    self.name = name
  }

  init(targetTimeInMin: Int) {
    self.targetTimeInSec = targetTimeInMin * 60
    self.name = "\(targetTimeInMin) min"
  }

  func checkTrigger(numSecondsElapsed: Int) {
    if hasTriggered {
      return
    }
    if numSecondsElapsed >= targetTimeInSec {
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
  var targetTimeInSec: Int
  var name: String
  var hasTriggered: Bool = false
  let hasTarget: Bool = false
  var intervalInSec: Int

  init(name: String, intervalInSec: Int) {
    // Raise an exception if intervalInSec is not greater than zero
    assert(intervalInSec > 0)

    self.name = name
    self.targetTimeInSec = intervalInSec
    self.intervalInSec = intervalInSec
  }

  func getProgress(numSecondsElapsed: Int) -> CGFloat {
    let timeUntilNextTrigger = (targetTimeInSec - numSecondsElapsed) % intervalInSec
    return CGFloat(timeUntilNextTrigger) / CGFloat(intervalInSec)
  }

  func checkTrigger(numSecondsElapsed: Int) {
    if !hasTriggered && numSecondsElapsed >= targetTimeInSec {
      doTrigger()
      targetTimeInSec += intervalInSec
      // If we've missed a trigger, catch up (shouldn't normally happen)
      while targetTimeInSec < numSecondsElapsed {
        targetTimeInSec += intervalInSec
      }
    }
  }

  func doTrigger() {
    print("Triggered \(name) alert")
    SoundManager.playSound()
  }
}
