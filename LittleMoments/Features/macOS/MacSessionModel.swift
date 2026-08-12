import Foundation
import Observation

@MainActor
@Observable
final class MacSessionModel {
  static let presetMinutes = [5, 10, 15, 20, 30, 45, 60]

  private(set) var selectedDurationSeconds: Int?
  private(set) var sessionController: MeditationSessionController
  var errorMessage: String?

  private let historyStore: SessionHistoryStore
  private let userDefaults: UserDefaults
  @ObservationIgnored private var targetBellTask: Task<Void, Never>?

  init(
    sessionController: MeditationSessionController = MeditationSessionController(),
    historyStore: SessionHistoryStore = SessionHistoryStore(usesCloudKit: false),
    userDefaults: UserDefaults = .standard
  ) {
    self.sessionController = sessionController
    self.historyStore = historyStore
    self.userDefaults = userDefaults
  }

  var isRunning: Bool {
    sessionController.isRunning
  }

  var selectedDurationLabel: String {
    Self.durationLabel(seconds: selectedDurationSeconds)
  }

  var targetDate: Date? {
    guard
      let session = sessionController.activeSession,
      let targetDurationSeconds = session.targetDurationSeconds
    else { return nil }

    return session.startDate.addingTimeInterval(TimeInterval(targetDurationSeconds))
  }

  func start(at date: Date = Date()) {
    guard !isRunning else { return }

    sessionController.start(
      at: date,
      targetDurationSeconds: selectedDurationSeconds
    )
    scheduleTargetBell()

    if ringBellAtStart {
      SoundManager.playSound()
    }
  }

  func setDuration(seconds: Int?) {
    selectedDurationSeconds = seconds.flatMap { $0 > 0 ? $0 : nil }

    guard isRunning else { return }
    sessionController.setTarget(durationSeconds: selectedDurationSeconds)
    scheduleTargetBell()
  }

  func complete(at endDate: Date = Date()) {
    guard let session = sessionController.end() else { return }
    targetBellTask?.cancel()
    targetBellTask = nil

    do {
      try historyStore.recordCompletedSession(
        startDate: session.startDate,
        endDate: endDate
      )
    } catch {
      errorMessage = "The session ended, but its history could not be saved."
    }
  }

  func cancel() {
    targetBellTask?.cancel()
    targetBellTask = nil
    sessionController.end()
  }

  func elapsed(at date: Date) -> TimeInterval {
    sessionController.elapsed(at: date)
  }

  func progress(at date: Date) -> Double {
    sessionController.progress(at: date)
  }

  func isDone(at date: Date) -> Bool {
    sessionController.isDone(at: date)
  }

  static func durationLabel(seconds: Int?) -> String {
    guard let seconds else { return "Untimed" }
    let minutes = max(seconds / 60, MeditationDuration.minimumMinutes)
    return (try? MeditationDuration(minutes: minutes))?.shortLabel ?? "\(minutes) min"
  }

  private var ringBellAtStart: Bool {
    guard userDefaults.object(forKey: "ringBellAtStart") != nil else { return true }
    return userDefaults.bool(forKey: "ringBellAtStart")
  }

  private func scheduleTargetBell() {
    targetBellTask?.cancel()
    targetBellTask = nil

    guard
      let session = sessionController.activeSession,
      let targetDurationSeconds = session.targetDurationSeconds
    else { return }

    let sessionID = session.id
    let deadline = session.startDate.addingTimeInterval(TimeInterval(targetDurationSeconds))
    let delay = max(0, deadline.timeIntervalSinceNow)

    targetBellTask = Task { [weak self] in
      do {
        try await Task.sleep(for: .seconds(delay))
      } catch {
        return
      }

      guard
        !Task.isCancelled,
        let self,
        self.sessionController.activeSession?.id == sessionID
      else { return }

      SoundManager.playSound()
    }
  }
}
