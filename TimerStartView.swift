//
//  TimerStartView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//  With help from GPT-4.
//

import SwiftUI

struct TimerStartView: View {
  @State private var showTimerRunningView: Bool = false
  @State private var showSettingsView: Bool = false

  var body: some View {
    NavigationView {
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
            showSettingsView = true
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
              showTimerRunningView = true
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
    .sheet(isPresented: $showTimerRunningView) {
      TimerRunningView()
    }
    .sheet(isPresented: $showSettingsView) {
      SettingsView()
    }
    .onAppear {
      // TODO: Do this in the Settings screen
      HealthKitManager.shared.requestAuthorization { (success, error) in
        if !success {
          print("HealthKit permission denied: ", error?.localizedDescription ?? "Unknown error")
        }
      }

    }
  }
}

struct TimerStartView_Previews: PreviewProvider {
  static var previews: some View {
    TimerStartView()
  }
}
