import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
<<<<<<< HEAD
    @StateObject private var noiseService = NoiseService()
    @State private var isRecording = false

=======
>>>>>>> c4fbeabe805ad3082ab67233c75c3af05b48fa4e
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
<<<<<<< HEAD
        } detail: {
            Text("Select an item")
        }
=======
        }
        
//        .onAppear {
//            locationManager.locationManager.requestWhenInUseAuthorization()
//        }
>>>>>>> c4fbeabe805ad3082ab67233c75c3af05b48fa4e
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}

