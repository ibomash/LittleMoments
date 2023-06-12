//
//  TimerRunningView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI
import UIKit

struct TimerRunningView: View {
  let buttonsPerRow = 3
  @StateObject var timerViewModel = TimerViewModel()
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
      Spacer()

      // Show elapsed time and a ring if we have a target time
      TimelineView(.periodic(from: Date(), by: 0.1)) { context in
        ZStack {
          Circle()
            .stroke(lineWidth: 10)
            .opacity(timerViewModel.hasEndTarget ? 0.2 : 0)
            .foregroundColor(Color.blue)
            .animation(.linear, value: timerViewModel.hasEndTarget)

          Circle()
            .trim(from: 0, to: timerViewModel.progress)
            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            .foregroundColor(Color.blue)
            .rotationEffect(Angle(degrees: 270))
            .animation(.linear, value: timerViewModel.progress)

          Text("\(timerViewModel.timeElapsedFormatted)")
            .font(.largeTitle)
            .fontWeight(.bold)
            .frame(width: 200, height: 200)
        }
        .frame(width: 200, height: 200)
        .padding(.bottom, 20)
      }

      Spacer()

      // Bell controls
      Grid {
        ForEach(0..<2) { rowIndex in
          GridRow {
            ForEach(0..<buttonsPerRow) { columnIndex in
              let index = rowIndex * buttonsPerRow + columnIndex
              if index < timerViewModel.scheduledAlertOptions.count {
                let scheduledAlertOption: OneTimeScheduledBellAlert =
                  timerViewModel.scheduledAlertOptions[index]
                Button(action: {
                  // Handle button tap
                  if timerViewModel.scheduledAlert == scheduledAlertOption {
                    timerViewModel.scheduledAlert = nil
                  } else {
                    timerViewModel.scheduledAlert = scheduledAlertOption
                  }
                }) {
                  Text(scheduledAlertOption.name)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                      timerViewModel.scheduledAlert == scheduledAlertOption
                        ? Color.blue : Color.white
                    )
                    .foregroundColor(
                      timerViewModel.scheduledAlert == scheduledAlertOption
                        ? Color.white : Color.blue
                    )
                    .cornerRadius(8)
                }.foregroundColor(.blue)
              } else {
                Spacer()
              }
            }
          }
        }
      }
      .padding()

      // Timer controls
      HStack {
        // Cancel button
        ImageButton(
          imageName: "xmark.circle.fill", buttonText: "Cancel",
          action: {
            timerViewModel.reset()
            presentationMode.wrappedValue.dismiss()
          }
        )
        .padding()

        // Complete button
        ImageButton(
          imageName: "checkmark.circle.fill", buttonText: "Complete",
          action: {
            presentationMode.wrappedValue.dismiss()
          }
        )
        .padding()
      }
    }
    .onAppear {
      timerViewModel.start()
      UIApplication.shared.isIdleTimerDisabled = true
      if JustNowSettings.shared.ringBellAtStart {
        SoundManager.playSound()
      }
    }
    .onDisappear {
      timerViewModel.writeToHealthStore()
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
}

struct TimerRunningView_Previews: PreviewProvider {
  static var previews: some View {
    TimerRunningView()
  }
}
