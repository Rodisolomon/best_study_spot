//import SwiftUI
//import CoreLocation
//
//struct StudyView: View {
//    @EnvironmentObject var locationManager: LocationManager
//    @StateObject private var noiseService = NoiseService()
//    @State private var isFocusing: Bool = false
//    @State private var secondsElapsed: Int = 0
//    @State private var timer: Timer?
//    @State private var showFeedbackView = false
//
//    var body: some View {
//        NavigationSplitView {
//            VStack {
//                Spacer()
//
//                Text("Focus Zone")
//                    .font(.title)
//                    .fontWeight(.semibold)
//
//                Image("bookIcon")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 200, height: 200)
//                    .padding(.top, 20)
//
//                if let location = locationManager.userLocation {
//                    let roundedLatitude = String(format: "%.2f", location.coordinate.latitude)
//                    let roundedLongitude = String(format: "%.2f", location.coordinate.longitude)
//                    Text("Latitude: \(roundedLatitude), Longitude: \(roundedLongitude)")
//                } else {
//                    Text("Fetching location...")
//                }
//
//                if isFocusing {
//                    Text(formatTime(seconds: secondsElapsed))
//                        .font(.largeTitle)
//                        .padding(.top, 20)
//                    Button("End Focus") {
//                        endFocus()
//                    }
//                    .foregroundColor(.white)
//                    .frame(width: 170, height: 20)
//                    .padding()
//                    .background(Color.red)
//                    .cornerRadius(10)
//                } else {
//                    Button("Start Focus") {
//                        startFocus()
//                    }
//                    .foregroundColor(.white)
//                    .padding()
//                    .frame(width: 200, height: 50)
//                    .background(Color.teal)
//                    .cornerRadius(10)
//                }
//
//                if noiseService.isSensing {
//                    Text("Sensing Noise...")
//                        .foregroundColor(.red)
//                } else {
//                    Text("Not Sensing")
//                        .foregroundColor(.teal)
//                }
//                
//                NavigationLink(destination: FeedbackView(), isActive: $showFeedbackView) {
//                    EmptyView()
//                }
//
//                Spacer()
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func startFocus() {
//        isFocusing = true
//        secondsElapsed = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            secondsElapsed += 1
//        }
//        noiseService.accelerometerService.startAccelerometerUpdates()
//        noiseService.startSensingCycle()
//    }
//
//    private func endFocus() {
//        isFocusing = false
//        timer?.invalidate()
//        timer = nil
//        noiseService.stopSensingCycle()
//        noiseService.accelerometerService.stopAccelerometerUpdates()
//        showFeedbackView = true  // Set to true to show the feedback view
//    }
//
//    private func formatTime(seconds: Int) -> String {
//        let hours = seconds / 3600
//        let minutes = (seconds % 3600) / 60
//        let seconds = seconds % 60
//        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
//    }
//}
//
//struct StudyView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyView()
//            .environmentObject(LocationManager())
//    }
//}


import SwiftUI
import CoreLocation

struct StudyView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var noiseService = NoiseService()
    @State private var isFocusing: Bool = false
    @State private var secondsElapsed: Int = 0
    @State private var timer: Timer?
    @State private var showFeedbackView = false
    @State private var showAlert = false

    var body: some View {
        NavigationSplitView {
            VStack {
                Spacer()

                Text("Focus Zone")
                    .font(.title)
                    .fontWeight(.semibold)

                Image("bookIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200) // Set the image size
                    .padding(.top, 20) // Space between the text and the image

                if let location = locationManager.userLocation {
                    let roundedLatitude = String(format: "%.2f", location.coordinate.latitude)
                    let roundedLongitude = String(format: "%.2f", location.coordinate.longitude)
                    Text("Latitude: \(roundedLatitude), Longitude: \(roundedLongitude)")
                } else {
                    Text("Fetching location...")
                }

                if isFocusing {
                    Text(formatTime(seconds: secondsElapsed))
                        .font(.largeTitle)
                        .padding(.top, 20)
                    Button("End Focus") {
                        showAlert = true
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
                    .background(Color.teal)
                    .cornerRadius(10)
                }

                if noiseService.isSensing {
                    Text("Sensing Noise...")
                        .foregroundColor(.red)
                } else {
                    Text("Not Sensing")
                        .foregroundColor(.teal)
                }
                
                NavigationLink(destination: FeedbackView(), isActive: $showFeedbackView) {
                    EmptyView()
                }

                Spacer()
            }
        } detail: {
            Text("Select an item")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("End Focus"),
                message: Text("Do you want to leave this location and provide feedback?"),
                primaryButton: .default(Text("Leave")) {
                    endFocus()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func startFocus() {
        isFocusing = true
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsElapsed += 1
        }
        noiseService.accelerometerService.startAccelerometerUpdates()
        noiseService.startSensingCycle()
    }

    private func endFocus() {
        isFocusing = false
        timer?.invalidate()
        timer = nil
        noiseService.manualStopSensingCycle()
        noiseService.accelerometerService.stopAccelerometerUpdates()
        showFeedbackView = true  
    }


    private func formatTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
            .environmentObject(LocationManager())
    }
}
