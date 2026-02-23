import SwiftData
import SwiftUI

struct SessionHistoryView: View {
  @Environment(\.modelContext) private var modelContext
  @State private var entries: [SessionHistoryEntry] = []

  var body: some View {
    Group {
      if entries.isEmpty {
        ContentUnavailableView(
          "No Session History",
          systemImage: "clock.badge.questionmark",
          description: Text("Completed sessions will appear here.")
        )
        .accessibilityIdentifier("session_history_empty_state")
      } else {
        List(entries, id: \.id) { entry in
          rowView(for: entry)
        }
        .accessibilityIdentifier("session_history_list")
        .refreshable {
          await loadEntries()
        }
      }
    }
    .task {
      await loadEntries()
    }
    .navigationTitle("Session History")
    .navigationBarTitleDisplayMode(.inline)
  }

  private func rowView(for entry: SessionHistoryEntry) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline) {
        Text(Self.endDateFormatter.string(from: entry.endDate))
          .font(.headline)
        Spacer()
        Text(entry.healthWriteStatus.displayName)
          .font(.caption.weight(.semibold))
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .background(statusBackgroundColor(for: entry.healthWriteStatus), in: Capsule())
      }

      Text("Duration: \(formattedDuration(for: entry.durationSeconds))")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }

  private func statusBackgroundColor(for status: SessionHealthWriteStatus) -> Color {
    switch status {
    case .pendingHealthWrite:
      return Color.orange.opacity(0.2)
    case .writtenToHealth:
      return Color.green.opacity(0.2)
    }
  }

  private func formattedDuration(for durationSeconds: Int) -> String {
    if let text = Self.durationFormatter.string(from: TimeInterval(durationSeconds)) {
      return text
    }

    return "\(durationSeconds)s"
  }

  @MainActor
  private func loadEntries() async {
    let descriptor = FetchDescriptor<SessionHistoryEntry>(
      sortBy: [
        SortDescriptor(\SessionHistoryEntry.endDate, order: .reverse)
      ]
    )

    entries = (try? modelContext.fetch(descriptor)) ?? []
  }

  private static let endDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }()

  private static let durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    return formatter
  }()
}

struct SessionHistoryView_Previews: PreviewProvider {
  static var previews: some View {
    SessionHistoryView()
  }
}
