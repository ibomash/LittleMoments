import AVFoundation
import Foundation
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class BellPlaybackCoordinatorTests: XCTestCase {
  func testRemainingSecondsUsesAbsoluteDeadlineAfterSetupDelay() {
    let deadline = Date(timeIntervalSinceReferenceDate: 100)
    let nowAfterSetup = Date(timeIntervalSinceReferenceDate: 95)

    let remainingSeconds = BellPlaybackCoordinator.remainingSeconds(
      until: deadline,
      now: nowAfterSetup
    )

    XCTAssertEqual(remainingSeconds, 5)
  }

  func testRemainingSecondsClampsElapsedDeadlineToZero() {
    let deadline = Date(timeIntervalSinceReferenceDate: 100)
    let nowAfterDeadline = Date(timeIntervalSinceReferenceDate: 105)

    let remainingSeconds = BellPlaybackCoordinator.remainingSeconds(
      until: deadline,
      now: nowAfterDeadline
    )

    XCTAssertEqual(remainingSeconds, 0)
  }

  func testReplacingQueueContentsReusesPlayerAndInstallsBellItem() {
    let silentItem = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/silence.caf"))
    let bellItem = AVPlayerItem(url: URL(fileURLWithPath: "/tmp/bell.aif"))
    let player = AVQueuePlayer(playerItem: silentItem)

    let didReplace = BellPlaybackCoordinator.replaceQueueContents(
      with: bellItem,
      in: player
    )

    XCTAssertTrue(didReplace)
    XCTAssertEqual(player.items().count, 1)
    XCTAssertTrue(player.currentItem === bellItem)
  }
}
