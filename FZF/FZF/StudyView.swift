//import SwiftUI
//import CoreLocation
//
//struct ContentView: View {
//    @EnvironmentObject var locationManager: LocationManager
//    @StateObject private var noiseService = NoiseService()
//    @State private var isStudying = false
//
//    var body: some View {
//        NavigationSplitView {
//            VStack {
//                if let location = locationManager.userLocation {
//                    Text("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
//                } else {
//                    Text("Fetching location...")
//                }
//
//                Button(action: {
//                    isStudying.toggle()
//                    if isStudying {
//                        startStudying()
//                    } else {
//                        stopStudying()
//                    }
//                }) {
//                    Text(isStudying ? "Stop Studying" : "Start Studying")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(isStudying ? Color.red : Color.green)
//                        .cornerRadius(8)
//                }
//                .padding()
//
//                if noiseService.isSensing {
//                    Text("Sensing Noise...")
//                        .foregroundColor(.red)
//                } else {
//                    Text("Not Sensing")
//                        .foregroundColor(.green)
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func startStudying() {
//        noiseService.accelerometerService.startAccelerometerUpdates()
//        noiseService.startSensingCycle()
//    }
//
//    private func stopStudying() {
//        noiseService.stopSensingCycle()
//        noiseService.accelerometerService.stopAccelerometerUpdates()
//    }
//}
//
//#Preview {
//    ContentView()
//        .environmentObject(LocationManager())
//}
import SwiftUI
import CoreLocation

struct StudyView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var noiseService = NoiseService()
    @State private var isFocusing: Bool = false
    @State private var secondsElapsed: Int = 0
    @State private var timer: Timer?

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
                    Text("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
                } else {
                    Text("Fetching location...")
                }

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


                if noiseService.isSensing {
                    Text("Sensing Noise...")
                        .foregroundColor(.red)
                } else {
                    Text("Not Sensing")
                        .foregroundColor(.green)
                }

                Spacer()
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func startFocus() {
        isFocusing = true
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsElapsed += 1
        }
        startStudying()
    }

    private func endFocus() {
        isFocusing = false
        timer?.invalidate()
        timer = nil
        stopStudying()
    }

    private func startStudying() {
        noiseService.accelerometerService.startAccelerometerUpdates()
        noiseService.startSensingCycle()
    }
    
    private func stopStudying() {
        noiseService.stopSensingCycle()
        noiseService.accelerometerService.stopAccelerometerUpdates()
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
