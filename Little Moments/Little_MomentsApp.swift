//
//  Little_MomentsApp.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI
import AVFoundation

// The app is in a transitional state with both the old
// singleton approach and the new DI approach available.
// During refactoring, we'll gradually migrate from
// singletons to DI.

@main
struct Little_MomentsApp: App {
    init() {
        // Initialize sound services
        // During the transition, we use the old approach:
        SoundManager.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            TimerStartView()
        }
    }
    
    func onExitCommand() {
        // Clean up resources
        // During the transition, we use the old approach:
        SoundManager.dispose()
    }
}

// MARK: - DI Implementation Notes
/*
 To complete Phase 1 of the refactoring, we'll:
 
 1. Implement all service protocols and implementations
 2. Connect the DI container and service locator
 3. Update existing views to use the new services
 4. Add tests for dependency injection
 
 Current blockers:
 - Import/module issues need to be resolved
 - Need to update the Xcode project structure
 
 Progress so far:
 - Created all service protocols
 - Implemented the core DI container
 - Created the service locator pattern
 */
