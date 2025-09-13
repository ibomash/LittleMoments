//
//  NotificationManager.swift
//  Little Moments
//
//  Created for Swift 6 concurrency compliance
//

import Foundation
import UserNotifications

/// A Swift 6 concurrency-safe notification manager that handles authorization and scheduling
/// without MainActor violations. This follows Option B from the MainActor crash specs.
@MainActor
final class NotificationManager {
  static let shared = NotificationManager()

  private init() {}

  /// Request notification authorization using async/await (Swift 6 safe)
  /// - Parameter options: The notification authorization options
  /// - Returns: A tuple indicating if authorization was granted and any error
  func requestAuthorization(
    options: UNAuthorizationOptions = [.alert, .sound]
  ) async -> (granted: Bool, error: Error?) {
    let center = UNUserNotificationCenter.current()

    do {
      let granted = try await center.requestAuthorization(options: options)
      return (granted, nil)
    } catch {
      return (false, error)
    }
  }

  /// Check current notification authorization status
  /// - Returns: The current authorization status
  func getAuthorizationStatus() async -> UNAuthorizationStatus {
    let center = UNUserNotificationCenter.current()
    return await withCheckedContinuation { continuation in
      center.getNotificationSettings { @Sendable settings in
        continuation.resume(returning: settings.authorizationStatus)
      }
    }
  }

  /// Request authorization only if not yet determined (Swift 6 safe)
  func requestAuthorizationIfNeeded() async {
    let status = await getAuthorizationStatus()
    guard status == .notDetermined else { return }

    _ = await requestAuthorization()
  }

  /// Schedule a timer notification (non-isolated, safe to call from background)
  nonisolated func scheduleTimerNotification(
    identifier: String,
    title: String,
    body: String,
    soundName: String,
    timeInterval: TimeInterval
  ) async throws {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
    content.interruptionLevel = .timeSensitive

    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: timeInterval,
      repeats: false
    )

    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )

    try await center.add(request)
  }

  /// Remove all pending notifications (non-isolated)
  nonisolated func removeAllPendingNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
}
