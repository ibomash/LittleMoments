//
//  DIServices.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation
import SwiftUI
import AVFoundation
import HealthKit

// MARK: - DI Container

/// A protocol defining a dependency injection container
protocol DIContainerProtocol {
    /// Registers a service with the container
    /// - Parameters:
    ///   - type: The protocol type to register
    ///   - service: The instance that implements the protocol
    func register<T>(_ type: T.Type, service: Any)
    
    /// Resolves a service from the container
    /// - Parameter type: The protocol type to resolve
    /// - Returns: An instance that implements the protocol
    func resolve<T>(_ type: T.Type) -> T?
}

/// A concrete implementation of the DIContainerProtocol
final class DIContainer: DIContainerProtocol {
    /// The shared instance of the DIContainer
    static let shared = DIContainer()
    
    /// Private storage for services
    private var services: [String: Any] = [:]
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Registers a service with the container
    /// - Parameters:
    ///   - type: The protocol type to register
    ///   - service: The instance that implements the protocol
    func register<T>(_ type: T.Type, service: Any) {
        let key = String(describing: type)
        services[key] = service
    }
    
    /// Resolves a service from the container
    /// - Parameter type: The protocol type to resolve
    /// - Returns: An instance that implements the protocol
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
    
    /// Resets the container, removing all registered services
    /// This is primarily useful for testing
    func reset() {
        services.removeAll()
    }
}

// MARK: - Service Locator

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

// MARK: - Helper Functions

/// A global function for accessing services
func service<T>(_ type: T.Type) -> T {
    return ServiceLocator.shared.resolve(type)
}

// MARK: - Settings Service Protocol

/// Protocol defining the settings service functionality
protocol SettingsServiceProtocol {
    /// Whether to write meditation sessions to HealthKit
    var writeToHealth: Bool { get set }
    
    /// Whether to ring the bell at the start of a session
    var ringBellAtStart: Bool { get set }
    
    /// Whether to show seconds in the timer display
    var showSeconds: Bool { get set }
}

// MARK: - HealthKit Service Protocol

/// Protocol defining the HealthKit service functionality
protocol HealthKitServiceProtocol {
    /// Requests authorization to access HealthKit data
    /// - Parameter completion: Closure called when authorization request completes
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void)
    
    /// Creates a mindful session with start and end dates
    /// - Parameters:
    ///   - startDate: Start date of the session
    ///   - endDate: End date of the session
    /// - Returns: A HealthKit sample representing the mindful session
    func createMindfulSession(startDate: Date, endDate: Date) -> HKCategorySample
    
    /// Saves a mindful session to HealthKit
    /// - Parameters:
    ///   - mindfulSession: The session to save
    ///   - completion: Closure called when save operation completes
    func saveMindfulSession(mindfulSession: HKCategorySample, completion: @escaping (Bool, Error?) -> Void)
}

// MARK: - Sound Service Protocol

/// Protocol defining the sound service functionality
protocol SoundServiceProtocol {
    /// Initializes the sound service
    func initialize()
    
    /// Plays the meditation bell sound
    func playSound()
    
    /// Releases resources used by the sound service
    func dispose()
} 