import AppIntents
import SwiftUI

struct TimerStartView: View {
  @StateObject private var appState = AppState.shared
  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency

  var body: some View {
    NavigationStack {
      ZStack {
        backgroundSurface

        VStack(spacing: 32) {
          Spacer()

          Text("🙏🏻")
            .font(.largeTitle)
            .padding(.vertical, 20)
            .italic()
            .lineSpacing(20)
            .frame(minWidth: 200, maxWidth: 300)
            .multilineTextAlignment(.center)

          Spacer()

          controlsRow
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .onAppear {
      // Request notification authorization the first time the main screen shows
      // Keep this non-blocking and avoid touching SwiftUI state in callbacks
      requestNotificationAuthorizationIfNeeded()
    }
    .fullScreenCover(isPresented: $appState.showTimerRunningView) {
      TimerRunningView()
    }
    .sheet(isPresented: $appState.showSettingsView) {
      SettingsView()
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(32)
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

  private var controlsRow: some View {
    HStack(spacing: 20) {
      settingsButton

      ImageButton(
        imageName: "play.fill",
        buttonText: "Start session",
        action: startSession
      )
      .accessibilityIdentifier("start_session_button")
    }
  }

  private var settingsButton: some View {
    Button(action: { appState.showSettingsView = true }) {
      Image(systemName: "gearshape.fill")
        .symbolVariant(.fill)
        .symbolRenderingMode(.hierarchical)
        .font(.system(size: 24, weight: .semibold))
    }
    .accessibilityLabel(Text("Settings"))
    .liquidGlassIconButtonStyle(variant: .subtle, diameter: 64)
  }

  private func startSession() {
    var intent = MeditationSessionIntent()
    intent.durationMinutes = appState.pendingStartDurationSeconds.map { $0 / 60 }
    let donationManager = IntentDonationManager.shared
    let donationID = donationManager.donate(intent: intent)
    print("Donated: \(intent) with result: \(donationID)")
    appState.showTimerRunningView = true
  }

  private var backgroundSurface: some View {
    Group {
      if reducesTransparency {
        Color(UIColor.systemBackground)
      } else {
        LinearGradient(
          colors: [
            LiquidGlassTokens.primaryTint.opacity(0.12),
            Color(UIColor.systemBackground),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      }
    }
    .ignoresSafeArea()
  }
}

struct TimerStartView_Previews: PreviewProvider {
  static var previews: some View {
    TimerStartView()
  }
}
