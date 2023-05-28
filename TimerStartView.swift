//
//  TimerStartView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//  With help from GPT-4.
//

import SwiftUI

struct TimerStartView: View {
  let durationOptions = [5, 10, 15, 20, 25, 30, 45, 60]  // in minutes
  @State private var selectedDuration: Int = 0
  @State private var showTimerRunningView: Bool = false
  @ObservedObject private var timerViewModel = TimerViewModel()

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
            showTimerRunningView = true
          }) {
            Image(systemName: "play.fill")
              .resizable()
              .frame(width: 24, height: 24)
          }
          .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 80)
          .foregroundColor(.white)
          .background(Color.blue)
          .cornerRadius(10)
          .padding()

          //          LargeBlueButtonView(buttonText: "3") {
          //            // This does not work!
          //            // TODO: Use .sheet(item:) to specify the timing
          //            // And do we really need the local timerViewModel variable for something??
          //            // And: Fix how this button looks somehow.
          //            showTimerRunningView = true
          //          }
        }
      }
      .frame(maxHeight: .infinity)
    }
    .sheet(isPresented: $showTimerRunningView) {
      TimerRunningView()
    }
    .onAppear {
      // TODO: Do this in the Settings screen
      HealthKitManager.shared.requestAuthorization { (success, error) in
        if success {
          print("Permission granted")
        } else {
          print("Permission denied: ", error?.localizedDescription ?? "Unknown error")
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
