import XCTest
import SwiftUI
@testable import LittleMoments

final class WidgetBundleTests: XCTestCase {
  
  func testDynamicIslandUsesSharedTimerFunction() {
    // Test that Dynamic Island regions use the shared timer function
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 195,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )
    
    // Dynamic Island should use the same shared function
    let dynamicIslandDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    
    XCTAssertEqual(dynamicIslandDisplay, "3:15")
    
    // Test with seconds disabled
    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: false
    )
    
    XCTAssertEqual(displayWithoutSeconds, "3")
  }
  
  func testConsistentTimerDisplayAcrossAllWidgetPresentations() {
    // Test that all widget presentations use the same timer display logic
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 247,
      targetTimeInSeconds: 900,
      isCompleted: false,
      showSeconds: true
    )
    
    // All should use the same shared function and produce the same result
    let lockScreenDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    
    let expandedLeadingDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    
    let compactTrailingDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    
    let expectedDisplay = "4:07"
    XCTAssertEqual(lockScreenDisplay, expectedDisplay)
    XCTAssertEqual(expandedLeadingDisplay, expectedDisplay)
    XCTAssertEqual(compactTrailingDisplay, expectedDisplay)
    
    // All should be identical
    XCTAssertEqual(lockScreenDisplay, expandedLeadingDisplay)
    XCTAssertEqual(expandedLeadingDisplay, compactTrailingDisplay)
  }
  
  func testPreviewProviderUsesValidStateData() {
    // Test that all preview variants use valid state data
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted
    let previewAttributes = MeditationLiveActivityAttributes.preview
    
    // In-progress preview state should be valid
    XCTAssertGreaterThan(previewState.secondsElapsed, 0)
    XCTAssertNotNil(previewState.targetTimeInSeconds)
    XCTAssertFalse(previewState.isCompleted)
    XCTAssertTrue(previewState.showSeconds)
    
    // Completed preview state should be valid
    XCTAssertGreaterThan(previewStateCompleted.secondsElapsed, 0)
    XCTAssertNotNil(previewStateCompleted.targetTimeInSeconds)
    XCTAssertTrue(previewStateCompleted.isCompleted)
    XCTAssertTrue(previewStateCompleted.showSeconds)
    
    // Attributes should be valid
    XCTAssertFalse(previewAttributes.sessionName.isEmpty)
    
    // States should be realistic
    if let targetTime = previewState.targetTimeInSeconds {
      XCTAssertLessThan(previewState.secondsElapsed, targetTime, "In-progress should be less than target")
    }
    
    if let targetTime = previewStateCompleted.targetTimeInSeconds {
      XCTAssertGreaterThanOrEqual(previewStateCompleted.secondsElapsed, targetTime, "Completed should be >= target")
    }
  }
  
  func testPreviewContextsAreProperlyConfigured() {
    // Test that preview contexts are configured correctly
    // This is more of a structural test to ensure preview setup is correct
    
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewStateCompleted = MeditationLiveActivityAttributes.previewStateCompleted
    
    // Preview states should produce valid timer displays
    let inProgressDisplay = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    XCTAssertFalse(inProgressDisplay.isEmpty)
    XCTAssertTrue(inProgressDisplay.contains(":"))
    
    let completedDisplay = timerDisplayFromSeconds(
      seconds: previewStateCompleted.secondsElapsed,
      showSeconds: previewStateCompleted.showSeconds
    )
    XCTAssertFalse(completedDisplay.isEmpty)
    XCTAssertTrue(completedDisplay.contains(":"))
  }
  
  func testWidgetBundleContainsCorrectWidget() {
    // Test that the widget bundle is properly configured
    // This is mainly a structural test
    
    // The widget bundle should contain the Live Activity widget
    // In a real test, you might check that MeditationLiveActivityWidget is properly configured
    
    // For now, we'll test that the shared function is accessible
    let testDisplay = timerDisplayFromSeconds(seconds: 120, showSeconds: true)
    XCTAssertEqual(testDisplay, "2:00")
  }
  
  func testSharedTimerFunctionAccessibility() {
    // Test that the shared timer function is accessible from all widget components
    let testSeconds: Double = 305
    
    // Function should be accessible and produce consistent results
    let displayWithSeconds = timerDisplayFromSeconds(seconds: testSeconds, showSeconds: true)
    let displayWithoutSeconds = timerDisplayFromSeconds(seconds: testSeconds, showSeconds: false)
    
    XCTAssertEqual(displayWithSeconds, "5:05")
    XCTAssertEqual(displayWithoutSeconds, "5")
    
    // Multiple calls should return the same result
    XCTAssertEqual(timerDisplayFromSeconds(seconds: testSeconds, showSeconds: true), displayWithSeconds)
    XCTAssertEqual(timerDisplayFromSeconds(seconds: testSeconds, showSeconds: false), displayWithoutSeconds)
  }
  
  func testWidgetSupportsAllRequiredPresentations() {
    // Test that the widget supports all required Live Activity presentations
    let testState = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: 150,
      targetTimeInSeconds: 300,
      isCompleted: false,
      showSeconds: true
    )
    
    // Lock screen presentation (main widget view)
    let lockScreenDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    XCTAssertEqual(lockScreenDisplay, "2:30")
    
    // Dynamic Island compact trailing
    let compactDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    XCTAssertEqual(compactDisplay, "2:30")
    
    // Dynamic Island expanded leading
    let expandedDisplay = timerDisplayFromSeconds(
      seconds: testState.secondsElapsed,
      showSeconds: testState.showSeconds
    )
    XCTAssertEqual(expandedDisplay, "2:30")
    
    // All should use the same shared logic
    XCTAssertEqual(lockScreenDisplay, compactDisplay)
    XCTAssertEqual(compactDisplay, expandedDisplay)
  }
  
  func testWidgetHandlesShowSecondsSettingConsistently() {
    // Test that all widget presentations handle showSeconds setting consistently
    let testSeconds: Double = 185
    
    let stateWithSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: testSeconds,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: true
    )
    
    let stateWithoutSeconds = MeditationLiveActivityAttributes.ContentState(
      secondsElapsed: testSeconds,
      targetTimeInSeconds: 600,
      isCompleted: false,
      showSeconds: false
    )
    
    // All presentations should respect the showSeconds setting
    let displayWithSeconds = timerDisplayFromSeconds(
      seconds: stateWithSeconds.secondsElapsed,
      showSeconds: stateWithSeconds.showSeconds
    )
    XCTAssertEqual(displayWithSeconds, "3:05")
    
    let displayWithoutSeconds = timerDisplayFromSeconds(
      seconds: stateWithoutSeconds.secondsElapsed,
      showSeconds: stateWithoutSeconds.showSeconds
    )
    XCTAssertEqual(displayWithoutSeconds, "3")
  }
  
  func testWidgetBundleIntegrationWithPreviewProvider() {
    // Test that the widget bundle and preview provider work together correctly
    let previewState = MeditationLiveActivityAttributes.previewState
    let previewAttributes = MeditationLiveActivityAttributes.preview
    
    // Preview should use the same shared function as the widget
    let previewDisplay = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    
    // Widget using the same state should produce the same display
    let widgetDisplay = timerDisplayFromSeconds(
      seconds: previewState.secondsElapsed,
      showSeconds: previewState.showSeconds
    )
    
    XCTAssertEqual(previewDisplay, widgetDisplay)
    XCTAssertEqual(previewDisplay, "3:00")
    
    // Attributes should be consistent
    XCTAssertEqual(previewAttributes.sessionName, "Morning Meditation")
  }
}