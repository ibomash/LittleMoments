//
//  BellPlaybackCoordinator.swift
//  Little Moments
//
//  Coordinates robust timed-session bell playback as a projection of timer state.
//

import AVFoundation
import Foundation
import UIKit

enum BellPlaybackMode: String, CaseIterable {
  case off
  case audioOnly
  case notificationOnly
  case hybrid

  var usesAudioPlayback: Bool {
    self == .audioOnly || self == .hybrid
  }

  var schedulesNotifications: Bool {
    self == .notificationOnly || self == .hybrid
  }

  static func resolved(
    arguments: [String] = ProcessInfo.processInfo.arguments,
    environment: [String: String] = ProcessInfo.processInfo.environment,
    userDefaults: UserDefaults = .standard
  ) -> BellPlaybackMode {
    if arguments.contains("-DISABLE_SYSTEM_INTEGRATIONS") {
      return .off
    }

    if let mode = modeFromLaunchArguments(arguments) {
      return mode
    }

    if environment["XCTestConfigurationFilePath"] != nil {
      return .off
    }

    if let rawValue = userDefaults.string(forKey: "robustBellPlaybackMode"),
      let mode = normalizedMode(rawValue)
    {
      return mode
    }

    return .hybrid
  }

  private static func modeFromLaunchArguments(_ arguments: [String]) -> BellPlaybackMode? {
    for (index, argument) in arguments.enumerated() {
      if argument == "-ROBUST_BELL_PLAYBACK_MODE",
        index + 1 < arguments.count,
        let mode = normalizedMode(arguments[index + 1])
      {
        return mode
      }

      if argument.hasPrefix("-ROBUST_BELL_PLAYBACK_MODE=") {
        let rawValue = String(argument.dropFirst("-ROBUST_BELL_PLAYBACK_MODE=".count))
        if let mode = normalizedMode(rawValue) {
          return mode
        }
      }
    }

    return nil
  }

  private static func normalizedMode(_ rawValue: String) -> BellPlaybackMode? {
    let normalized =
      rawValue
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "-", with: "")
      .replacingOccurrences(of: "_", with: "")
      .lowercased()

    switch normalized {
    case "off":
      return .off
    case "audioonly":
      return .audioOnly
    case "notificationonly":
      return .notificationOnly
    case "hybrid":
      return .hybrid
    default:
      return nil
    }
  }
}

@MainActor
protocol BellPlaybackCoordinating: AnyObject {
  var mode: BellPlaybackMode { get }

  func startSession(startDate: Date, ringBellAtStart: Bool)
  func setTarget(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval)
  func ensureCompletionBellAudible(elapsedSeconds: TimeInterval)
  func finishSession()
  func cancelSession()
}

extension BellPlaybackCoordinating {
  var usesAudioPlayback: Bool {
    mode.usesAudioPlayback
  }

  var schedulesNotifications: Bool {
    mode.schedulesNotifications
  }
}

@MainActor
final class BellPlaybackCoordinator: BellPlaybackCoordinating {
  static let shared = BellPlaybackCoordinator()

  private static let silentLoopDurationSeconds: Double = 60
  private static let foregroundFallbackGraceSeconds: TimeInterval = 0.5
  private static let minimumConfirmedBellProgressSeconds: TimeInterval = 0.05
  private static let maximumForegroundFallbackDelaySeconds: TimeInterval = 5

  private var sessionStartDate: Date?
  private var watchdogState = CompletionBellWatchdogState()
  private var targetSecondsFromSessionStart: Int?
  private var completionTask: Task<Void, Never>?
  private var fallbackWatchdogTask: Task<Void, Never>?
  private var queuePlayer: AVQueuePlayer?
  private var playerLooper: AVPlayerLooper?
  private var completionBellItem: AVPlayerItem?
  private var completionBellPlanID: UUID?
  private var completionBellAttemptDate: Date?
  private var completionObserver: NSObjectProtocol?
  private var cachedSilentAudioURL: URL?
  private var isAudioSessionActive = false

  private let applicationIsActive: @MainActor () -> Bool
  private let foregroundBellPlayer: @MainActor () -> Bool

  init(
    applicationIsActive: @escaping @MainActor () -> Bool = {
      UIApplication.shared.connectedScenes.contains {
        $0.activationState == .foregroundActive
      }
    },
    foregroundBellPlayer: @escaping @MainActor () -> Bool = {
      SoundManager.playSound()
    }
  ) {
    self.applicationIsActive = applicationIsActive
    self.foregroundBellPlayer = foregroundBellPlayer
  }

  var mode: BellPlaybackMode {
    BellPlaybackMode.resolved()
  }

  func startSession(startDate: Date, ringBellAtStart: Bool) {
    sessionStartDate = startDate
    _ = watchdogState.replacePlan()
    targetSecondsFromSessionStart = nil
    BellPlaybackDiagnostics.sessionStarted(
      startDate: startDate,
      mode: mode,
      ringBellAtStart: ringBellAtStart
    )
  }

  func setTarget(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval) {
    cancelCompletionTask(reason: "target_replaced")
    BellPlaybackDiagnostics.targetRequested(
      mode: mode,
      secondsFromSessionStart: secondsFromSessionStart,
      elapsedSeconds: elapsedSeconds
    )

    let planID = watchdogState.replacePlan()
    targetSecondsFromSessionStart = secondsFromSessionStart
    clearCompletionBellState()

    guard mode.usesAudioPlayback else {
      BellPlaybackDiagnostics.notificationSkipped(reason: "mode_does_not_use_audio", mode: mode)
      stopPlayback(deactivateSession: true, invalidatePlan: false)
      return
    }

    guard sessionStartDate != nil, let secondsFromSessionStart else {
      stopPlayback(deactivateSession: true)
      return
    }

    let remainingSeconds = TimeInterval(secondsFromSessionStart) - elapsedSeconds
    guard remainingSeconds > 0 else {
      BellPlaybackDiagnostics.completionPlanCancelled(
        planID: planID, reason: "target_elapsed")
      stopPlayback(deactivateSession: true)
      return
    }

    guard startPlaybackPlan() else { return }

    BellPlaybackDiagnostics.completionPlanScheduled(
      planID: planID,
      targetSeconds: secondsFromSessionStart,
      elapsedSeconds: elapsedSeconds,
      remainingSeconds: remainingSeconds
    )
    scheduleCompletionBell(planID: planID, remainingSeconds: remainingSeconds)
  }

  private func cancelCompletionTask(reason: String) {
    if completionTask != nil {
      BellPlaybackDiagnostics.completionPlanCancelled(planID: watchdogState.planID, reason: reason)
    }
    completionTask?.cancel()
    completionTask = nil
    fallbackWatchdogTask?.cancel()
    fallbackWatchdogTask = nil
  }

  private func startPlaybackPlan() -> Bool {
    do {
      try configureAudioSession()
      try startSilentLoop()
      return true
    } catch {
      BellPlaybackDiagnostics.audioSessionActivationFailed(error)
      print("Failed to start robust bell silence loop: \(error.localizedDescription)")
      stopPlayback(deactivateSession: true, invalidatePlan: false)
      return false
    }
  }

  private func scheduleCompletionBell(planID: UUID, remainingSeconds: TimeInterval) {
    completionTask = Task { [weak self] in
      let nanoseconds = UInt64(max(0, remainingSeconds) * 1_000_000_000)
      do {
        try await Task.sleep(nanoseconds: nanoseconds)
      } catch {
        return
      }
      guard !Task.isCancelled else { return }

      await MainActor.run {
        guard let self else { return }
        guard self.watchdogState.planID == planID else {
          BellPlaybackDiagnostics.foregroundFallbackSkipped(reason: "stale_plan")
          return
        }
        BellPlaybackDiagnostics.completionPlanFired(planID: planID)
        self.playCompletionBell(planID: planID)
      }
    }
  }

  func ensureCompletionBellAudible(elapsedSeconds: TimeInterval) {
    guard
      let targetSecondsFromSessionStart,
      elapsedSeconds >= TimeInterval(targetSecondsFromSessionStart),
      elapsedSeconds - TimeInterval(targetSecondsFromSessionStart)
        <= Self.maximumForegroundFallbackDelaySeconds
    else { return }

    let planID = watchdogState.planID
    guard mode.usesAudioPlayback else {
      startForegroundFallbackIfNeeded(planID: planID, progressSeconds: nil)
      return
    }

    if completionBellPlanID == planID, let completionBellItem {
      guard
        let completionBellAttemptDate,
        Date().timeIntervalSince(completionBellAttemptDate)
          >= Self.foregroundFallbackGraceSeconds
      else { return }

      evaluateForegroundFallback(
        planID: planID,
        player: queuePlayer,
        item: completionBellItem
      )
      return
    }

    completionTask?.cancel()
    completionTask = nil
    playCompletionBell(planID: planID)
  }

  func finishSession() {
    stopPlayback(deactivateSession: true)
    sessionStartDate = nil
  }

  func cancelSession() {
    stopPlayback(deactivateSession: true)
    sessionStartDate = nil
  }

  private func configureAudioSession() throws {
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playback)
    try audioSession.setActive(true)
    isAudioSessionActive = true
    BellPlaybackDiagnostics.audioSessionActivated()
  }

  private func startSilentLoop() throws {
    if queuePlayer != nil {
      BellPlaybackDiagnostics.silentLoopAlreadyRunning()
      return
    }

    let silentAudioURL = try silentAudioURL()
    let item = AVPlayerItem(url: silentAudioURL)
    let player = AVQueuePlayer(playerItem: item)
    player.actionAtItemEnd = .none

    queuePlayer = player
    playerLooper = AVPlayerLooper(player: player, templateItem: item)
    player.play()
    BellPlaybackDiagnostics.silentLoopStarted(url: silentAudioURL)
  }

  private func playCompletionBell(planID: UUID) {
    guard watchdogState.planID == planID else {
      BellPlaybackDiagnostics.foregroundFallbackSkipped(reason: "stale_plan")
      return
    }

    completionTask?.cancel()
    completionTask = nil
    playerLooper?.disableLooping()
    playerLooper = nil

    guard let soundURL = SoundManager.soundURL else {
      BellPlaybackDiagnostics.finalBellMissingSound()
      print("Could not find bell sound file for robust playback")
      stopPlayback(deactivateSession: true, invalidatePlan: false)
      startForegroundFallbackIfNeeded(planID: planID, progressSeconds: nil)
      return
    }

    guard let queuePlayer else {
      BellPlaybackDiagnostics.finalBellQueueUnavailable()
      print("Could not play robust completion bell because the audio queue was unavailable")
      stopPlayback(deactivateSession: true, invalidatePlan: false)
      startForegroundFallbackIfNeeded(planID: planID, progressSeconds: nil)
      return
    }

    let bellItem = AVPlayerItem(url: soundURL)
    guard Self.replaceQueueContents(with: bellItem, in: queuePlayer) else {
      BellPlaybackDiagnostics.finalBellQueueTransitionFailed()
      print("Could not insert robust completion bell into the active audio queue")
      stopPlayback(deactivateSession: true, invalidatePlan: false)
      startForegroundFallbackIfNeeded(planID: planID, progressSeconds: nil)
      return
    }

    completionBellItem = bellItem
    completionBellPlanID = planID
    completionBellAttemptDate = Date()
    observeCompletion(of: bellItem, planID: planID)
    queuePlayer.play()
    BellPlaybackDiagnostics.finalBellStarted(
      playerStatus: queuePlayer.status,
      timeControlStatus: queuePlayer.timeControlStatus,
      itemStatus: bellItem.status
    )
    scheduleForegroundFallbackWatchdog(planID: planID, player: queuePlayer, item: bellItem)
  }

  @discardableResult
  static func replaceQueueContents(
    with item: AVPlayerItem,
    in player: AVQueuePlayer
  ) -> Bool {
    player.removeAllItems()
    guard player.canInsert(item, after: nil) else { return false }
    player.insert(item, after: nil)
    return true
  }

  private func scheduleForegroundFallbackWatchdog(
    planID: UUID,
    player: AVQueuePlayer,
    item: AVPlayerItem
  ) {
    fallbackWatchdogTask?.cancel()
    fallbackWatchdogTask = Task { [weak self, weak player, weak item] in
      try? await Task.sleep(for: .seconds(Self.foregroundFallbackGraceSeconds))

      guard
        !Task.isCancelled,
        let self,
        let player,
        let item
      else { return }

      self.evaluateForegroundFallback(planID: planID, player: player, item: item)
    }
  }

  private func evaluateForegroundFallback(
    planID: UUID,
    player: AVQueuePlayer?,
    item: AVPlayerItem
  ) {
    let progressSeconds: TimeInterval?
    if let player,
      queuePlayer === player,
      player.currentItem === item,
      completionBellItem === item,
      completionBellPlanID == planID
    {
      progressSeconds = player.currentTime().seconds
      BellPlaybackDiagnostics.finalBellProgressChecked(
        BellPlaybackDiagnostics.FinalBellPlaybackState(
          elapsedSeconds: progressSeconds ?? .nan,
          playerStatus: player.status.rawValue,
          timeControlStatus: player.timeControlStatus.rawValue,
          itemStatus: item.status.rawValue,
          waitingReason: player.reasonForWaitingToPlay?.rawValue,
          playerError: player.error?.localizedDescription,
          itemError: item.error?.localizedDescription
        )
      )
    } else {
      progressSeconds = nil
    }

    startForegroundFallbackIfNeeded(planID: planID, progressSeconds: progressSeconds)
  }

  private func startForegroundFallbackIfNeeded(
    planID: UUID,
    progressSeconds: TimeInterval?
  ) {
    let isActive = applicationIsActive()
    guard
      watchdogState.claimFallback(
        planID: planID,
        progressSeconds: progressSeconds,
        minimumConfirmedProgressSeconds: Self.minimumConfirmedBellProgressSeconds,
        applicationIsActive: isActive
      )
    else {
      let reason: String
      if planID != watchdogState.planID {
        reason = "stale_plan"
      } else if !isActive {
        reason = "application_inactive"
      } else if watchdogState.fallbackPlanID == planID {
        reason = "already_started"
      } else {
        reason = "primary_progress_confirmed"
      }
      BellPlaybackDiagnostics.foregroundFallbackSkipped(reason: reason)
      return
    }

    let didStart = foregroundBellPlayer()
    BellPlaybackDiagnostics.foregroundFallbackStarted(didStart: didStart)
  }

  private func observeCompletion(of item: AVPlayerItem, planID: UUID) {
    if let completionObserver {
      NotificationCenter.default.removeObserver(completionObserver)
    }

    completionObserver = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: item,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        BellPlaybackDiagnostics.finalBellEnded()
        guard let self else { return }
        let foregroundFallbackIsPlaying = self.watchdogState.fallbackPlanID == planID
        self.stopPlayback(deactivateSession: !foregroundFallbackIsPlaying)
      }
    }
  }

  private func stopPlayback(deactivateSession: Bool, invalidatePlan: Bool = true) {
    let hadTask = completionTask != nil
    let hadPlayer = queuePlayer != nil
    completionTask?.cancel()
    completionTask = nil
    fallbackWatchdogTask?.cancel()
    fallbackWatchdogTask = nil
    if invalidatePlan {
      _ = watchdogState.replacePlan()
      targetSecondsFromSessionStart = nil
    }
    clearCompletionBellState()
    playerLooper = nil
    queuePlayer?.pause()
    queuePlayer?.removeAllItems()
    queuePlayer = nil

    if let completionObserver {
      NotificationCenter.default.removeObserver(completionObserver)
      self.completionObserver = nil
    }

    BellPlaybackDiagnostics.playbackStopped(
      deactivateSession: deactivateSession,
      hadPlayer: hadPlayer,
      hadTask: hadTask
    )

    if deactivateSession, isAudioSessionActive {
      do {
        try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isAudioSessionActive = false
        BellPlaybackDiagnostics.audioSessionDeactivated()
      } catch {
        BellPlaybackDiagnostics.audioSessionDeactivationFailed(error)
        print("Failed to deactivate robust bell audio session: \(error.localizedDescription)")
      }
    }
  }

  private func clearCompletionBellState() {
    completionBellItem = nil
    completionBellPlanID = nil
    completionBellAttemptDate = nil
  }

  private func silentAudioURL() throws -> URL {
    if let cachedSilentAudioURL {
      return cachedSilentAudioURL
    }

    let fileManager = FileManager.default
    let cachesDirectory = try fileManager.url(
      for: .cachesDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    let url = cachesDirectory.appendingPathComponent("little-moments-silence-60s.caf")

    if fileManager.fileExists(atPath: url.path) {
      cachedSilentAudioURL = url
      return url
    }

    guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1),
      let buffer = AVAudioPCMBuffer(
        pcmFormat: format,
        frameCapacity: AVAudioFrameCount(
          format.sampleRate * Self.silentLoopDurationSeconds
        )
      )
    else {
      throw CocoaError(.fileWriteUnknown)
    }

    buffer.frameLength = buffer.frameCapacity
    let file = try AVAudioFile(forWriting: url, settings: format.settings)
    try file.write(from: buffer)
    cachedSilentAudioURL = url
    BellPlaybackDiagnostics.silentAudioCreated(url: url)
    return url
  }
}

struct CompletionBellWatchdogState {
  private(set) var planID = UUID()
  private(set) var fallbackPlanID: UUID?

  @discardableResult
  mutating func replacePlan() -> UUID {
    planID = UUID()
    fallbackPlanID = nil
    return planID
  }

  mutating func claimFallback(
    planID candidatePlanID: UUID,
    progressSeconds: TimeInterval?,
    minimumConfirmedProgressSeconds: TimeInterval,
    applicationIsActive: Bool
  ) -> Bool {
    guard candidatePlanID == planID else { return false }
    guard applicationIsActive else { return false }
    guard fallbackPlanID != candidatePlanID else { return false }

    if let progressSeconds,
      progressSeconds.isFinite,
      progressSeconds >= minimumConfirmedProgressSeconds
    {
      return false
    }

    fallbackPlanID = candidatePlanID
    return true
  }
}
