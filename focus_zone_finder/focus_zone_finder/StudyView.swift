//
//  ContentView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-14.
//
import SwiftUI

struct StudyView: View {
    @State private var isFocusing: Bool = false
    @State private var secondsElapsed: Int = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Spacer() // Adds space at the top

            Text("Focus Zone")
                .font(.title)
                .fontWeight(.semibold)

            Image("bookIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150) // Set the image size
                .padding(.top, 20) // Space between the text and the image

            if isFocusing {
                Text(formatTime(seconds: secondsElapsed))
                    .font(.largeTitle)
                    .padding(.top, 20)
                Button("End Focus") {
                    endFocus()
                }
                .foregroundColor(.white)
                .frame(width: 170, height: 20)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            } else {
                Button("Start Focus") {
                    startFocus()
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 200, height: 50)
                .background(Color.green)
                .cornerRadius(10)
            }

            Button(action: {
                // Action for the button
            }) {
                Text("Collect Data")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50) // Specific size for the button
                    .background(Color.teal)
                    .cornerRadius(10) // Rounded corners
            }
            .padding(.top, 10) // Space between the image and the button

            Spacer() // Adds space at the bottom
        }
        .padding()
        .navigationTitle("Study")
    }

    func startFocus() {
        isFocusing = true
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsElapsed += 1
        }
    }

    func endFocus() {
        isFocusing = false
        timer?.invalidate()
        timer = nil
        // Here, you can also handle the storage or processing of the focus duration
    }

    func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
