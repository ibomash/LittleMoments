//
//  TimerRunningView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

struct TimerRunningView: View {
    @State private var progress: CGFloat = 0.0
    @State private var isPaused: Bool = false
    @State private var showIntermediateBell: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //@ObservedObject private var timerViewModel = TimerViewModel()
    @StateObject var timerViewModel = TimerViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
//            ZStack {
//                Circle()
//                    .stroke(lineWidth: 20)
//                    .opacity(0.2)
//                    .foregroundColor(Color.blue)
//
//                Circle()
//                    .trim(from: 0, to: timerViewModel.progress)
//                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
//                    .foregroundColor(Color.blue)
//                    .rotationEffect(Angle(degrees: 270))
//                    // .animation(.linear)
//
//                Text("\(timerViewModel.timeRemaining)")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//            }
//            .frame(width: 200, height: 200)
            
            Text("\(timerViewModel.timeElapsedFormatted)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(width: 200, height: 200)
            
            HStack {
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
            timerViewModel.start() // Set your desired initial time in minutes
        }
        .onDisappear {
            timerViewModel.writeToHealthStore()
        }
    }
}

struct TimerRunningView_Previews: PreviewProvider {
    static var previews: some View {
        TimerRunningView()
    }
}
