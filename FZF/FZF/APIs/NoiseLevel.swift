//
//  NoiseLevel.swift
//  FZF
//
//  Created by Tracy on 2024/5/15.
//

import Foundation
import AVFoundation

class NoiseService: NSObject, ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let url = URL(fileURLWithPath: "/dev/null")

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.audioRecorder?.updateMeters()
                let averagePower = self.audioRecorder?.averagePower(forChannel: 0) ?? 0
                let noiseLevel = self.convertToDecibels(averagePower: averagePower)
                self.sendNoiseLevel(noiseLevel)
            }
        } catch {
            print("Failed to set up recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        timer?.invalidate()
        timer = nil
    }

    private func convertToDecibels(averagePower: Float) -> Int {
        let minDb: Float = -80.0
        let level = max(0.0, min(1.0, (averagePower - minDb) / -minDb))
        return Int(level * 100)
    }

    private func sendNoiseLevel(_ noiseLevel: Int) {
        guard let url = URL(string: "http://192.168.x.x:5000/api/environment/noise") else { return }  // Replace with your actual IP address
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: Any] = ["level": noiseLevel]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending noise level: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            print("Noise level sent successfully")
        }

        task.resume()
    }
}
