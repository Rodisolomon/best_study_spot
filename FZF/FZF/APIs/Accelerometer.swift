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
            motionManager.accelerometerUpdateInterval = 1
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }

                let stable = self.isStable(acceleration: data.acceleration)
                //print("Acceleration X: \(data.acceleration.x), Y: \(data.acceleration.y), Z: \(data.acceleration.z), Is Stable: \(stable)")
                self.motionDetected?(stable)
            }
        }
    }

    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }

    private func isStable(acceleration: CMAcceleration) -> Bool {
        let rangeX = (0.01)...(0.06)
        let rangeY = (0.01)...(0.06)
        let rangeZ = (0.8)...(1.2)

        // Check if current acceleration values fall within the stable range
        let isStableX = rangeX.contains(abs(acceleration.x))
        let isStableY = rangeY.contains(abs(acceleration.y))
        let isStableZ = rangeZ.contains(abs(acceleration.z))

        return isStableX && isStableY && isStableZ
    }
}
