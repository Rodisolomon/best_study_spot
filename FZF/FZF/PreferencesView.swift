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
    @State private var hasLargeTables = true
    @State private var hasNoMusic = true
    @State private var mustHaveOutlets = true // Correcting this Toggle state
    @State private var maxDistance = 5.0

    var body: some View {
        Form {
            Section(header: Text("Choose your focus zone preferences.")) {
                Picker("Light Level", selection: $lightLevel) {
                    Text("High").tag("High")
                    Text("Medium").tag("Medium")
                    Text("Low").tag("Low")
                }

                Picker("Noise Level", selection: $noiseLevel) {
                    Text("Low").tag("Low")
                    Text("Medium").tag("Medium")
                    Text("High").tag("High")
                }
                
                Picker("Space Size", selection: $spaceSize) {
                    Text("Small").tag("Small")
                    Text("Medium").tag("Medium")
                    Text("Large").tag("Large")
                }
                
                Picker("Crowded Level", selection: $isCrowded) {
                    Text("Empty").tag("Empty")
                    Text("Medium").tag("Medium")
                    Text("Very busy").tag("Very busy")
                }

                Toggle("Large Tables", isOn: $hasLargeTables)
                Toggle("No Background Music", isOn: $hasNoMusic)
                Toggle("Must have outlets", isOn: $mustHaveOutlets) // Updated Toggle

                Stepper("Maximum Distance: \(maxDistance, specifier: "%.1f") km", value: $maxDistance, in: 0...10, step: 0.5)
            }
            
        }
        .navigationBarTitle("Preferences")
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
