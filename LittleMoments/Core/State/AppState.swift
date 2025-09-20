import SwiftUI

@MainActor
public final class AppState: ObservableObject {
  public static let shared = AppState()

  // Make initializer private to enforce singleton pattern
  private init() {
    resetState()
  }

  // Method to reset state for testing purposes
  public func resetState() {
    showTimerRunningView = false
    showSettingsView = false
    pendingStartDurationSeconds = nil
  }

  @Published public var showTimerRunningView: Bool = false
  @Published public var showSettingsView: Bool = false
  // If set, TimerRunningView will preselect a duration when it appears
  @Published public var pendingStartDurationSeconds: Int?
}
