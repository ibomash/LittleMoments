import AppKit
import SwiftUI

enum MacTerminationDecision: Equatable {
  case terminate
  case confirmActiveSession
}

struct MacTerminationPolicy {
  static func decision(isSessionRunning: Bool) -> MacTerminationDecision {
    isSessionRunning ? .confirmActiveSession : .terminate
  }
}

@MainActor
final class MacTerminationCoordinator {
  static let shared = MacTerminationCoordinator()

  private var model: MacSessionModel?
  private var terminationIsApproved = false

  private init() {}

  func attach(model: MacSessionModel) {
    self.model = model
  }

  func applicationShouldTerminate() -> NSApplication.TerminateReply {
    if terminationIsApproved {
      return .terminateNow
    }

    guard let model else { return .terminateNow }
    switch MacTerminationPolicy.decision(isSessionRunning: model.isRunning) {
    case .terminate:
      return .terminateNow
    case .confirmActiveSession:
      return confirmTermination(for: model) ? .terminateNow : .terminateCancel
    }
  }

  func windowShouldClose() -> Bool {
    if terminationIsApproved {
      return true
    }

    guard let model else { return true }
    switch MacTerminationPolicy.decision(isSessionRunning: model.isRunning) {
    case .terminate:
      requestApplicationTermination()
    case .confirmActiveSession:
      if confirmTermination(for: model) {
        requestApplicationTermination()
      }
    }

    return false
  }

  private func confirmTermination(for model: MacSessionModel) -> Bool {
    let alert = NSAlert()
    alert.alertStyle = .warning
    alert.messageText = "A session is still running."
    alert.informativeText =
      "Keep the window open, complete the session and save it, or end it without saving."
    alert.addButton(withTitle: "Keep Open")
    alert.addButton(withTitle: "Complete and Quit")
    alert.addButton(withTitle: "End Session and Quit")
    alert.buttons.last?.hasDestructiveAction = true

    switch alert.runModal() {
    case .alertSecondButtonReturn:
      model.complete()
      terminationIsApproved = true
      return true
    case .alertThirdButtonReturn:
      model.cancel()
      terminationIsApproved = true
      return true
    default:
      return false
    }
  }

  private func requestApplicationTermination() {
    terminationIsApproved = true
    DispatchQueue.main.async {
      NSApp.terminate(nil)
    }
  }
}

@MainActor
struct MainWindowCloseBridge: NSViewRepresentable {
  let coordinator: MacTerminationCoordinator

  func makeCoordinator() -> WindowDelegateCoordinator {
    WindowDelegateCoordinator(terminationCoordinator: coordinator)
  }

  func makeNSView(context: Context) -> WindowReaderView {
    let view = WindowReaderView()
    view.onWindowChange = { window in
      context.coordinator.install(on: window)
    }
    return view
  }

  func updateNSView(_ nsView: WindowReaderView, context: Context) {
    context.coordinator.install(on: nsView.window)
  }

  static func dismantleNSView(_ nsView: WindowReaderView, coordinator: WindowDelegateCoordinator) {
    coordinator.uninstall()
  }
}

@MainActor
final class WindowReaderView: NSView {
  var onWindowChange: ((NSWindow?) -> Void)?

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    onWindowChange?(window)
  }
}

@MainActor
final class WindowDelegateCoordinator: NSObject, NSWindowDelegate {
  private let terminationCoordinator: MacTerminationCoordinator
  private weak var window: NSWindow?
  // AppKit invokes delegate forwarding on the main thread, but NSObject's
  // forwarding hooks are declared nonisolated.
  nonisolated(unsafe) private weak var previousDelegate: NSWindowDelegate?

  init(terminationCoordinator: MacTerminationCoordinator) {
    self.terminationCoordinator = terminationCoordinator
  }

  func install(on window: NSWindow?) {
    guard let window, self.window !== window else { return }
    uninstall()
    self.window = window
    previousDelegate = window.delegate
    window.delegate = self
  }

  func uninstall() {
    guard let window, window.delegate === self else { return }
    window.delegate = previousDelegate
    self.window = nil
    previousDelegate = nil
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    terminationCoordinator.windowShouldClose()
  }

  override func responds(to selector: Selector!) -> Bool {
    super.responds(to: selector) || previousDelegate?.responds(to: selector) == true
  }

  override func forwardingTarget(for selector: Selector!) -> Any? {
    if previousDelegate?.responds(to: selector) == true {
      return previousDelegate
    }
    return super.forwardingTarget(for: selector)
  }
}
