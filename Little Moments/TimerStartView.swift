//
//  TimerStartView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import AppIntents
import SwiftUI

struct TimerStartView: View {

  @EnvironmentObject private var vm: AppViewModel

  var body: some View {
    NavigationStack {
      VStack {
        Spacer()

        Text(
          "What if you deeply let go, in this moment, of the “self” that sat down to meditate just now?"
        )
        .font(.title)
        .multilineTextAlignment(.center)
        .padding(.vertical, 20)
        .italic()
        .lineSpacing(20)
        .frame(minWidth: 200, maxWidth: 300)
        .multilineTextAlignment(.center)

        Spacer()

        HStack {
          Button(action: {
            vm.showSettingsView = true
          }) {
            Image(systemName: "gear")
              .resizable()
              .frame(width: 36, height: 36)
          }
          .frame(minWidth: 80, minHeight: 80, maxHeight: 80)
          .padding()

          ImageButton(
            imageName: "play.fill", buttonText: "Start session",
            action: {
              let ua = NSUserActivity(activityType: "net.bomash.illya.Little-Moments.start-timer")
              ua.title = "Mindfulness session"
              ua.isEligibleForPrediction = true
              ua.persistentIdentifier = Date().ISO8601Format()
              ua.becomeCurrent()
              print("User activity made current: \(ua)")

              vm.showTimerRunningView = true
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
    .sheet(isPresented: $vm.showTimerRunningView) {
      TimerRunningView()
    }
    .sheet(isPresented: $vm.showSettingsView) {
      SettingsView()
    }
  }
}

struct TimerStartView_Previews: PreviewProvider {
  static var previews: some View {
    TimerStartView()
  }
}
