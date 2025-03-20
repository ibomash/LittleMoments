//
//  ImageButton.swift
//  Just Now
//
//  Created by Illya Bomash on 5/29/23.
//

// import Foundation
import SwiftUI

struct ImageButton: View {
  let imageName: String
  let buttonText: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(buttonText, systemImage: imageName)
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
  }
}
