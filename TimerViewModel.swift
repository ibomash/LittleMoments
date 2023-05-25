//
//  TimerViewModel.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import Foundation

class TimerViewModel: ObservableObject {
    @Published var secondsElapsed: Int = 0
    @Published var isRunning: Bool = false
    @Published var bellDurationSeconds: Int? = nil
    var timer: Timer? = nil
    
    var timeElapsedFormatted: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var hasEndTarget: Bool {
        return bellDurationSeconds != nil
    }

    var progress: CGFloat {
        guard let bellDuration = bellDurationSeconds else { return 0.0 }
        // Cap the progress value at 1.0
        if secondsElapsed >= bellDuration {
            return 1.0
        }
        return CGFloat(secondsElapsed) / CGFloat(bellDuration)
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
        }
        isRunning = true
    }

    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        secondsElapsed = 0
        isRunning = false
    }
    
    func writeToHealthStore() {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-Double(secondsElapsed))
        // Create a new mindful session
        let mindfulSession = HealthKitManager.shared.createMindfulSession(startDate: startDate, endDate: endDate)

        // Save the session to HealthKit
        HealthKitManager.shared.saveMindfulSession(mindfulSession: mindfulSession) { [self] (success, error) in
            if success {
                print("Mindful session of \(secondsElapsed) seconds saved successfully: \(mindfulSession)")
            } else {
                print("Failed to save mindful session: ", error?.localizedDescription ?? "Unknown error")
            }
        }
    }
}
