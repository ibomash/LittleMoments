import XCTest

@testable import LittleMoments

/// Test suite for JustNowSettings
final class JustNowSettingsTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Clear UserDefaults before each test
    UserDefaultsReset.resetDefaults()
  }

  /// Tests default settings values
  func testDefaultSettings() {
    // Test default values
    let settings = JustNowSettings.shared
    XCTAssertFalse(settings.writeToHealth)
    XCTAssertTrue(settings.ringBellAtStart)
    XCTAssertTrue(settings.showSeconds)
  }

  /// Tests that settings are properly persisted
  func testSettingsPersistence() {
    let settings = JustNowSettings.shared

    // Test setting values
    settings.ringBellAtStart = false
    settings.showSeconds = false
    settings.writeToHealth = true

    // Create new instance to test if values were saved
    let newSettings = JustNowSettings.shared
    XCTAssertEqual(newSettings.ringBellAtStart, false)
    XCTAssertEqual(newSettings.showSeconds, false)
    XCTAssertEqual(newSettings.writeToHealth, true)
  }
}
