@preconcurrency import XCTest

@testable import LittleMoments

@MainActor
final class BellPlaybackModeTests: XCTestCase {
  private var suiteName: String!
  private var defaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suiteName = UUID().uuidString
    defaults = UserDefaults(suiteName: suiteName)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    defaults = nil
    suiteName = nil
    super.tearDown()
  }

  func testModeDefaultsOffWhenSystemIntegrationsAreDisabled() {
    let mode = BellPlaybackMode.resolved(
      arguments: ["App", "-DISABLE_SYSTEM_INTEGRATIONS"],
      environment: [:],
      userDefaults: defaults
    )

    XCTAssertEqual(mode, .off)
  }

  func testModeDefaultsOffUnderXCTestEnvironment() {
    let mode = BellPlaybackMode.resolved(
      arguments: ["App"],
      environment: ["XCTestConfigurationFilePath": "/tmp/tests.xctestconfiguration"],
      userDefaults: defaults
    )

    XCTAssertEqual(mode, .off)
  }

  func testModeParsesSeparatedLaunchArgument() {
    let mode = BellPlaybackMode.resolved(
      arguments: ["App", "-ROBUST_BELL_PLAYBACK_MODE", "audio-only"],
      environment: [:],
      userDefaults: defaults
    )

    XCTAssertEqual(mode, .audioOnly)
  }

  func testModeParsesEqualsLaunchArgument() {
    let mode = BellPlaybackMode.resolved(
      arguments: ["App", "-ROBUST_BELL_PLAYBACK_MODE=notification_only"],
      environment: [:],
      userDefaults: defaults
    )

    XCTAssertEqual(mode, .notificationOnly)
  }

  func testModeParsesUserDefault() {
    defaults.set("hybrid", forKey: "robustBellPlaybackMode")

    let mode = BellPlaybackMode.resolved(
      arguments: ["App"],
      environment: [:],
      userDefaults: defaults
    )

    XCTAssertEqual(mode, .hybrid)
  }

  func testModeDefaultsToHybridOutsideTests() {
    let mode = BellPlaybackMode.resolved(
      arguments: ["App"], environment: [:], userDefaults: defaults)

    XCTAssertEqual(mode, .hybrid)
  }
}
