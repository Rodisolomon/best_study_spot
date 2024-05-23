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
    @State private var submissionError: SubmissionError?

    struct SubmissionError: Identifiable {
        let id = UUID()
        let message: String
    }

    var body: some View {
        Form {
            Section(header: Text("Choose your focus zone preferences.")) {
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
                Toggle("Exclusive to Student", isOn: $studentExclusive)
                Toggle("I want to collaborate", isOn: $canCollaborate)
                Toggle("Must have wi-fi", isOn: $mustHaveNetwork)

                Stepper("Maximum Distance: \(maxDistance, specifier: "%.1f") km", value: $maxDistance, in: 0...10, step: 0.5)
            }

            Button("Save & Continue") {
                savePreferences()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .cornerRadius(10)
            .alert(isPresented: $submissionSuccess) {
                Alert(
                    title: Text("Preferences Submitted"),
                    message: Text("Your preferences have been saved successfully."),
                    primaryButton: .default(Text("OK")) {
                        selectedTab = .search
                    },
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
            .alert(item: $submissionError) { error in
                Alert(title: Text("Submission Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
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
            submissionError = SubmissionError(message: "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: preferences, options: [])
            request.httpBody = jsonData
        } catch {
            submissionError = SubmissionError(message: "Failed to serialize JSON")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    submissionError = SubmissionError(message: error.localizedDescription)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    submissionError = SubmissionError(message: "Invalid response from server")
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
