//
//  LargeBlueButtonView.swift
//  Little Moments
//
//  Created by Illya Bomash on 5/1/23.
//

import SwiftUI

struct LargeBlueButtonView: View {
  var buttonText: String
  var buttonAction: () -> Void

  var body: some View {
    Button(action: buttonAction) {
      Text(buttonText)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color.blue)
        .cornerRadius(10)
    }
  }
}

//struct LargeBlueButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeBlueButtonView()
//    }
//}
//
