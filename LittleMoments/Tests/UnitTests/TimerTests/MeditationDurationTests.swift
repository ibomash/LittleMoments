import XCTest

@testable import LittleMoments

final class MeditationDurationTests: XCTestCase {
  func testFormattingShortLabels() throws {
    XCTAssertEqual(try MeditationDuration(minutes: 1).shortLabel, "1 min")
    XCTAssertEqual(try MeditationDuration(minutes: 59).shortLabel, "59 min")
    XCTAssertEqual(try MeditationDuration(minutes: 60).shortLabel, "1 hr")
    XCTAssertEqual(try MeditationDuration(minutes: 90).shortLabel, "1 hr 30 min")
    XCTAssertEqual(try MeditationDuration(minutes: 120).shortLabel, "2 hr")
    XCTAssertEqual(try MeditationDuration(minutes: 150).shortLabel, "2 hr 30 min")
  }

  func testAccessibilityLabels() throws {
    XCTAssertEqual(try MeditationDuration(minutes: 1).accessibilityLabel, "1 minute")
    XCTAssertEqual(try MeditationDuration(minutes: 2).accessibilityLabel, "2 minutes")
    XCTAssertEqual(try MeditationDuration(minutes: 60).accessibilityLabel, "1 hour")
    XCTAssertEqual(try MeditationDuration(minutes: 121).accessibilityLabel, "2 hours 1 minute")
  }

  func testParsingRejectsInvalidValues() {
    XCTAssertEqual(MeditationDuration.parseMinutes(""), .failure(.empty))
    XCTAssertEqual(MeditationDuration.parseMinutes("abc"), .failure(.notWholeMinutes))
    XCTAssertEqual(MeditationDuration.parseMinutes("1.5"), .failure(.notWholeMinutes))
    XCTAssertEqual(MeditationDuration.parseMinutes("0"), .failure(.belowMinimum))
  }

  func testParsingAcceptsValuesOverSliderMaximum() throws {
    let result = MeditationDuration.parseMinutes("150")

    guard case .success(let duration) = result else {
      return XCTFail("Expected 150 minutes to parse successfully")
    }
    XCTAssertEqual(duration.minutes, 150)
  }

  func testSliderMinutesClampToOneThroughTwoHours() {
    XCTAssertEqual(MeditationDuration.clampedSliderMinutes(-10), 1)
    XCTAssertEqual(MeditationDuration.clampedSliderMinutes(25.4), 25)
    XCTAssertEqual(MeditationDuration.clampedSliderMinutes(140), 120)
  }
}
