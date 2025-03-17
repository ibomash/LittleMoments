//
//  SoundService.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation
import AVFoundation
#if os(iOS)
import UIKit
#endif

/// Protocol defining the sound service functionality
protocol SoundServiceProtocol {
    /// Initializes the sound service
    func initialize()
    
    /// Plays the meditation bell sound
    func playSound()
    
    /// Releases resources used by the sound service
    func dispose()
}

/// Concrete implementation of the SoundServiceProtocol
final class SoundServiceImpl: SoundServiceProtocol {
    /// Singleton instance for backward compatibility
    /// Will be deprecated after refactoring is complete
    static let shared = SoundServiceImpl()
    
    /// URL of the sound file to play
    private let soundURL: URL?
    
    /// Audio player instance
    private var audioPlayer: AVAudioPlayer?
    
    /// Initializes a new sound service
    /// - Parameter soundURL: The URL of the sound file to play
    init(soundURL: URL? = Bundle.main.url(
        forResource: "42095__fauxpress__bell-meditation", withExtension: "aif")
    ) {
        self.soundURL = soundURL
    }
    
    /// Initializes the sound service
    func initialize() {
        if audioPlayer != nil {
            return
        }
        
        #if os(iOS)
        // Set the audio session category to playback
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Error setting audio session category: \(error.localizedDescription)")
        }
        #endif
        
        // Create an AVAudioPlayer instance
        if let soundURL = soundURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            } catch {
                print("Error creating audio player: \(error.localizedDescription)")
            }
        } else {
            print("Could not find sound file")
        }
    }
    
    /// Plays the meditation bell sound
    func playSound() {
        guard let audioPlayer = audioPlayer else {
            print("Audio player not initialized")
            return
        }
        
        if !audioPlayer.play() {
            print("Error playing audio")
        }
    }
    
    /// Releases resources used by the sound service
    func dispose() {
        audioPlayer = nil
    }
} 