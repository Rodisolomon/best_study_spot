//
//  PreferencesView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-21.
//
import SwiftUI

struct PreferencesView: View {
    @State private var lightLevel = "High"
    @State private var noiseLevel = "Low"
    @State private var spaceSize = "Small"
    @State private var isCrowded = "Empty"
    @State private var canCollaborate = true
    @State private var mustHaveNetwork = true // Correcting this Toggle state
    @State private var studentExclusive = true // Correcting this Toggle state
    @State private var maxDistance = 5.0

    var body: some View {
        Form {
            Section(header: Text("Choose your focus zone preferences.")) {

                Picker("Noise Level", selection: $noiseLevel) {
                    Text("Low").tag("Low") //0-1
                    Text("Medium").tag("Medium") //2-3
                    Text("High").tag("High") //4-5
                }
                
                Picker("Space Size", selection: $spaceSize) {
                    Text("Small").tag("Small") //similar as above
                    Text("Medium").tag("Medium")
                    Text("Large").tag("Large")
                }
                Toggle("Exclusive to Student", isOn: $studentExclusive)
                Toggle("I want to collaborate", isOn: $canCollaborate)
                Toggle("Must have wi-fi", isOn: $mustHaveNetwork) // Updated Toggle

                Stepper("Maximum Distance: \(maxDistance, specifier: "%.1f") km", value: $maxDistance, in: 0...10, step: 0.5)
            }

            NavigationLink("Save & Continue", destination: SearchView())
        }
        .navigationBarTitle("Preferences")
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
