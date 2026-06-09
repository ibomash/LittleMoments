import XCTest

@testable import LittleMoments

@MainActor
final class TimerPresetDurationTests: XCTestCase {
  func testDefaultPresetDurationsReserveCustomSlot() throws {
    let timerViewModel = TimerViewModel()

    XCTAssertNil(timerViewModel.scheduledAlert)
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 7)

    #if targetEnvironment(simulator)
      let expectedNames = ["5 sec", "10", "15", "20", "30", "45", "60"]
    #else
      let expectedNames = ["5", "10", "15", "20", "30", "45", "60"]
    #endif
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.map(\.name), expectedNames)
  }

  func testApplyPresetDurationCreatesCustomTargetWithoutChangingPresetList() throws {
    let timerViewModel = TimerViewModel()

    timerViewModel.applyPresetDuration(420)

    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 7)
    XCTAssertEqual(timerViewModel.scheduledAlert?.name, "7")
    XCTAssertEqual(Int(timerViewModel.scheduledAlert?.targetTimeInSec ?? 0), 420)
    XCTAssertTrue(timerViewModel.hasCustomDurationTarget)
    XCTAssertEqual(timerViewModel.customDurationLabel, "7")
  }

  func testApplyPresetDurationSupportsNonMinuteTarget() throws {
    let timerViewModel = TimerViewModel()

    timerViewModel.applyPresetDuration(315)

    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 7)
    XCTAssertEqual(timerViewModel.scheduledAlert?.name, "315s")
    XCTAssertEqual(Int(timerViewModel.scheduledAlert?.targetTimeInSec ?? 0), 315)
    XCTAssertTrue(timerViewModel.hasCustomDurationTarget)
  }

  func testApplyPresetDurationExistingOptionSelectsPreset() throws {
    let timerViewModel = TimerViewModel()

    timerViewModel.applyPresetDuration(600)

    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 7)
    XCTAssertNotNil(timerViewModel.scheduledAlert)
    XCTAssertEqual(timerViewModel.scheduledAlert?.name, "10")
    XCTAssertEqual(Int(timerViewModel.scheduledAlert?.targetTimeInSec ?? 0), 600)
    XCTAssertFalse(timerViewModel.hasCustomDurationTarget)
  }

  func testClearDurationTargetClearsPresetAndCustomTargets() throws {
    let timerViewModel = TimerViewModel()

    timerViewModel.applyPresetDuration(420)
    XCTAssertNotNil(timerViewModel.scheduledAlert)

    timerViewModel.clearDurationTarget()

    XCTAssertNil(timerViewModel.scheduledAlert)
    XCTAssertFalse(timerViewModel.hasCustomDurationTarget)
  }
}
