import AppKit
import SwiftUI

@main
@MainActor
struct LittleMomentsMacApp: App {
  @NSApplicationDelegateAdaptor(LittleMomentsMacAppDelegate.self) private var appDelegate
  @State private var model = MacSessionModel()

  init() {
    SoundManager.initialize()
  }

  var body: some Scene {
    Window("Little Moments", id: "main") {
      MacTimerRootView(model: model)
    }
    .defaultSize(width: 460, height: 560)
    .windowResizability(.contentMinSize)
    .commands {
      MacSessionCommands(model: model)
    }

    Settings {
      MacSettingsView()
    }
  }
}

@MainActor
private struct MacSessionCommands: Commands {
  let model: MacSessionModel

  var body: some Commands {
    CommandMenu("Session") {
      if model.isRunning {
        Button("Complete Session") {
          model.complete()
        }
        .keyboardShortcut(.return, modifiers: [.command])

        Button("Cancel Session", role: .destructive) {
          model.cancel()
        }
      } else {
        Button("Start Session") {
          model.start()
        }
        .keyboardShortcut(.return, modifiers: [.command])
      }
    }
  }
}

@MainActor
final class LittleMomentsMacAppDelegate: NSObject, NSApplicationDelegate {
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    MacTerminationCoordinator.shared.applicationShouldTerminate()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    true
  }

  func applicationWillTerminate(_ notification: Notification) {
    SoundManager.dispose()
  }
}
