//
//  SoundManager.swift
//  Just Now
//
//  Created by Illya Bomash on 5/24/23.
//

import AudioToolbox
import Foundation

class SoundManager {
  static var bellSound: SystemSoundID = 0

  static func initialize() {
    if bellSound != 0 {
      return
    }

    if let soundURL = Bundle.main.url(
      forResource: "42095__fauxpress__bell-meditation", withExtension: "aif")
    {
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &SoundManager.bellSound)
      print("Loaded my sound")
    } else {
      print("Could not load my sound")
    }
  }

  static func playSound() {
    if bellSound == 0 {
      print("Sound not loaded")
      return
    }

    AudioServicesPlaySystemSound(SoundManager.bellSound)
  }

  static func dispose() {
    if bellSound != 0 {
      AudioServicesDisposeSystemSoundID(bellSound)
      bellSound = 0
    }
  }
}
