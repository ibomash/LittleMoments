import Foundation

struct MeditationDuration: Equatable {
  static let minimumMinutes = 1
  static let sliderMinimumMinutes = 1
  static let sliderMaximumMinutes = 60

  enum ValidationError: LocalizedError, Equatable {
    case empty
    case notWholeMinutes
    case belowMinimum

    var errorDescription: String? {
      switch self {
      case .empty:
        return "Add a duration before applying."
      case .notWholeMinutes:
        return "Enter whole minutes."
      case .belowMinimum:
        return "Enter at least 1 minute."
      }
    }
  }

  let minutes: Int

  static let uncheckedMinimum = MeditationDuration(uncheckedMinutes: minimumMinutes)

  private init(uncheckedMinutes minutes: Int) {
    self.minutes = minutes
  }

  init(minutes: Int) throws {
    guard minutes >= Self.minimumMinutes else { throw ValidationError.belowMinimum }
    self.minutes = minutes
  }

  var seconds: Int { minutes * 60 }

  var shortLabel: String {
    if minutes < 60 {
      return "\(minutes) min"
    }

    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    if remainingMinutes == 0 {
      return "\(hours) hr"
    }
    return "\(hours) hr \(remainingMinutes) min"
  }

  var accessibilityLabel: String {
    if minutes < 60 {
      return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }

    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    let hourText = hours == 1 ? "1 hour" : "\(hours) hours"
    guard remainingMinutes > 0 else { return hourText }

    let minuteText = remainingMinutes == 1 ? "1 minute" : "\(remainingMinutes) minutes"
    return "\(hourText) \(minuteText)"
  }

  var timerOptionName: String {
    if minutes < 60 {
      return "\(minutes)"
    }
    return shortLabel
  }

  static func parseMinutes(_ raw: String) -> Result<MeditationDuration, ValidationError> {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return .failure(.empty) }
    guard trimmed.allSatisfy(\.isNumber), let minutes = Int(trimmed) else {
      return .failure(.notWholeMinutes)
    }

    do {
      return .success(try MeditationDuration(minutes: minutes))
    } catch let error as ValidationError {
      return .failure(error)
    } catch {
      return .failure(.notWholeMinutes)
    }
  }

  static func clampedSliderMinutes(_ value: Double) -> Int {
    let rounded = Int(value.rounded())
    return min(max(rounded, sliderMinimumMinutes), sliderMaximumMinutes)
  }
}
