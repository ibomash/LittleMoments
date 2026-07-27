import Foundation
@preconcurrency import XCTest

@testable import LittleMoments

final class CustomDurationSheetTests: XCTestCase {
  func testStartModeProjectsFinishFromCurrentTime() {
    let now = Date(timeIntervalSinceReferenceDate: 10_000)
    let earlierSessionStart = now.addingTimeInterval(-300)

    let finishDate = CustomDurationSheetMode.start.projectedFinishDate(
      duration: 600,
      now: now,
      sessionStartDate: earlierSessionStart
    )

    XCTAssertEqual(finishDate, now.addingTimeInterval(600))
  }

  func testRunningModeProjectsFinishFromSessionStart() {
    let now = Date(timeIntervalSinceReferenceDate: 10_000)
    let sessionStart = now.addingTimeInterval(-300)

    let finishDate = CustomDurationSheetMode.running.projectedFinishDate(
      duration: 600,
      now: now,
      sessionStartDate: sessionStart
    )

    XCTAssertEqual(finishDate, sessionStart.addingTimeInterval(600))
    XCTAssertEqual(finishDate.timeIntervalSince(now), 300)
  }

  func testRunningModeFallsBackToCurrentTimeWithoutSessionStart() {
    let now = Date(timeIntervalSinceReferenceDate: 10_000)

    let finishDate = CustomDurationSheetMode.running.projectedFinishDate(
      duration: 600,
      now: now,
      sessionStartDate: nil
    )

    XCTAssertEqual(finishDate, now.addingTimeInterval(600))
  }
}
