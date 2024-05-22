//
//  PreferencesView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-21.
//
import SwiftUI


struct PreferencesView: View {
    @Binding var selectedTab: MainTabView.Tab
    @State private var lightLevel = "High"
    @State private var noiseLevel = "Low"
    @State private var spaceSize = "Small"
    @State private var isCrowded = "Empty"
    @State private var canCollaborate = true
    @State private var mustHaveNetwork = true
    @State private var studentExclusive = true
    @State private var maxDistance = 5.0
    @State private var submissionSuccess = false
    @State private var submissionError: String?

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

                Button(action: {
                            savePreferences()
                        }) {
                            Text("Save & Continue")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.teal)
                                .cornerRadius(10)
                        }
                        .alert(isPresented: $submissionSuccess) {
                            Alert(
                                title: Text("Preferences Submitted"),
                                message: Text("Your preferences have been saved successfully."),
                                dismissButton: .default(Text("OK")) {
                                    selectedTab = .search
                                }
                            )
                        }
        }
        .navigationBarTitle("Preferences")
        
    }
            private func savePreferences() {
            let preferences: [String: Any] = [
                "lightLevel": lightLevel,
                "noiseLevel": noiseLevel,
                "spaceSize": spaceSize,
                "isCrowded": isCrowded,
                "canCollaborate": canCollaborate,
                "mustHaveNetwork": mustHaveNetwork,
                "studentExclusive": studentExclusive,
                "maxDistance": maxDistance
            ]

            guard let url = URL(string: "\(Constants.baseURL)/api/preference") else {
                submissionError = "Invalid URL"
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: preferences, options: [])
                request.httpBody = jsonData
            } catch {
                submissionError = "Failed to serialize JSON"
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        submissionError = error.localizedDescription
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        submissionError = "Invalid response from server"
                        return
                    }

                    submissionSuccess = true
                }
            }.resume()
        }
    }

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(selectedTab: .constant(.preferences))
    }
}
