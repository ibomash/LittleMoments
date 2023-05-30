//
//  SettingsView.swift
//  Just Now
//
//  Created by Illya Bomash on 5/29/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
  @Environment(\.presentationMode)
  var presentationMode

  var writeToHealth: Bool = false

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Health")) {
          // Toggle(isOn: writeToHealth, label: { Text("Write session to Health") })
          Text("Settings Go Here")
        }

        Section(header: Text("Next Settings")) {
          Text("Settings Go Here")
        }
      }
      .navigationBarTitle("Settings")
      .navigationBarItems(
        trailing: Button(
          "Dismiss",
          action: {
            self.presentationMode.wrappedValue.dismiss()
          }))
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
