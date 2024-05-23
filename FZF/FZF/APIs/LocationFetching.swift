import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    private var lastSentLocation: CLLocation?
    private let distanceThreshold: CLLocationDistance = 10.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let lastLocation = lastSentLocation {
            let distance = location.distance(from: lastLocation)
            if distance < distanceThreshold {
                return
            }
        }

        userLocation = location
        let roundedLatitude = round(location.coordinate.latitude * 1000) / 1000
        let roundedLongitude = round(location.coordinate.longitude * 1000) / 1000
                
        userLocation = CLLocation(latitude: roundedLatitude, longitude: roundedLongitude)
        sendLocation(latitude: roundedLatitude, longitude: roundedLongitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    private func sendLocation(latitude: Double, longitude: Double) {
        guard let url = URL(string: "\(Constants.baseURL)/api/location") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: Any] = ["latitude": latitude, "longitude": longitude]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending location: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            self.lastSentLocation = CLLocation(latitude: latitude, longitude: longitude) 
        }
        task.resume()
    }
}
