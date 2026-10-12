import XCTest

@testable import LittleMomentsMac

final class AppIconTests: XCTestCase {
  func testAppUsesComposerIcon() {
    XCTAssertEqual(
      Bundle.main.object(forInfoDictionaryKey: "CFBundleIconName") as? String, "Little Moments")
  }
}
