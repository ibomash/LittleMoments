import ActivityKit
import Foundation

struct MeditationLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var secondsElapsed: Double
        var targetTimeInSeconds: Double?
        var isCompleted: Bool
    }
    
    var sessionName: String
} 