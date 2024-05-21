//
//  Accelerometer.swift
//  FZF
//
//  Created by Tracy on 2024/5/15.
//

import Foundation
import CoreMotion

class AccelerometerService {
    private var motionManager = CMMotionManager()
    var motionDetected: ((Bool) -> Void)?

    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 2
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                
                let isMoving = abs(data.acceleration.x) > 0.5 || abs(data.acceleration.y) > 0.5 || abs(data.acceleration.z) > 1.5
                print("Acceleration X: \(data.acceleration.x), Y: \(data.acceleration.y), Z: \(data.acceleration.z), Is Moving: \(isMoving)") // Debug print
                self.motionDetected?(isMoving)
            }
        }
    }

    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
