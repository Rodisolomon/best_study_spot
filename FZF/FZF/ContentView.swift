import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var noiseService = NoiseService()
    @State private var isRecording = false

    var body: some View {
        NavigationSplitView {
            VStack {
                if let location = locationManager.userLocation {
                    Text("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
                } else {
                    Text("Fetching location...")
                }
                
                Button(action: {
                    isRecording.toggle()
                    if isRecording {
                        noiseService.startRecording()
                    } else {
                        noiseService.stopRecording()
                    }
                }) {
                    Text(isRecording ? "Stop Recording Noise" : "Start Recording Noise")
                        .foregroundColor(.white)
                        .padding()
                        .background(isRecording ? Color.red : Color.green)
                        .cornerRadius(8)
                }
                .padding()
            }
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}

