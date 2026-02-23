import Foundation
import SwiftData

enum SessionHealthWriteStatus: String, Codable, CaseIterable, Sendable {
  case pendingHealthWrite = "pending_health_write"
  case writtenToHealth = "written_to_health"

  var displayName: String {
    switch self {
    case .pendingHealthWrite:
      return "Pending"
    case .writtenToHealth:
      return "Written"
    }
  }
}

@Model
final class SessionHistoryEntry {
  var id: UUID = UUID()
  var startDate: Date = Date()
  var endDate: Date = Date()
  var durationSeconds: Int = 0
  var createdAt: Date = Date()
  var sourceDeviceId: String = ""
  var healthWriteStatusRaw: String = SessionHealthWriteStatus.pendingHealthWrite.rawValue
  var healthWrittenAt: Date?
  var lastWriteAttemptAt: Date?
  var lastWriteErrorCode: String?

  var healthWriteStatus: SessionHealthWriteStatus {
    get { SessionHealthWriteStatus(rawValue: healthWriteStatusRaw) ?? .pendingHealthWrite }
    set { healthWriteStatusRaw = newValue.rawValue }
  }

  init(
    id: UUID = UUID(),
    startDate: Date,
    endDate: Date,
    durationSeconds: Int,
    createdAt: Date = Date(),
    sourceDeviceId: String,
    healthWriteStatus: SessionHealthWriteStatus = .pendingHealthWrite,
    healthWrittenAt: Date? = nil,
    lastWriteAttemptAt: Date? = nil,
    lastWriteErrorCode: String? = nil
  ) {
    self.id = id
    self.startDate = startDate
    self.endDate = endDate
    self.durationSeconds = durationSeconds
    self.createdAt = createdAt
    self.sourceDeviceId = sourceDeviceId
    self.healthWriteStatusRaw = healthWriteStatus.rawValue
    self.healthWrittenAt = healthWrittenAt
    self.lastWriteAttemptAt = lastWriteAttemptAt
    self.lastWriteErrorCode = lastWriteErrorCode
  }
}
