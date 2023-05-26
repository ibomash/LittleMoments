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

  static func playSound() {
    if let soundURL = Bundle.main.url(
      forResource: "42095__fauxpress__bell-meditation", withExtension: "aif")
    {
      AudioServicesCreateSystemSoundID(soundURL as CFURL, &SoundManager.bellSound)
      // Play
      AudioServicesPlaySystemSound(SoundManager.bellSound)
      print("Played my sound")
    } else {
      print("Could not load my sound")
    }
  }
}
