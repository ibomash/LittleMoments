import SwiftUI

struct MacSettingsView: View {
  @AppStorage("ringBellAtStart") private var ringBellAtStart = true
  @AppStorage("showSeconds") private var showSeconds = true

  var body: some View {
    Form {
      Section("Session") {
        Toggle("Ring bell when a session starts", isOn: $ringBellAtStart)
        Toggle("Show seconds", isOn: $showSeconds)
      }

      Section {
        Text("Completed sessions are saved to Little Moments history on this Mac.")
          .foregroundStyle(.secondary)
      }
    }
    .formStyle(.grouped)
    .frame(width: 430)
  }
}
