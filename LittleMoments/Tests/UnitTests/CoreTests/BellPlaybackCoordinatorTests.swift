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

  func testWatchdogDoesNotFallbackWhenPrimaryBellAdvanced() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()

    let shouldFallback = state.claimFallback(
      planID: planID,
      progressSeconds: 0.1,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )

    XCTAssertFalse(shouldFallback)
  }

  func testWatchdogFallsBackWhenPrimaryBellIsStalled() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()

    let shouldFallback = state.claimFallback(
      planID: planID,
      progressSeconds: 0,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )

    XCTAssertTrue(shouldFallback)
  }

  func testWatchdogFallsBackWhenProgressIsUnknown() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()

    let shouldFallback = state.claimFallback(
      planID: planID,
      progressSeconds: nil,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )

    XCTAssertTrue(shouldFallback)
  }

  func testWatchdogDoesNotFallbackWhileApplicationIsInactive() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()

    let shouldFallback = state.claimFallback(
      planID: planID,
      progressSeconds: nil,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: false
    )

    XCTAssertFalse(shouldFallback)
  }

  func testWatchdogFallsBackOnlyOnceForPlan() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()

    let firstClaim = state.claimFallback(
      planID: planID,
      progressSeconds: nil,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )
    let secondClaim = state.claimFallback(
      planID: planID,
      progressSeconds: nil,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )

    XCTAssertTrue(firstClaim)
    XCTAssertFalse(secondClaim)
  }

  func testFailedFallbackStartIsNotTrackedAsPlayback() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()
    XCTAssertTrue(
      state.claimFallback(
        planID: planID,
        progressSeconds: nil,
        minimumConfirmedProgressSeconds: 0.05,
        applicationIsActive: true
      )
    )

    state.recordFallbackPlaybackStart(planID: planID, didStart: false)

    XCTAssertNil(state.fallbackPlaybackPlanID)
  }

  func testSuccessfulFallbackStartIsTrackedAsPlayback() {
    var state = CompletionBellWatchdogState()
    let planID = state.replacePlan()
    XCTAssertTrue(
      state.claimFallback(
        planID: planID,
        progressSeconds: nil,
        minimumConfirmedProgressSeconds: 0.05,
        applicationIsActive: true
      )
    )

    state.recordFallbackPlaybackStart(planID: planID, didStart: true)

    XCTAssertEqual(state.fallbackPlaybackPlanID, planID)
  }

  func testReplacingPlanInvalidatesStaleWatchdog() {
    var state = CompletionBellWatchdogState()
    let stalePlanID = state.replacePlan()
    _ = state.replacePlan()

    let shouldFallback = state.claimFallback(
      planID: stalePlanID,
      progressSeconds: nil,
      minimumConfirmedProgressSeconds: 0.05,
      applicationIsActive: true
    )

    XCTAssertFalse(shouldFallback)
  }
}
