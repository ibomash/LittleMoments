//
//  AppState.swift
//  Little Moments
//
//  Created by Illya Bomash on 1/16/25.
//

import SwiftUI

class AppState: ObservableObject {
  static let shared = AppState()
  @Published var showTimerRunningView: Bool = false
}
