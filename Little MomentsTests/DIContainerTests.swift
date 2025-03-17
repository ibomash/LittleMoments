//
//  DIContainerTests.swift
//  Little MomentsTests
//
//  Created as part of architecture refactoring
//

import XCTest
@testable import Little_Moments

class DIContainerTests: XCTestCase {
    
    // Test protocol and implementation for testing
    protocol TestServiceProtocol {
        func doSomething() -> String
    }
    
    class TestServiceImpl: TestServiceProtocol {
        func doSomething() -> String {
            return "Test service implementation"
        }
    }
    
    var container: DIContainer!
    
    override func setUp() {
        super.setUp()
        container = DIContainer.shared
        container.reset() // Start with a clean container for each test
    }
    
    override func tearDown() {
        container.reset()
        container = nil
        super.tearDown()
    }
    
    func testRegisterAndResolveService() {
        // Given
        let service = TestServiceImpl()
        
        // When
        container.register(TestServiceProtocol.self, service: service)
        let resolvedService = container.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNotNil(resolvedService, "Service should be resolved")
        XCTAssertEqual(resolvedService?.doSomething(), "Test service implementation", "Service should be the correct implementation")
    }
    
    func testResolveNonexistentService() {
        // When
        let resolvedService = container.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNil(resolvedService, "Non-existent service should not be resolved")
    }
    
    func testRegisterAndResetContainer() {
        // Given
        let service = TestServiceImpl()
        container.register(TestServiceProtocol.self, service: service)
        
        // When
        container.reset()
        let resolvedService = container.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNil(resolvedService, "Service should not be resolved after reset")
    }
    
    func testRegisterMultipleServices() {
        // Given
        protocol AnotherServiceProtocol {
            func doAnotherThing() -> String
        }
        
        class AnotherServiceImpl: AnotherServiceProtocol {
            func doAnotherThing() -> String {
                return "Another service implementation"
            }
        }
        
        let service1 = TestServiceImpl()
        let service2 = AnotherServiceImpl()
        
        // When
        container.register(TestServiceProtocol.self, service: service1)
        container.register(AnotherServiceProtocol.self, service: service2)
        
        let resolvedService1 = container.resolve(TestServiceProtocol.self)
        let resolvedService2 = container.resolve(AnotherServiceProtocol.self)
        
        // Then
        XCTAssertNotNil(resolvedService1, "Service 1 should be resolved")
        XCTAssertNotNil(resolvedService2, "Service 2 should be resolved")
        XCTAssertEqual(resolvedService1?.doSomething(), "Test service implementation", "Service 1 should be the correct implementation")
        XCTAssertEqual(resolvedService2?.doAnotherThing(), "Another service implementation", "Service 2 should be the correct implementation")
    }
} 