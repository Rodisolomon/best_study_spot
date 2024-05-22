//
//  FZFApp.swift
//  FZF
//
//  Created by Tracy on 2024/5/13.
//

import SwiftUI

@main
struct FZFApp: App {
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(locationManager)
        }
    }
}
