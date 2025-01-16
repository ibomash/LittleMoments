import SwiftUI

class AppState: ObservableObject {
  static let shared = AppState()
  @Published var showTimerRunningView: Bool = false
  @Published var showSettingsView: Bool = false
}
