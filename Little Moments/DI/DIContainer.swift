//
//  DIContainer.swift
//  Little Moments
//
//  Created as part of architecture refactoring
//

import Foundation

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