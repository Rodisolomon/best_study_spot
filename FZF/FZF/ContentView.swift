import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var noiseService = NoiseService()
    @State private var isStudying = false

    var body: some View {
        NavigationSplitView {
            VStack {
                if let location = locationManager.userLocation {
                    Text("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
                } else {
                    Text("Fetching location...")
                }
                
                Button(action: {
                    isStudying.toggle()
                    if isStudying {
                        startStudying()
                    } else {
                        stopStudying()
                    }
                }) {
                    Text(isStudying ? "Stop Studying" : "Start Studying")
                        .foregroundColor(.white)
                        .padding()
                        .background(isStudying ? Color.red : Color.green)
                        .cornerRadius(8)
                }
                .padding()

                if noiseService.isSensing {
                    Text("Sensing Noise...")
                        .foregroundColor(.red)
                } else {
                    Text("Not Sensing")
                        .foregroundColor(.green)
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func startStudying() {
        noiseService.accelerometerService.startAccelerometerUpdates()
        noiseService.startSensingCycle()
    }
    
    private func stopStudying() {
        noiseService.stopSensingCycle()
        noiseService.accelerometerService.stopAccelerometerUpdates()
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
