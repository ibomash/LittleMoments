//
//  TimerRunningView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

struct TimerRunningView: View {
  let timerButtonValues = [1, 3, 5, 10, 15, 20]
  let buttonsPerRow = 3
  @State private var isPaused: Bool = false
  @State private var showIntermediateBell: Bool = false
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  //@ObservedObject private var timerViewModel = TimerViewModel()
  @StateObject var timerViewModel = TimerViewModel()
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
      Spacer()

      // Show elapsed time and a ring if we have a target time
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
      // Add some spacing
      .padding(.bottom, 20)

      Spacer()

      // Bell controls
      Grid {
        ForEach(0..<2) { rowIndex in
          GridRow {
            ForEach(0..<buttonsPerRow) { columnIndex in
              let index = rowIndex * buttonsPerRow + columnIndex
              if index < timerButtonValues.count {
                let buttonValue = timerButtonValues[index]
                Button(action: {
                  // Handle button tap
                  timerViewModel.scheduledAlert = OneTimeScheduledBellAlert(
                    targetTimeInMin: buttonValue)
                }) {
                  Text("\(buttonValue) min")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
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
        Button(action: {
          timerViewModel.reset()
          presentationMode.wrappedValue.dismiss()
        }) {
          Image(systemName: "x.circle.fill")
            .resizable()
            .frame(width: 24, height: 24)
        }
        .padding()

        Button(action: {
          timerViewModel.isRunning.toggle()
          if timerViewModel.isRunning {
            timerViewModel.start()
          } else {
            timerViewModel.pause()
          }
        }) {
          Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
            .resizable()
            .frame(width: 24, height: 24)
        }
        .padding()

        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Image(systemName: "stop.fill")
            .resizable()
            .frame(width: 24, height: 24)
        }
        .padding()
      }
    }
    .onAppear {
      timerViewModel.start()
      SoundManager.playSound()
    }
    .onDisappear {
      if timerViewModel.secondsElapsed > 0 {
        timerViewModel.writeToHealthStore()
      }
    }
  }
}

struct TimerRunningView_Previews: PreviewProvider {
  static var previews: some View {
    TimerRunningView()
  }
}
