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

          ImageButton(imageName: "play.fill", buttonText: "Start session", action: {
            let intent = MeditationSessionIntent()
            // Print the intent I'm donating
            let donationManager = IntentDonationManager.shared
            // Donate the intent and print confirmation for debugging purposes depending on success or failure
            let donationID = donationManager.donate(intent: intent)
            // Print the intent and result within my log message
            print("Donated: \(intent) with result: \(donationID)")
            appState.showTimerRunningView = true
          })
          .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
          .foregroundColor(.white)
          .background(Color.blue)
          .cornerRadius(10)
          .padding()
        }
      }
      .frame(maxHeight: .infinity)
    }
    .sheet(isPresented: $appState.showTimerRunningView) {
      TimerRunningView()
    }
    .sheet(isPresented: $appState.showSettingsView) {
      SettingsView()
    }
  }
}

struct TimerStartView_Previews: PreviewProvider {
  static var previews: some View {
    TimerStartView()
  }
}
