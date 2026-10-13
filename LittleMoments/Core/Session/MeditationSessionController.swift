import Foundation
import Observation

struct MeditationSession: Equatable, Identifiable, Sendable {
  let id: UUID
  let startDate: Date
  var targetDurationSeconds: Int?

  init(
    id: UUID = UUID(),
    startDate: Date,
    targetDurationSeconds: Int? = nil
  ) {
    self.id = id
    self.startDate = startDate
    self.targetDurationSeconds = targetDurationSeconds
  }
}

@MainActor
@Observable
final class MeditationSessionController {
  private(set) var activeSession: MeditationSession?

  var isRunning: Bool {
    activeSession != nil
  }

  func start(
    at startDate: Date = Date(),
    targetDurationSeconds: Int? = nil
  ) {
    activeSession = MeditationSession(
      startDate: startDate,
      targetDurationSeconds: Self.validatedTarget(targetDurationSeconds)
    )
  }

  func setTarget(durationSeconds: Int?) {
    guard var activeSession else { return }
    activeSession.targetDurationSeconds = Self.validatedTarget(durationSeconds)
    self.activeSession = activeSession
  }

  @discardableResult
  func end() -> MeditationSession? {
    defer { activeSession = nil }
    return activeSession
  }

  func elapsed(at date: Date = Date()) -> TimeInterval {
    guard let activeSession else { return 0 }
    return max(0, date.timeIntervalSince(activeSession.startDate))
  }

  func progress(at date: Date = Date()) -> Double {
    guard
      let targetDurationSeconds = activeSession?.targetDurationSeconds,
      targetDurationSeconds > 0
    else { return 0 }

    return min(elapsed(at: date) / Double(targetDurationSeconds), 1)
  }

  func isDone(at date: Date = Date()) -> Bool {
    guard let targetDurationSeconds = activeSession?.targetDurationSeconds else { return false }
    return elapsed(at: date) >= Double(targetDurationSeconds)
  }

  static func formatElapsed(_ elapsed: TimeInterval, showSeconds: Bool) -> String {
    let fullSeconds = Int(max(0, elapsed))
    let minutes = fullSeconds / 60
    let seconds = fullSeconds % 60

    if showSeconds {
      return String(format: "%d:%02d", minutes, seconds)
    }
    return "\(minutes)"
  }

  private static func validatedTarget(_ durationSeconds: Int?) -> Int? {
    guard let durationSeconds, durationSeconds > 0 else { return nil }
    return durationSeconds
  }
}
