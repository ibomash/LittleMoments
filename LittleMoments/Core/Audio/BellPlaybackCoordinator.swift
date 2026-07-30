//
//  BellPlaybackCoordinator.swift
//  Little Moments
//
//  Coordinates robust timed-session bell playback as a projection of timer state.
//

import AVFoundation
import Foundation

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

  private var sessionStartDate: Date?
  private var targetPlanID = UUID()
  private var completionTask: Task<Void, Never>?
  private var queuePlayer: AVQueuePlayer?
  private var playerLooper: AVPlayerLooper?
  private var completionObserver: NSObjectProtocol?
  private var cachedSilentAudioURL: URL?
  private var isAudioSessionActive = false

  var mode: BellPlaybackMode {
    BellPlaybackMode.resolved()
  }

  var shouldSuppressForegroundTimerBell: Bool {
    mode.usesAudioPlayback
  }

  func startSession(startDate: Date, ringBellAtStart: Bool) {
    sessionStartDate = startDate
    targetPlanID = UUID()
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

    targetPlanID = UUID()

    guard mode.usesAudioPlayback else {
      BellPlaybackDiagnostics.notificationSkipped(reason: "mode_does_not_use_audio", mode: mode)
      stopPlayback(deactivateSession: true)
      return
    }

    guard let sessionStartDate, let secondsFromSessionStart else {
      stopPlayback(deactivateSession: true)
      return
    }

    let deadline = sessionStartDate.addingTimeInterval(TimeInterval(secondsFromSessionStart))
    let remainingSeconds = Self.remainingSeconds(until: deadline)
    guard remainingSeconds > 0 else {
      BellPlaybackDiagnostics.completionPlanCancelled(
        planID: targetPlanID, reason: "target_elapsed")
      stopPlayback(deactivateSession: true)
      return
    }

    let planID = targetPlanID
    guard startPlaybackPlan() else { return }
    let adjustedRemainingSeconds = Self.remainingSeconds(until: deadline)

    BellPlaybackDiagnostics.completionPlanScheduled(
      planID: planID,
      targetSeconds: secondsFromSessionStart,
      elapsedSeconds: elapsedSeconds,
      remainingSeconds: adjustedRemainingSeconds
    )
    scheduleCompletionBell(planID: planID, remainingSeconds: adjustedRemainingSeconds)
  }

  static func remainingSeconds(until deadline: Date, now: Date = Date()) -> TimeInterval {
    max(0, deadline.timeIntervalSince(now))
  }

  private func cancelCompletionTask(reason: String) {
    if completionTask != nil {
      BellPlaybackDiagnostics.completionPlanCancelled(planID: targetPlanID, reason: reason)
    }
    completionTask?.cancel()
    completionTask = nil
  }

  private func startPlaybackPlan() -> Bool {
    do {
      try configureAudioSession()
      try startSilentLoop()
      return true
    } catch {
      BellPlaybackDiagnostics.audioSessionActivationFailed(error)
      print("Failed to start robust bell silence loop: \(error.localizedDescription)")
      stopPlayback(deactivateSession: true)
      return false
    }
  }

  private func scheduleCompletionBell(planID: UUID, remainingSeconds: TimeInterval) {
    completionTask = Task { [weak self] in
      let nanoseconds = UInt64(max(0, remainingSeconds) * 1_000_000_000)
      try? await Task.sleep(nanoseconds: nanoseconds)

      await MainActor.run {
        guard let self, !Task.isCancelled, self.targetPlanID == planID else { return }
        BellPlaybackDiagnostics.completionPlanFired(planID: planID)
        self.playCompletionBell()
      }
    }
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

  private func playCompletionBell() {
    completionTask?.cancel()
    completionTask = nil
    targetPlanID = UUID()
    playerLooper?.disableLooping()
    playerLooper = nil

    guard let soundURL = SoundManager.soundURL else {
      BellPlaybackDiagnostics.finalBellMissingSound()
      print("Could not find bell sound file for robust playback")
      stopPlayback(deactivateSession: true)
      return
    }

    guard let queuePlayer else {
      BellPlaybackDiagnostics.finalBellQueueUnavailable()
      print("Could not play robust completion bell because the audio queue was unavailable")
      stopPlayback(deactivateSession: true)
      return
    }

    let bellItem = AVPlayerItem(url: soundURL)
    guard Self.replaceQueueContents(with: bellItem, in: queuePlayer) else {
      BellPlaybackDiagnostics.finalBellQueueTransitionFailed()
      print("Could not insert robust completion bell into the active audio queue")
      stopPlayback(deactivateSession: true)
      return
    }

    observeCompletion(of: bellItem)
    queuePlayer.play()
    BellPlaybackDiagnostics.finalBellStarted(
      playerStatus: queuePlayer.status,
      timeControlStatus: queuePlayer.timeControlStatus,
      itemStatus: bellItem.status
    )
    scheduleFinalBellProgressCheck(player: queuePlayer, item: bellItem)
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

  private func scheduleFinalBellProgressCheck(
    player: AVQueuePlayer,
    item: AVPlayerItem
  ) {
    Task { [weak self, weak player, weak item] in
      try? await Task.sleep(for: .seconds(1))

      guard
        let self,
        let player,
        let item,
        self.queuePlayer === player,
        player.currentItem === item
      else { return }

      BellPlaybackDiagnostics.finalBellProgressChecked(
        BellPlaybackDiagnostics.FinalBellPlaybackState(
          elapsedSeconds: player.currentTime().seconds,
          playerStatus: player.status.rawValue,
          timeControlStatus: player.timeControlStatus.rawValue,
          itemStatus: item.status.rawValue,
          waitingReason: player.reasonForWaitingToPlay?.rawValue,
          playerError: player.error?.localizedDescription,
          itemError: item.error?.localizedDescription
        )
      )
    }
  }

  private func observeCompletion(of item: AVPlayerItem) {
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
        self?.stopPlayback(deactivateSession: true)
      }
    }
  }

  private func stopPlayback(deactivateSession: Bool) {
    let hadTask = completionTask != nil
    let hadPlayer = queuePlayer != nil
    completionTask?.cancel()
    completionTask = nil
    targetPlanID = UUID()
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
