import Foundation
import UIKit

/// Manager class responsible for providing haptic feedback during meditation sessions.
/// This provides tactile feedback for session completion to enhance the user experience
/// without being intrusive during the meditation itself.
class HapticFeedbackManager {
  /// Shared singleton instance for app-wide access
  static let shared = HapticFeedbackManager()
  
  /// Private initializer to enforce singleton pattern
  private init() {}
  
  /// Provides haptic feedback when a meditation session is completed successfully.
  /// This uses UINotificationFeedbackGenerator with success type to indicate
  /// a positive completion event.
  func provideCompletionFeedback() {
    // Check if haptic feedback is available on this device
    guard UIDevice.current.userInterfaceIdiom == .phone else {
      print("ℹ️ Haptic feedback not available on this device type")
      return
    }
    
    print("🔄 Providing haptic feedback for session completion")
    
    // Create and prepare the feedback generator
    let feedbackGenerator = UINotificationFeedbackGenerator()
    feedbackGenerator.prepare()
    
    // Provide success notification feedback
    feedbackGenerator.notificationOccurred(.success)
    
    print("✅ Haptic feedback provided for session completion")
  }
}