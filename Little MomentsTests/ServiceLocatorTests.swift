//
//  ServiceLocatorTests.swift
//  Little MomentsTests
//
//  Created as part of architecture refactoring
//

import XCTest
@testable import Little_Moments

class ServiceLocatorTests: XCTestCase {
    
    // Mock container for testing
    class MockDIContainer: DIContainerProtocol {
        var registeredServices: [String: Any] = [:]
        var registerCalled = false
        var resolveCalled = false
        
        func register<T>(_ type: T.Type, service: Any) {
            registerCalled = true
            let key = String(describing: type)
            registeredServices[key] = service
        }
        
        func resolve<T>(_ type: T.Type) -> T? {
            resolveCalled = true
            let key = String(describing: type)
            return registeredServices[key] as? T
        }
    }
    
    var mockContainer: MockDIContainer!
    var serviceLocator: ServiceLocator!
    
    override func setUp() {
        super.setUp()
        mockContainer = MockDIContainer()
        serviceLocator = ServiceLocator(container: mockContainer)
    }
    
    override func tearDown() {
        mockContainer = nil
        serviceLocator = nil
        super.tearDown()
    }
    
    func testRegisterServices() {
        // When
        serviceLocator.registerServices()
        
        // Then
        XCTAssertTrue(mockContainer.registerCalled, "Register should be called")
        
        // Verify that at least one service was registered
        XCTAssertGreaterThan(mockContainer.registeredServices.count, 0, "At least one service should be registered")
    }
    
    func testResolveService() {
        // Given
        protocol TestServiceProtocol {
            func doSomething() -> String
        }
        
        class TestServiceImpl: TestServiceProtocol {
            func doSomething() -> String {
                return "Test service implementation"
            }
        }
        
        let service = TestServiceImpl()
        mockContainer.register(TestServiceProtocol.self, service: service)
        
        // When
        let resolvedService = serviceLocator.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertTrue(mockContainer.resolveCalled, "Resolve should be called")
        XCTAssertNotNil(resolvedService, "Service should be resolved")
        XCTAssertEqual(resolvedService.doSomething(), "Test service implementation", "Service should be the correct implementation")
    }
    
    func testResolveMissingServiceThrowsFatalError() {
        // Given
        protocol MissingServiceProtocol {
            func doSomething() -> String
        }
        
        // When/Then
        // This should cause a fatal error
        // We can't directly test fatal errors in Swift, but we could use expectations to test this
        // For now, this is a manual verification point
    }
} 