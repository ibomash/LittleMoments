@preconcurrency import XCTest
import SwiftUI

@testable import LittleMoments

@MainActor
final class TimerViewModelLiveActivityTests: XCTestCase {
    var timerViewModel: TimerViewModel?
    
    @MainActor override func setUp() async throws {
        try await super.setUp()
        timerViewModel = TimerViewModel()
        UserDefaultsReset.resetDefaults()
        // Enable Live Activities by default for tests
        JustNowSettings.shared.enableLiveActivities = true
    }
    
    @MainActor override func tearDown() async throws {
        timerViewModel?.reset()
        timerViewModel = nil
        try await super.tearDown()
    }
    
    func testStartLiveActivity() {
        // Test that Live Activity starts correctly
        timerViewModel?.startLiveActivity()
        // Since we can't directly test ActivityKit in unit tests,
        // we're mostly testing that the function doesn't crash
        XCTAssertNotNil(timerViewModel)
    }
    
    func testStartLiveActivityWithTarget() {
        // Set a target time for the session
        let fiveMinAlert = timerViewModel?.scheduledAlertOptions[1]  // 5-minute timer
        timerViewModel?.scheduledAlert = fiveMinAlert
        
        // Start Live Activity with target
        timerViewModel?.startLiveActivity()
        // Verify the timer has a target
        XCTAssertTrue(timerViewModel?.hasEndTarget ?? false)
    }
    
    func testUpdateLiveActivity() {
        // Start timer and Live Activity
        timerViewModel?.start()
        timerViewModel?.startLiveActivity()
        
        // Update Live Activity
        timerViewModel?.updateLiveActivity()
        // This is just testing that the function doesn't crash
        XCTAssertNotNil(timerViewModel)
    }
    
    func testEndLiveActivity() {
        // Start timer and Live Activity
        timerViewModel?.start()
        timerViewModel?.startLiveActivity()
        
        // End Live Activity
        timerViewModel?.endLiveActivity(completed: true)
        // This is just testing that the function doesn't crash
        XCTAssertNotNil(timerViewModel)
    }
    
    func testLiveActivitiesDisabled() {
        // Disable Live Activities
        JustNowSettings.shared.enableLiveActivities = false
        
        // These should all be no-ops when disabled
        timerViewModel?.startLiveActivity()
        timerViewModel?.updateLiveActivity()
        timerViewModel?.endLiveActivity()
        
        // Just verify that nothing crashed
        XCTAssertNotNil(timerViewModel)
    }
} 
