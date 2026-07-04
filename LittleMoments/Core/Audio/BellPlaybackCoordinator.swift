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

  func startSession(startDate: Date, ringBellAtStart _: Bool) {
    sessionStartDate = startDate
    targetPlanID = UUID()
  }

  func setTarget(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval) {
    completionTask?.cancel()
    completionTask = nil
    targetPlanID = UUID()

    guard mode.usesAudioPlayback else {
      stopPlayback(deactivateSession: true)
      return
    }

    guard sessionStartDate != nil, let secondsFromSessionStart else {
      stopPlayback(deactivateSession: true)
      return
    }

    let remainingSeconds = TimeInterval(secondsFromSessionStart) - elapsedSeconds
    guard remainingSeconds > 0 else {
      stopPlayback(deactivateSession: true)
      return
    }

    let planID = targetPlanID

    do {
      try configureAudioSession()
      try startSilentLoop()
    } catch {
      print("Failed to start robust bell silence loop: \(error.localizedDescription)")
      stopPlayback(deactivateSession: true)
      return
    }

    completionTask = Task { [weak self] in
      let nanoseconds = UInt64(max(0, remainingSeconds) * 1_000_000_000)
      try? await Task.sleep(nanoseconds: nanoseconds)

      await MainActor.run {
        guard let self, !Task.isCancelled, self.targetPlanID == planID else { return }
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
  }

  private func startSilentLoop() throws {
    if queuePlayer != nil {
      return
    }

    let silentAudioURL = try silentAudioURL()
    let item = AVPlayerItem(url: silentAudioURL)
    let player = AVQueuePlayer(playerItem: item)
    player.actionAtItemEnd = .none

    queuePlayer = player
    playerLooper = AVPlayerLooper(player: player, templateItem: item)
    player.play()
  }

  private func playCompletionBell() {
    completionTask?.cancel()
    completionTask = nil
    targetPlanID = UUID()
    playerLooper = nil
    queuePlayer?.removeAllItems()

    guard let soundURL = SoundManager.soundURL else {
      print("Could not find bell sound file for robust playback")
      stopPlayback(deactivateSession: true)
      return
    }

    let bellItem = AVPlayerItem(url: soundURL)
    observeCompletion(of: bellItem)
    queuePlayer = AVQueuePlayer(playerItem: bellItem)
    queuePlayer?.play()
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
        self?.stopPlayback(deactivateSession: true)
      }
    }
  }

  private func stopPlayback(deactivateSession: Bool) {
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

    if deactivateSession, isAudioSessionActive {
      do {
        try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        isAudioSessionActive = false
      } catch {
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
    let url = cachesDirectory.appendingPathComponent("little-moments-silence.caf")

    if fileManager.fileExists(atPath: url.path) {
      cachedSilentAudioURL = url
      return url
    }

    guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1),
      let buffer = AVAudioPCMBuffer(
        pcmFormat: format,
        frameCapacity: AVAudioFrameCount(format.sampleRate)
      )
    else {
      throw CocoaError(.fileWriteUnknown)
    }

    buffer.frameLength = buffer.frameCapacity
    let file = try AVAudioFile(forWriting: url, settings: format.settings)
    try file.write(from: buffer)
    cachedSilentAudioURL = url
    return url
  }
}
