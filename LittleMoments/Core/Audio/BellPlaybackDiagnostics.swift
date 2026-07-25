//
//  BellPlaybackDiagnostics.swift
//  Little Moments
//
//  Temporary structured diagnostics for robust completion bell validation.
//

import Foundation
import OSLog

enum BellPlaybackDiagnostics {
  #if DEBUG
    private static let logger = Logger(
      subsystem: "net.bomash.illya.LittleMoments",
      category: "BellPlayback"
    )

    static func sessionStarted(
      startDate: Date,
      mode: BellPlaybackMode,
      ringBellAtStart: Bool
    ) {
      logger.info(
        "session_started mode=\(mode.rawValue, privacy: .public) ring_at_start=\(ringBellAtStart, privacy: .public) start=\(startDate, privacy: .public)"
      )
    }

    static func targetRequested(
      mode: BellPlaybackMode,
      secondsFromSessionStart: Int?,
      elapsedSeconds: TimeInterval
    ) {
      logger.info(
        "target_requested mode=\(mode.rawValue, privacy: .public) target=\(secondsFromSessionStart ?? -1, privacy: .public) elapsed=\(elapsedSeconds, privacy: .public)"
      )
    }

    static func completionPlanScheduled(
      planID: UUID,
      targetSeconds: Int,
      elapsedSeconds: TimeInterval,
      remainingSeconds: TimeInterval
    ) {
      logger.info(
        "completion_plan_scheduled plan=\(planID.uuidString, privacy: .public) target=\(targetSeconds, privacy: .public) elapsed=\(elapsedSeconds, privacy: .public) remaining=\(remainingSeconds, privacy: .public)"
      )
    }

    static func completionPlanCancelled(planID: UUID, reason: String) {
      logger.info(
        "completion_plan_cancelled plan=\(planID.uuidString, privacy: .public) reason=\(reason, privacy: .public)"
      )
    }

    static func completionPlanFired(planID: UUID) {
      logger.info("completion_plan_fired plan=\(planID.uuidString, privacy: .public)")
    }

    static func playbackStopped(deactivateSession: Bool, hadPlayer: Bool, hadTask: Bool) {
      logger.info(
        "playback_stopped deactivate_session=\(deactivateSession, privacy: .public) had_player=\(hadPlayer, privacy: .public) had_task=\(hadTask, privacy: .public)"
      )
    }

    static func audioSessionActivated() {
      logger.info("audio_session_activated")
    }

    static func audioSessionActivationFailed(_ error: Error) {
      logger.error(
        "audio_session_activation_failed error=\(error.localizedDescription, privacy: .public)")
    }

    static func audioSessionDeactivated() {
      logger.info("audio_session_deactivated")
    }

    static func audioSessionDeactivationFailed(_ error: Error) {
      logger.error(
        "audio_session_deactivation_failed error=\(error.localizedDescription, privacy: .public)"
      )
    }

    static func silentLoopStarted(url: URL) {
      logger.info("silent_loop_started url=\(url.lastPathComponent, privacy: .public)")
    }

    static func silentLoopAlreadyRunning() {
      logger.debug("silent_loop_already_running")
    }

    static func silentAudioCreated(url: URL) {
      logger.info("silent_audio_created url=\(url.lastPathComponent, privacy: .public)")
    }

    static func finalBellStarted() {
      logger.info("final_bell_started")
    }

    static func finalBellEnded() {
      logger.info("final_bell_ended")
    }

    static func finalBellMissingSound() {
      logger.error("final_bell_missing_sound")
    }

    static func foregroundBellSuppressed() {
      logger.info("foreground_bell_suppressed")
    }

    static func notificationSkipped(reason: String, mode: BellPlaybackMode? = nil) {
      logger.info(
        "notification_skipped reason=\(reason, privacy: .public) mode=\(mode?.rawValue ?? "none", privacy: .public)"
      )
    }

    static func notificationScheduled(remainingSeconds: TimeInterval, mode: BellPlaybackMode) {
      logger.info(
        "notification_scheduled mode=\(mode.rawValue, privacy: .public) remaining=\(remainingSeconds, privacy: .public)"
      )
    }
  #else
    static func sessionStarted(startDate: Date, mode: BellPlaybackMode, ringBellAtStart: Bool) {}
    static func targetRequested(
      mode: BellPlaybackMode,
      secondsFromSessionStart: Int?,
      elapsedSeconds: TimeInterval
    ) {}
    static func completionPlanScheduled(
      planID: UUID,
      targetSeconds: Int,
      elapsedSeconds: TimeInterval,
      remainingSeconds: TimeInterval
    ) {}
    static func completionPlanCancelled(planID: UUID, reason: String) {}
    static func completionPlanFired(planID: UUID) {}
    static func playbackStopped(deactivateSession: Bool, hadPlayer: Bool, hadTask: Bool) {}
    static func audioSessionActivated() {}
    static func audioSessionActivationFailed(_ error: Error) {}
    static func audioSessionDeactivated() {}
    static func audioSessionDeactivationFailed(_ error: Error) {}
    static func silentLoopStarted(url: URL) {}
    static func silentLoopAlreadyRunning() {}
    static func silentAudioCreated(url: URL) {}
    static func finalBellStarted() {}
    static func finalBellEnded() {}
    static func finalBellMissingSound() {}
    static func foregroundBellSuppressed() {}
    static func notificationSkipped(reason: String, mode: BellPlaybackMode? = nil) {}
    static func notificationScheduled(remainingSeconds: TimeInterval, mode: BellPlaybackMode) {}
  #endif
}
