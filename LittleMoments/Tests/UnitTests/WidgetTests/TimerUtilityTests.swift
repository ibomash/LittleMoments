import XCTest
@testable import LittleMoments

final class TimerUtilityTests: XCTestCase {
  
  func testTimerDisplayWithSeconds() {
    // Test various time values with seconds enabled
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 0, showSeconds: true), "0:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 59, showSeconds: true), "0:59")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 60, showSeconds: true), "1:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 125, showSeconds: true), "2:05")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 180, showSeconds: true), "3:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 3600, showSeconds: true), "60:00")
  }
  
  func testTimerDisplayWithoutSeconds() {
    // Test various time values with seconds disabled
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 0, showSeconds: false), "0")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 59, showSeconds: false), "0")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 60, showSeconds: false), "1")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 125, showSeconds: false), "2")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 180, showSeconds: false), "3")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 3600, showSeconds: false), "60")
  }
  
  func testTimerDisplayEdgeCases() {
    // Test edge cases and boundary conditions
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 0.5, showSeconds: true), "0:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 59.9, showSeconds: true), "0:59")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 60.1, showSeconds: true), "1:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 0.9, showSeconds: false), "0")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 59.9, showSeconds: false), "0")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 60.1, showSeconds: false), "1")
  }
  
  func testTimerDisplayLargeValues() {
    // Test large time values
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 7200, showSeconds: true), "120:00")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 7200, showSeconds: false), "120")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 7265, showSeconds: true), "121:05")
    XCTAssertEqual(timerDisplayFromSeconds(seconds: 7265, showSeconds: false), "121")
  }
  
  func testTimerDisplayConsistency() {
    // Test that the same input always produces the same output
    let testSeconds: Double = 185
    let withSeconds = timerDisplayFromSeconds(seconds: testSeconds, showSeconds: true)
    let withoutSeconds = timerDisplayFromSeconds(seconds: testSeconds, showSeconds: false)
    
    XCTAssertEqual(withSeconds, "3:05")
    XCTAssertEqual(withoutSeconds, "3")
    
    // Test multiple calls return same result
    XCTAssertEqual(timerDisplayFromSeconds(seconds: testSeconds, showSeconds: true), withSeconds)
    XCTAssertEqual(timerDisplayFromSeconds(seconds: testSeconds, showSeconds: false), withoutSeconds)
  }
}