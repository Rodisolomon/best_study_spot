//
//  FeedbackView.swift
//  FZF
//
//  Created by 天豪刘 on 2024-05-21.
//

//import SwiftUI
//
//struct FeedbackView: View {
//    @State private var generalScore: Double = 0
//    @State private var noiseLevel: Double = 0
//    @State private var spaciousness: Double = 0
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Rate your study location")) {
//                    VStack(alignment: .leading) {
//                        Text("Overall Score: \(Int(generalScore))")
//                        Slider(value: $generalScore, in: 0...5, step: 1)
//                        Text("0 - Very Bad   5 - Very Good")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//
//                    VStack(alignment: .leading) {
//                        Text("Noise Level: \(Int(noiseLevel))")
//                        Slider(value: $noiseLevel, in: 0...5, step: 1)
//                        Text("0 - Very Bad   5 - Very Good")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//
//                    VStack(alignment: .leading) {
//                        Text("Spaciousness: \(Int(spaciousness))")
//                        Slider(value: $spaciousness, in: 0...5, step: 1)
//                        Text("0 - Very Bad   5 - Very Good")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
//                
//                Button("Submit Feedback") {
//                    // Handle feedback submission here
//                    print("Feedback submitted")
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.teal)
//                .cornerRadius(10)
//            }
//            .navigationBarTitle("Feedback", displayMode: .inline)
//        }
//    }
//}
//
//struct FeedbackView_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedbackView()
//    }
//}

import SwiftUI

struct FeedbackView: View {
    @State private var generalScore: Double = 0
    @State private var noiseLevel: Double = 0
    @State private var spaciousness: Double = 0
    @State private var isSubmitting = false
    @State private var submissionSuccess = false
    @State private var submissionError: SubmissionError?

    struct SubmissionError: Identifiable {
        let id = UUID()
        let message: String
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rate your study location")) {
                    VStack(alignment: .leading) {
                        Text("Overall Score: \(Int(generalScore))")
                        Slider(value: $generalScore, in: 0...5, step: 1)
                        Text("0 - Very Bad   5 - Very Good")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading) {
                        Text("Noise Level: \(Int(noiseLevel))")
                        Slider(value: $noiseLevel, in: 0...5, step: 1)
                        Text("0 - Very Bad   5 - Very Good")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading) {
                        Text("Spaciousness: \(Int(spaciousness))")
                        Slider(value: $spaciousness, in: 0...5, step: 1)
                        Text("0 - Very Bad   5 - Very Good")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button("Submit Feedback") {
                    submitFeedback()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.teal)
                .cornerRadius(10)
                .disabled(isSubmitting)
            }
            .navigationBarTitle("Feedback", displayMode: .inline)
            .alert(isPresented: $submissionSuccess) {
                Alert(title: Text("Feedback Submitted"), message: Text("Thank you for your feedback!"), dismissButton: .default(Text("OK")))
            }
            .alert(item: $submissionError) { error in
                Alert(title: Text("Submission Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        submissionError = nil

        guard let url = URL(string: "\(Constants.baseURL)/api/feedback") else {
            submissionError = SubmissionError(message: "Invalid URL")
            isSubmitting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let feedbackData: [String: Any] = [
            "generalScore": Int(generalScore),
            "noiseLevel": Int(noiseLevel),
            "spaciousness": Int(spaciousness)
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: feedbackData, options: []) else {
            submissionError = SubmissionError(message: "Failed to serialize JSON")
            isSubmitting = false
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false

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

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
