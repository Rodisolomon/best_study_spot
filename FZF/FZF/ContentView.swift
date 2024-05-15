//
//  ContentView.swift
//  FZF
//
//  Created by Tracy on 2024/5/13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack {
            if let location = locationManager.userLocation {
                Text("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            } else {
                Text("Fetching location...")
            }
        }
        .onAppear {
            locationManager.locationManager.requestWhenInUseAuthorization()
        }
    }
}
