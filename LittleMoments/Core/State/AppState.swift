import SwiftUI

class AppState: ObservableObject {
  static let shared = AppState()

  // Make initializer private to enforce singleton pattern
  private init() {
    resetState()
  }

  // Method to reset state for testing purposes
  func resetState() {
    showTimerRunningView = false
    showSettingsView = false
  }

  @Published var showTimerRunningView: Bool = false
  @Published var showSettingsView: Bool = false
}
