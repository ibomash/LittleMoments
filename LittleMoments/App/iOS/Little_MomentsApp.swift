//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import ActivityKit
import OSLog
import SwiftData
import SwiftUI
import UIKit

// Keep track of the active timer view model for deep link handling
@MainActor private var activeTimerViewModel: Any?
// Global flag to track if a session was recently canceled, to prevent race conditions
@MainActor private var sessionWasRecentlyCanceled = false
@MainActor private var lastCancelationTime: Date?

@main
struct LittleMomentsApp: App {
  @StateObject private var appState = AppState.shared
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(LittleMomentsAppDelegate.self) private var appDelegate
  private let controlsLogger = Logger(
    subsystem: "net.bomash.illya.LittleMoments", category: "Controls")

  static let quickSessionShortcutType = "net.bomash.illya.LittleMoments.startQuickSession"
  static let quickSessionDurationUserInfoKey = "duration"
  static let quickSessionDefaultDurationSeconds = 300

  init() {
    SoundManager.initialize()

    let arguments = ProcessInfo.processInfo.arguments
    if arguments.contains("-RESET_SESSION_HISTORY_FOR_TESTS") {
      try? SessionHistoryStore.shared.purgeAllEntries()
    }

    if arguments.contains("-SEED_SESSION_HISTORY_FOR_TESTS") {
      let endDate = Date()
      let startDate = endDate.addingTimeInterval(-60)
      _ = try? SessionHistoryStore.shared.recordCompletedSession(
        startDate: startDate,
        endDate: endDate
      )
    }
  }

  var body: some Scene {
    WindowGroup {
      TimerStartView()
        .task {
          await HealthWriteCoordinator.shared.triggerProcessing(.appLaunch)
        }
        .onOpenURL { url in
          controlsLogger.notice("onOpenURL fired with: \(url.absoluteString, privacy: .public)")
          handleDeepLink(url: url)
        }
        .onChange(of: scenePhase) { _, newPhase in
          switch newPhase {
          case .active:
            controlsLogger.notice("App became active (possible Control tap -> OpenAppIntent)")
            Task {
              await HealthWriteCoordinator.shared.triggerProcessing(.appBecameActive)
            }
          case .background:
            controlsLogger.debug("App moved to background")
          case .inactive:
            controlsLogger.debug("App became inactive")
          @unknown default:
            controlsLogger.debug("App scenePhase unknown state")
          }
        }
        .modelContainer(SessionHistoryStore.shared.modelContainer)
    }
  }

  func onExitCommand() {
    SoundManager.dispose()
  }

  // swiftlint:disable function_body_length
  @MainActor
  func handleDeepLink(url: URL) {
    print("📲 Received deep link: \(url)")
    print("📲 URL scheme: \(url.scheme ?? "nil"), host: \(url.host ?? "nil"), path: \(url.path)")

    guard url.scheme == "littlemoments" else {
      print("❌ Deep link ignored - wrong scheme: \(url.scheme ?? "nil")")
      return
    }

    if url.host == "finishSession" {
      print("📲 Processing finishSession deep link")

      // Check if we've recently received a cancel notification
      if sessionWasRecentlyCanceled {
        print("⛔️ BLOCKED finishSession - session was recently canceled")

        // Extra protection: Check timestamp if available
        if let lastCancel = lastCancelationTime {
          let timeGap = Date().timeIntervalSince(lastCancel)
          print("⛔️ Cancel happened \(String(format: "%.2f", timeGap)) seconds ago")
        }

        // Still close the view if needed
        if appState.showTimerRunningView {
          print("📲 Closing timer view (but NOT saving to HealthKit)")
          appState.showTimerRunningView = false
        }

        return
      }

      // Complete the current session if there is one active
      if appState.showTimerRunningView {
        print("📲 Timer is active - preparing to finish session via deep link")
        // First try to get an active timer view model to prepare the session
        // This ensures we capture the startDate before we close the view
        if let activeTimerVC = getActiveTimerViewController(),
          let timerRunningView = findTimerRunningView(in: activeTimerVC)
        {
          // Access the timer view model directly
          timerRunningView.timerViewModel.prepareSessionForFinish()

          print("📲 Recording completed session from deep link")
          timerRunningView.timerViewModel.recordCompletedSession()

          // Provide haptic feedback for successful session completion
          print("📲 Providing haptic feedback for session completion")
          LiveActivityManager.shared.provideSessionCompletionFeedback()

          print("📲 Found active timer view model - session data saved")
        } else {
          print("⚠️ Could not access timer view model directly - will try via notification")
        }

        // Post a notification to finish the session
        // Other components will observe this notification
        print("📲 Posting finishSession notification")
        NotificationCenter.default.post(
          name: Notification.Name("com.littlemoments.finishSession"),
          object: nil
        )

        // Close the timer view
        print("📲 Closing timer view")
        appState.showTimerRunningView = false
      } else {
        print("⚠️ Received finishSession deep link, but no active timer session found")
      }
    } else if url.host == "cancelSession" || url.host == "cancel" || url.path == "/cancel" {
      print("📲 Processing cancel request from Live Activity")
      // Cancel the current session if there is one active
      if appState.showTimerRunningView {
        // Set the global cancellation flag
        sessionWasRecentlyCanceled = true
        lastCancelationTime = Date()

        // For cancellation, we want to make sure we don't accidentally save to HealthKit
        // Post a notification that will be observed by the timer view model
        print("📲 Posting cancelSession notification")
        NotificationCenter.default.post(
          name: Notification.Name("com.littlemoments.cancelSession"),
          object: nil
        )

        // Close the timer view
        print("📲 Closing timer view (session will NOT be saved to HealthKit)")
        appState.showTimerRunningView = false

        // Reset the cancel flag after a delay (as a safety measure)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
          sessionWasRecentlyCanceled = false
        }
      } else {
        print("⚠️ Received cancel request, but no active timer session found")
      }
    } else if url.host == "startSession" || url.host == "start" || url.path == "/start" {
      print("📲 Processing startSession deep link")

      if appState.showTimerRunningView {
        print("⚠️ Start request ignored - session already running")
        return
      }

      // Parse optional duration query item (seconds). Accept forms like "60", "60s", "1m".
      if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
        let items = comps.queryItems
      {
        if let durationString = items.first(where: { $0.name.lowercased() == "duration" })?.value {
          let seconds = Self.parseDurationToSeconds(durationString)
          if let seconds {
            print("📲 Will start with preset duration: \(seconds) sec")
            AppState.shared.pendingStartDurationSeconds = seconds
          }
        }
      }
      // Present the running timer view immediately
      appState.showTimerRunningView = true
    } else {
      print("❌ Unknown deep link host: \(url.host ?? "nil")")
    }
  }
  // swiftlint:enable function_body_length

  // MARK: - Helpers
  @MainActor
  static func handleHomeScreenQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
    guard shortcutItem.type == quickSessionShortcutType else {
      print("❌ Quick action ignored - unknown type: \(shortcutItem.type)")
      return false
    }

    if AppState.shared.showTimerRunningView {
      print("⚠️ Quick action ignored - session already running")
      return true
    }

    let durationSeconds = quickActionDurationSeconds(from: shortcutItem)
    AppState.shared.pendingStartDurationSeconds = durationSeconds
    AppState.shared.showTimerRunningView = true

    print("📲 Quick action started session with preset duration: \(durationSeconds) sec")
    return true
  }

  static func quickActionDurationSeconds(from shortcutItem: UIApplicationShortcutItem) -> Int {
    guard let rawValue = shortcutItem.userInfo?[quickSessionDurationUserInfoKey] else {
      return quickSessionDefaultDurationSeconds
    }

    if let number = rawValue as? NSNumber, number.intValue > 0 {
      return number.intValue
    }

    if let stringValue = rawValue as? NSString,
      let seconds = parseDurationToSeconds(String(stringValue)),
      seconds > 0
    {
      return seconds
    }

    return quickSessionDefaultDurationSeconds
  }

  static func parseDurationToSeconds(_ raw: String) -> Int? {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if trimmed.hasSuffix("m"), let minutes = Int(trimmed.dropLast()) {
      return minutes * 60
    }
    if trimmed.hasSuffix("s"), let sec = Int(trimmed.dropLast()) {
      return sec
    }
    if let sec = Int(trimmed) { return sec }
    return nil
  }

  // Helper method to find the active timer view controller
  func getActiveTimerViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let rootViewController = windowScene.windows.first?.rootViewController
    else {
      return nil
    }

    // Check for presented view controller
    if let presentedVC = rootViewController.presentedViewController {
      return presentedVC
    }

    return nil
  }

  // Helper method to find TimerRunningView in a view controller's view hierarchy
  func findTimerRunningView(in viewController: UIViewController) -> TimerRunningView? {
    // This is a simplification since we can't directly inspect SwiftUI view hierarchy
    // In a real implementation, we would need a more robust approach
    // that might involve a shared state object or other architectural patterns
    return nil
  }
}
