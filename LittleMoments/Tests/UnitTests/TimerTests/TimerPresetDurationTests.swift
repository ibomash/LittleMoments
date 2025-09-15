import XCTest

@testable import LittleMoments

@MainActor
final class TimerPresetDurationTests: XCTestCase {

  func testApplyPresetDuration420() throws {
    let timerViewModel = TimerViewModel()

    // Check initial state
    XCTAssertNil(timerViewModel.scheduledAlert)
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 8)  // Default options

    // Apply 420 seconds (7 minutes)
    timerViewModel.applyPresetDuration(420)

    // Check that the count is still 8 (temporary option added, last option removed)
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 8)

    // Check that the first option is the temporary 7-minute option
    let firstOption = timerViewModel.scheduledAlertOptions[0]
    XCTAssertEqual(firstOption.name, "7")
    XCTAssertEqual(Int(firstOption.targetTimeInSec), 420)

    // Check that this option is selected
    XCTAssertNotNil(timerViewModel.scheduledAlert)
    XCTAssertEqual(timerViewModel.scheduledAlert, firstOption)
    XCTAssertEqual(timerViewModel.scheduledAlert?.name, "7")
  }

  func testApplyPresetDuration315() throws {
    let timerViewModel = TimerViewModel()

    // Apply 315 seconds (5 minutes 15 seconds - not evenly divisible by 60)
    timerViewModel.applyPresetDuration(315)

    // Check that a temporary option was created with "315s" label
    let firstOption = timerViewModel.scheduledAlertOptions[0]
    XCTAssertEqual(firstOption.name, "315s")
    XCTAssertEqual(Int(firstOption.targetTimeInSec), 315)

    // Check that this option is selected
    XCTAssertEqual(timerViewModel.scheduledAlert, firstOption)
  }

  func testApplyPresetDurationExistingOption() throws {
    let timerViewModel = TimerViewModel()

    // Apply 300 seconds (5 minutes - should match existing option)
    timerViewModel.applyPresetDuration(300)

    // Should not create a new option (still 8 total)
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 8)

    // Should select the existing 5-minute option
    XCTAssertNotNil(timerViewModel.scheduledAlert)
    XCTAssertEqual(timerViewModel.scheduledAlert?.name, "5")
    XCTAssertEqual(Int(timerViewModel.scheduledAlert!.targetTimeInSec), 300)
  }

  func testTemporaryOptionRemoval() throws {
    let timerViewModel = TimerViewModel()

    // Store reference to the last option before adding temporary
    let originalLastOption = timerViewModel.scheduledAlertOptions.last!
    XCTAssertEqual(originalLastOption.name, "60")  // 60 minutes

    // Apply 420 seconds (7 minutes) - creates temporary option
    timerViewModel.applyPresetDuration(420)

    // Verify the temporary option is at the front and last option was removed
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 8)
    XCTAssertEqual(timerViewModel.scheduledAlertOptions[0].name, "7")
    XCTAssertNotEqual(timerViewModel.scheduledAlertOptions.last!.name, "60")  // 60min option should be gone

    // Apply an existing option (should remove temporary and restore removed option)
    timerViewModel.applyPresetDuration(300)  // 5 minutes

    // Verify count is still 8 and temporary option is gone
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 8)
    XCTAssertNotEqual(timerViewModel.scheduledAlertOptions[0].name, "7")  // Temporary should be gone

    // Check if the 60-minute option was restored
    let has60MinOption = timerViewModel.scheduledAlertOptions.contains { $0.name == "60" }
    XCTAssertTrue(
      has60MinOption, "60-minute option should be restored when temporary option is removed")
  }
}
