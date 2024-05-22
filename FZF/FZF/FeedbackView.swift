//
//  FeedbackView.swift
//  FZF
//
//  Created by 天豪刘 on 2024-05-21.
//

import SwiftUI

struct FeedbackView: View {
    @State private var generalScore: Double = 0
    @State private var noiseLevel: Double = 0
    @State private var spaciousness: Double = 0

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
                    // Handle feedback submission here
                    print("Feedback submitted")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.teal)
                .cornerRadius(10)
            }
            .navigationBarTitle("Feedback", displayMode: .inline)
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
