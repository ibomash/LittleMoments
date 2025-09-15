# Deep Link Testing Strategy

**Date**: 2025-09-15  
**Status**: Proposed  
**Priority**: Medium  
**Related**: Timer Deep Link UI Tests, Deep Link Handling  

## Problem Statement

The UI test `testCustomDurationHighlightedViaDeepLink` was failing because it couldn't verify that custom duration deep links properly create and highlight temporary timer duration buttons in the UI.

### Root Cause Analysis

Through investigation, we discovered two separate issues:

1. **Race Condition in TimerRunningView**: A timing issue between Live Activity setup and preset duration application caused temporary timer options to be removed before the UI could display them.

2. **UI Test Deep Link Limitation**: XCUITest's `app.open(URL(...))` method relaunches the app instead of calling `onOpenURL` on the existing instance, making it impossible to test deep link handling in the UI test environment.

### Evidence

- Unit tests for deep link processing work correctly
- Direct simulation of deep link logic in UI tests works correctly  
- `app.open(URL(...))` causes app relaunch rather than URL handling
- Debug output shows `showTimerRunningView` remains `false` after deep link attempt

## Current Workaround

The test currently passes by using a debug simulation button that bypasses actual deep link processing:

```swift
// Debug button only visible during UI testing
if ProcessInfo.processInfo.arguments.contains("UITesting") {
  Button("Simulate Deep Link") {
    AppState.shared.pendingStartDurationSeconds = 420
    appState.showTimerRunningView = true
  }
}
```

### Issues with Current Approach

1. **Limited Coverage**: Doesn't test actual deep link URL parsing, scheme validation, or `onOpenURL` flow
2. **Debug Code in Production**: Adds test-specific code to production views
3. **False Confidence**: Test passes but real deep link failures could go undetected
4. **Maintenance Burden**: Two separate code paths to maintain

## Recommended Solution: Integration Testing

Replace the UI test with comprehensive integration tests that directly test the deep link processing logic.

### Proposed Test Structure

```swift
@MainActor
final class DeepLinkIntegrationTests: XCTestCase {
  
  func testStartSessionDeepLinkWithCustomDuration() {
    // Test URL parsing and app state changes
    let app = LittleMomentsApp()
    let url = URL(string: "littlemoments://startSession?duration=420")!
    
    app.handleDeepLink(url: url)
    
    XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, 420)
    XCTAssertTrue(AppState.shared.showTimerRunningView)
  }
  
  func testTimerViewModelAppliesPresetDuration() {
    // Test that TimerViewModel correctly processes preset durations
    let timerViewModel = TimerViewModel()
    
    timerViewModel.applyPresetDuration(420)
    
    // Verify temporary option creation
    XCTAssertEqual(timerViewModel.scheduledAlertOptions.count, 9) // 8 default + 1 temporary
    
    // Verify correct naming for minutes
    let temporaryOption = timerViewModel.scheduledAlertOptions[0]
    XCTAssertEqual(temporaryOption.name, "7")
    XCTAssertEqual(Int(temporaryOption.targetTimeInSec), 420)
    
    // Verify selection
    XCTAssertEqual(timerViewModel.scheduledAlert, temporaryOption)
  }
  
  func testTimerViewModelAppliesPresetDurationNonMinutes() {
    // Test seconds-based labeling for non-minute durations
    let timerViewModel = TimerViewModel()
    
    timerViewModel.applyPresetDuration(315) // 5 minutes 15 seconds
    
    let temporaryOption = timerViewModel.scheduledAlertOptions[0]
    XCTAssertEqual(temporaryOption.name, "315s")
  }
  
  func testDeepLinkSchemeValidation() {
    // Test that invalid schemes are rejected
    let app = LittleMomentsApp()
    let invalidUrl = URL(string: "otherapp://startSession?duration=420")!
    
    app.handleDeepLink(url: invalidUrl)
    
    XCTAssertNil(AppState.shared.pendingStartDurationSeconds)
    XCTAssertFalse(AppState.shared.showTimerRunningView)
  }
  
  func testDeepLinkDurationParsing() {
    // Test various duration formats
    let testCases = [
      ("littlemoments://startSession?duration=60", 60),
      ("littlemoments://startSession?duration=5m", 300),
      ("littlemoments://startSession?duration=120s", 120),
    ]
    
    for (urlString, expectedSeconds) in testCases {
      AppState.shared.resetState()
      let app = LittleMomentsApp()
      let url = URL(string: urlString)!
      
      app.handleDeepLink(url: url)
      
      XCTAssertEqual(AppState.shared.pendingStartDurationSeconds, expectedSeconds)
    }
  }
}
```

### Benefits of Integration Testing Approach

1. **Comprehensive Coverage**: Tests actual deep link parsing, validation, and state management
2. **No Production Code Impact**: Removes debug buttons and test-specific UI elements
3. **Reliable**: Doesn't depend on XCUITest deep link limitations
4. **Fast Execution**: Integration tests run much faster than UI tests
5. **Better Debugging**: Can directly inspect state and add detailed assertions

## Implementation Plan

### Phase 1: Create Integration Tests
1. Create `DeepLinkIntegrationTests.swift` in the unit test target
2. Implement comprehensive test cases covering:
   - Valid deep link processing
   - Invalid scheme rejection
   - Duration parsing (seconds, minutes, various formats)
   - Timer preset application
   - State management

### Phase 2: Clean Up UI Test
1. Remove debug simulation button from `TimerStartView`
2. Remove debug text display
3. Either:
   - Delete the failing UI test entirely, OR
   - Simplify it to test only UI presentation (manually trigger timer view)

### Phase 3: Verify Real-World Functionality
1. Manual testing of deep links from:
   - Widgets
   - Control Center
   - Safari/other apps
   - Shortcuts app
2. Consider adding end-to-end tests using device automation if needed

## Alternative Approaches Considered

### Option A: Fix XCUITest Deep Link Handling
- Research alternative XCUITest methods for deep links
- Investigate `XCUIApplication.launch(withArguments:, environment:)` with deep link parameters
- **Risk**: May not be possible or reliable across iOS versions

### Option B: Hybrid UI + Integration Testing
- Keep simplified UI test for visual verification
- Add integration tests for deep link logic
- **Downside**: More maintenance overhead, potential duplication

### Option C: Mock-Based UI Testing
- Inject mock deep link handler for UI tests
- **Downside**: Adds complexity, doesn't test real integration

## Risks and Considerations

### Risks
- Integration tests don't verify actual UI presentation
- Real deep link bugs in iOS URL handling wouldn't be caught
- Manual testing burden increases

### Mitigation
- Supplement with manual testing checklist
- Consider periodic device-based testing
- Monitor crash reports and user feedback for deep link issues

## Success Criteria

- [ ] All deep link scenarios covered by fast, reliable integration tests
- [ ] Debug code removed from production views
- [ ] Test execution time reduced (integration tests vs UI tests)
- [ ] Test flakiness eliminated
- [ ] Real deep link functionality verified through manual testing

## Timeline

**Estimated Effort**: 1-2 days
- 0.5 day: Create integration test suite
- 0.5 day: Clean up UI test and debug code
- 0.5 day: Manual testing and verification
- 0.5 day: Documentation and review

## Related Files

- `LittleMoments/Tests/UITests/TimerDeepLinkUITests.swift` - Current failing test
- `LittleMoments/Features/Timer/Views/TimerStartView.swift` - Contains debug code
- `LittleMoments/Features/Timer/Views/TimerRunningView.swift` - Race condition fix
- `LittleMoments/Features/Timer/Models/TimerViewModel.swift` - Preset duration logic
- `LittleMoments/App/iOS/Little_MomentsApp.swift` - Deep link handler
- `LittleMoments/Tests/UnitTests/CoreTests/DeepLinkTests.swift` - Existing unit tests
