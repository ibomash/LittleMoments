//
//  SettingsServiceTests.swift
//  Little MomentsTests
//
//  Created as part of architecture refactoring
//

import XCTest
@testable import Little_Moments

class SettingsServiceTests: XCTestCase {
    
    var userDefaults: UserDefaults!
    var mockHealthKitService: MockHealthKitService!
    var settingsService: SettingsServiceImpl!
    
    class MockHealthKitService: HealthKitServiceProtocol {
        var authorizationRequested = false
        var authorizationHandler: ((Bool, Error?) -> Void)?
        
        func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
            authorizationRequested = true
            authorizationHandler = completion
        }
        
        func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample {
            fatalError("Not implemented in mock")
        }
        
        func saveMindfulSession(mindfulSession: HKCategorySample, completion: @escaping (Bool, Error?) -> Void) {
            fatalError("Not implemented in mock")
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // Create a unique identifier for this test run to avoid conflicts with other tests
        let suiteName = "SettingsServiceTests_\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        
        mockHealthKitService = MockHealthKitService()
        settingsService = SettingsServiceImpl(
            userDefaults: userDefaults,
            healthKitService: mockHealthKitService
        )
    }
    
    override func tearDown() {
        userDefaults.removeSuite(named: userDefaults.suiteName ?? "")
        userDefaults = nil
        mockHealthKitService = nil
        settingsService = nil
        super.tearDown()
    }
    
    func testWriteToHealthDefaultValue() {
        // When the key doesn't exist
        // Then it should return false (default)
        XCTAssertFalse(settingsService.writeToHealth, "Default value should be false")
    }
    
    func testWriteToHealthSetsAndGetsValue() {
        // When we set the value to true
        settingsService.writeToHealth = true
        
        // Then it should be retrieved as true
        XCTAssertTrue(settingsService.writeToHealth, "Value should be true after setting")
        
        // And authorization should be requested
        XCTAssertTrue(mockHealthKitService.authorizationRequested, "HealthKit authorization should be requested")
    }
    
    func testRingBellAtStartDefaultValue() {
        // When the key doesn't exist
        // Then it should return the default value (true)
        XCTAssertTrue(settingsService.ringBellAtStart, "Default value should be true")
    }
    
    func testRingBellAtStartSetsAndGetsValue() {
        // When we set the value to false
        settingsService.ringBellAtStart = false
        
        // Then it should be retrieved as false
        XCTAssertFalse(settingsService.ringBellAtStart, "Value should be false after setting")
    }
    
    func testShowSecondsDefaultValue() {
        // When the key doesn't exist
        // Then it should return the default value (true)
        XCTAssertTrue(settingsService.showSeconds, "Default value should be true")
    }
    
    func testShowSecondsSetsAndGetsValue() {
        // When we set the value to false
        settingsService.showSeconds = false
        
        // Then it should be retrieved as false
        XCTAssertFalse(settingsService.showSeconds, "Value should be false after setting")
    }
} 