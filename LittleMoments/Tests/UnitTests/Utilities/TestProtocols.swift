import AVFoundation
import Foundation

/// Protocol for objects that can play and stop audio
protocol AudioPlayable {
  func play() -> Bool
  func stop()
}

/// Protocol for playback delegation
protocol PlaybackDelegate: AnyObject {
  func play() -> Bool
  func stop()
}

// Make AVAudioPlayer conform to AudioPlayable
extension AVAudioPlayer: AudioPlayable {}
