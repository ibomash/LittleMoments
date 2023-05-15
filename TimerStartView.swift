//
//  TimerStartView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//  With help from GPT-4.
//


import SwiftUI

struct TimerStartView: View {
    let durationOptions = [5, 10, 15, 20, 25, 30, 45, 60] // in minutes
    @State private var selectedDuration: Int = 0
    @State private var showTimerRunningView: Bool = false
    @ObservedObject private var timerViewModel = TimerViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Meditation Duration")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                    ForEach(durationOptions, id: \.self) { duration in
                        LargeBlueButtonView(buttonText: "\(duration) min") {
                            selectedDuration = duration
                            showTimerRunningView = true
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarTitle("MeditateMe", displayMode: .large)
        }
        .sheet(isPresented: $showTimerRunningView) {
            TimerRunningView()
        }
        .onAppear() {
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



//
//import SwiftUI
//
//struct TimerStartView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//struct TimerStartView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimerStartView()
//    }
//}
