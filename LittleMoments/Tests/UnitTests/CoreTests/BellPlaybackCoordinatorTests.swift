import AVFoundation
import Foundation
@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class BellPlaybackCoordinatorTests: XCTestCase {
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
