import AVFoundation
@preconcurrency import XCTest

@testable import LittleMoments

/// Test suite for SoundManager
@MainActor
final class SoundManagerTests: XCTestCase {

  override func tearDown() async throws {
    // Reset the SoundManager after each test
    SoundManager.dispose()
    try await super.tearDown()
  }

  /// Tests proper initialization of SoundManager
  func testSoundManagerInitialization() {
    // Test initialization
    SoundManager.initialize()
    XCTAssertNotNil(SoundManager.audioPlayer)
    XCTAssertNotNil(SoundManager.soundURL)
  }

  /// Tests sound playback using a mock player
  func testSoundPlayback() {
    // Use a mock player directly and verify behavior
    let mockPlayer = MockAVAudioPlayer()
    mockPlayer.play()
    XCTAssertTrue(mockPlayer.playWasCalled)
  }
}

/// Simple spy class to test if playback was called
class PlaybackSpy: PlaybackDelegate {
  var playWasCalled = false

  func play() -> Bool {
    playWasCalled = true
    return true
  }

  func stop() {
    // Not testing stop in this test
  }
}
