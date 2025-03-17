//
//  ServiceLocator.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation

// Import the DI container
@_implementationOnly import DIContainer

// Import service protocols and implementations
@_implementationOnly import SettingsService
@_implementationOnly import HealthKitService
@_implementationOnly import SoundService

/// Service Locator provides a centralized registry for all application services
/// This helps manage dependencies and simplifies testing
final class ServiceLocator {
    /// Shared instance of the service locator
    static let shared = ServiceLocator()
    
    /// The underlying DI container
    private let container: DIContainerProtocol
    
    /// Private initializer to enforce singleton pattern
    /// For testing, you can inject a mock container
    init(container: DIContainerProtocol = DIContainer.shared) {
        self.container = container
    }
    
    /// Registers all application services
    func registerServices() {
        registerSettingsService()
        registerHealthKitService()
        registerSoundService()
    }
    
    /// Registers the settings service
    private func registerSettingsService() {
        let service = SettingsServiceImpl()
        container.register(SettingsServiceProtocol.self, service: service)
    }
    
    /// Registers the HealthKit service
    private func registerHealthKitService() {
        let service = HealthKitServiceImpl()
        container.register(HealthKitServiceProtocol.self, service: service)
    }
    
    /// Registers the sound service
    private func registerSoundService() {
        let service = SoundServiceImpl()
        container.register(SoundServiceProtocol.self, service: service)
    }
    
    /// Resolves a service from the container
    /// - Parameter type: The protocol type to resolve
    /// - Returns: An instance that implements the protocol
    func resolve<T>(_ type: T.Type) -> T {
        guard let service = container.resolve(type) else {
            fatalError("Failed to resolve service of type \(type). Make sure it is registered properly.")
        }
        return service
    }
    
    /// Resets the container, removing all registered services
    /// This is primarily useful for testing
    func reset() {
        if let container = container as? DIContainer {
            container.reset()
        }
    }
} 