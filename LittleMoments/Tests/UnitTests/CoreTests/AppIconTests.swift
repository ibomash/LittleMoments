import XCTest

@testable import LittleMoments

@MainActor
final class AppIconTests: XCTestCase {
  /// Verifies the compiled app selects the Composer icon on both device families.
  func testAppIconIsConfiguredForPhoneAndPad() throws {
    let appBundle = Bundle(for: AppState.self)
    let data = try Data(contentsOf: appBundle.bundleURL.appendingPathComponent("Info.plist"))
    let metadata = try XCTUnwrap(
      PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any])
    for key in ["CFBundleIcons", "CFBundleIcons~ipad"] {
      let icons = try XCTUnwrap(
        metadata[key] as? [String: Any], "Missing \(key) in \(appBundle.bundleURL.path)")
      let primaryIcon = try XCTUnwrap(icons["CFBundlePrimaryIcon"] as? [String: Any])
      XCTAssertEqual(primaryIcon["CFBundleIconName"] as? String, "Little Moments")
    }
  }
}
