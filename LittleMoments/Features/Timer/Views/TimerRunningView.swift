//
//  TimerRunningView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI
import UserNotifications

struct TimerRunningView: View {
  let buttonsPerRow = 4
  @StateObject var timerViewModel = TimerViewModel()
  @Environment(\.presentationMode) var presentationMode
  @Environment(\.horizontalSizeClass) var horizontalSizeClass

  var body: some View {
    GeometryReader { geometry in
      let isLandscape = geometry.size.width > geometry.size.height

      Group {
        if isLandscape {
          // Landscape layout
          HStack {
            // Timer view
            VStack {
              Spacer()
              TimerCircleView(timerViewModel: timerViewModel)
                .frame(width: min(geometry.size.height * 0.7, geometry.size.width * 0.4))
                .padding()
              Spacer()
            }

            // Bell controls and buttons
            VStack {
              Spacer()
              // Bell controls
              BellControlsGrid(timerViewModel: timerViewModel)
                .padding()

              // Timer controls at the bottom
              TimerControlButtons(
                timerViewModel: timerViewModel, presentationMode: presentationMode
              )
              .padding(.bottom)
            }
          }
        } else {
          // Portrait layout
          VStack {
            Spacer()

            // Timer view
            TimerCircleView(timerViewModel: timerViewModel)
              .frame(width: 200, height: 200)
              .padding(.bottom, 20)

            Spacer()

            // Bell controls
            BellControlsGrid(timerViewModel: timerViewModel)
              .padding()

            // Timer controls
            TimerControlButtons(timerViewModel: timerViewModel, presentationMode: presentationMode)
          }
        }
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
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
      timerViewModel.writeToHealthStore()
      timerViewModel.reset()
      UIApplication.shared.isIdleTimerDisabled = false
    }
  }
}

// MARK: - Timer Circle View
struct TimerCircleView: View {
  @ObservedObject var timerViewModel: TimerViewModel

  var body: some View {
    TimelineView(.periodic(from: Date(), by: 0.1)) { _ in
      ZStack {
        Circle()
          .stroke(lineWidth: 10)
          .opacity(timerViewModel.hasEndTarget ? 0.2 : 0)
          .foregroundColor(Color.blue)
          .animation(.linear, value: timerViewModel.hasEndTarget)

        Circle()
          .trim(from: 0, to: timerViewModel.progress)
          .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
          .foregroundColor(timerViewModel.isDone ? Color.green : Color.blue)
          .rotationEffect(Angle(degrees: 270))
          .animation(.linear, value: timerViewModel.progress)

        Text("\(timerViewModel.timeElapsedFormatted)")
          .font(.largeTitle)
          .fontWeight(.bold)
      }
    }
  }
}

// MARK: - Bell Controls Grid
struct BellControlsGrid: View {
  @ObservedObject var timerViewModel: TimerViewModel
  let buttonsPerRow = 4

  var body: some View {
    Grid {
      Text("Timer (minutes)")
        .foregroundColor(Color.gray)
      ForEach(0..<2) { rowIndex in
        GridRow {
          ForEach(0..<buttonsPerRow) { columnIndex in
            let index = rowIndex * buttonsPerRow + columnIndex
            if index < timerViewModel.scheduledAlertOptions.count {
              let scheduledAlertOption: OneTimeScheduledBellAlert =
                timerViewModel.scheduledAlertOptions[index]
              Button(
                action: {
                  handleAlertSelection(scheduledAlertOption)
                },
                label: {
                  Text(scheduledAlertOption.name)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                      timerViewModel.scheduledAlert == scheduledAlertOption
                        ? Color.blue : Color(UIColor.systemBackground)
                    )
                    .foregroundColor(
                      timerViewModel.scheduledAlert == scheduledAlertOption
                        ? Color.white : Color.blue
                    )
                    .cornerRadius(8)
                }
              )
            } else {
              Spacer()
            }
          }
        }
      }
    }
  }

  private func handleAlertSelection(_ scheduledAlertOption: OneTimeScheduledBellAlert) {
    if timerViewModel.scheduledAlert == scheduledAlertOption {
      timerViewModel.scheduledAlert = nil
      UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    } else {
      timerViewModel.scheduledAlert = scheduledAlertOption

      UNUserNotificationCenter.current().requestAuthorization(options: [
        .alert, .sound
      ]) { granted, _ in
        if granted {
          let content = UNMutableNotificationContent()
          content.title = "Timer Complete"
          content.body =
            "Your \(scheduledAlertOption.name) minute timer has finished"
          content.sound = UNNotificationSound(
            named: UNNotificationSoundName(
              rawValue: "42095__fauxpress__bell-meditation.aif"))
          content.interruptionLevel = .timeSensitive

          let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(scheduledAlertOption.targetTimeInSec),
            repeats: false
          )

          let request = UNNotificationRequest(
            identifier: "timerNotification",
            content: content,
            trigger: trigger
          )

          UNUserNotificationCenter.current().add(request)
        }
      }
    }
  }
}

// MARK: - Timer Control Buttons
struct TimerControlButtons: View {
  @ObservedObject var timerViewModel: TimerViewModel
  var presentationMode: Binding<PresentationMode>

  var body: some View {
    HStack {
      ImageButton(
        imageName: "xmark.circle.fill", 
        buttonText: "Cancel",
        action: {
          timerViewModel.reset()
          presentationMode.wrappedValue.dismiss()
        }
      )
      .padding()

      ImageButton(
        imageName: "checkmark.circle.fill", 
        buttonText: "Complete",
        action: {
          presentationMode.wrappedValue.dismiss()
        }
      )
      .padding()
    }
  }
}

struct TimerRunningView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TimerRunningView()
        .previewInterfaceOrientation(.portrait)

      TimerRunningView()
        .previewInterfaceOrientation(.landscapeLeft)
    }
  }
}
