import AppIntents
import SwiftUI

struct TimerStartView: View {
  @StateObject private var appState = AppState.shared

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()

        Text(
          "🙏🏻"
        )
        .font(.largeTitle)
        .padding(.vertical, 20)
        .italic()
        .lineSpacing(20)
        .frame(minWidth: 200, maxWidth: 300)
        .multilineTextAlignment(.center)

        Spacer()

        HStack {
          Button(
            action: {
              appState.showSettingsView = true
            },
            label: {
              Image(systemName: "gear")
                .resizable()
                .frame(width: 36, height: 36)
            }
          )
          .frame(minWidth: 80, minHeight: 80, maxHeight: 80)
          .padding()

          ImageButton(
            imageName: "play.fill", buttonText: "Start session",
            action: {
              var intent = MeditationSessionIntent()
              intent.durationMinutes = appState.pendingStartDurationSeconds.map { $0 / 60 }
              // Print the intent I'm donating
              let donationManager = IntentDonationManager.shared
              // Donate the intent and print confirmation for debugging purposes depending on success or failure
              let donationID = donationManager.donate(intent: intent)
              // Print the intent and result within my log message
              print("Donated: \(intent) with result: \(donationID)")
              appState.showTimerRunningView = true
            }
          )
          .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
          .foregroundColor(.white)
          .background(Color.blue)
          .cornerRadius(10)
          .padding()
        }
      }
      .frame(maxHeight: .infinity)
    }
    .onAppear {
      // Request notification authorization the first time the main screen shows
      // Keep this non-blocking and avoid touching SwiftUI state in callbacks
      requestNotificationAuthorizationIfNeeded()
    }
    .sheet(isPresented: $appState.showTimerRunningView) {
      TimerRunningView()
    }
    .sheet(isPresented: $appState.showSettingsView) {
      SettingsView()
    }
  }

  private func requestNotificationAuthorizationIfNeeded() {
    // Skip during stable UI tests
    if ProcessInfo.processInfo.arguments.contains("-DISABLE_SYSTEM_INTEGRATIONS") { return }

    // Use the async/await approach for Swift 6 compliance
    Task {
      await NotificationManager.shared.requestAuthorizationIfNeeded()
    }
  }
}

struct TimerStartView_Previews: PreviewProvider {
  static var previews: some View {
    TimerStartView()
  }
}
