//
//  SoundManager.swift
//  Just Now
//
//  Created by Illya Bomash on 5/24/23.
//

import AVFoundation

// import AudioToolbox
// import Foundation

@MainActor
final class SoundManager {
  static var soundURL: URL? = Bundle.main.url(
    forResource: "42095__fauxpress__bell-meditation", withExtension: "aif")
  static var audioPlayer: AVAudioPlayer?

  static func initialize() {
    if audioPlayer != nil {
      return
    }

    // Set the audio session category to playback
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.playback)
    } catch {
      print("Error setting audio session category: \(error.localizedDescription)")
    }

    // Create an AVAudioPlayer instance and play the audio file
    if let soundURL {
      do {
        audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
      } catch {
        print("Error playing audio: \(error.localizedDescription)")
      }
    } else {
      print("Could not find sound file")
    }
  }

  static func playSound() {
    guard let audioPlayer else {
      print("Audio player not initialized")
      return
    }
    if !audioPlayer.play() {
      print("Error playing audio")
    }
  }

  static func dispose() {
    audioPlayer = nil
  }
}
