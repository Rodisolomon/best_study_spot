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
    private var sensingTimer: Timer?
    
    private var highestNoiseLevel: Float = -Float.greatestFiniteMagnitude
    private var lowestNoiseLevel: Float = Float.greatestFiniteMagnitude
    private var totalNoiseLevel: Float = 0
    private var noiseCount: Int = 0

    // Variables to define interval and duration
    var sensingInterval: TimeInterval = 3  // Interval between each sensing in seconds (e.g., 5 minutes)
    var sensingDuration: TimeInterval = 2    // Duration of each sensing in seconds (e.g., 2 seconds)

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

            // Start the first sensing immediately
            startSensing()

            // Schedule intermittent sensing
            sensingTimer = Timer.scheduledTimer(timeInterval: sensingInterval, target: self, selector: #selector(startSensing), userInfo: nil, repeats: true)
        } catch {
            print("Failed to set up recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        timer?.invalidate()
        timer = nil
        sensingTimer?.invalidate()
        sensingTimer = nil
    }

    @objc private func startSensing() {
        resetNoiseLevels()
        
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()

        timer = Timer.scheduledTimer(timeInterval: sensingDuration, target: self, selector: #selector(stopSensing), userInfo: nil, repeats: false)
    }

    @objc private func stopSensing() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil

        // Process the recorded data
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? 0
        updateNoiseLevels(averagePower: averagePower)
        let noiseLevels = getNoiseLevels()
        self.sendNoiseLevel(noiseLevels)
    }

    private func resetNoiseLevels() {
        highestNoiseLevel = -Float.greatestFiniteMagnitude
        lowestNoiseLevel = Float.greatestFiniteMagnitude
        totalNoiseLevel = 0
        noiseCount = 0
    }

    private func updateNoiseLevels(averagePower: Float) {
        highestNoiseLevel = max(highestNoiseLevel, averagePower)
        lowestNoiseLevel = min(lowestNoiseLevel, averagePower)
        totalNoiseLevel += averagePower
        noiseCount += 1
    }

    private func getNoiseLevels() -> (average: Int, highest: Int, lowest: Int) {
        let averageLevel = noiseCount > 0 ? totalNoiseLevel / Float(noiseCount) : -Float.greatestFiniteMagnitude
        return (convertToDecibels(averagePower: averageLevel), convertToDecibels(averagePower: highestNoiseLevel), convertToDecibels(averagePower: lowestNoiseLevel))
    }

    private func convertToDecibels(averagePower: Float) -> Int {
        let minDb: Float = -80.0
        let level = max(0.0, min(1.0, (averagePower - minDb) / -minDb))
        return Int(level * 100)
    }

    private func sendNoiseLevel(_ noiseLevels: (average: Int, highest: Int, lowest: Int)) {
        guard let url = URL(string: "\(Constants.baseURL)/api/environment/noise") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: Any] = ["average_level": noiseLevels.average, "highest_level": noiseLevels.highest, "lowest_level": noiseLevels.lowest]
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

            print("Noise levels sent successfully")
        }

        task.resume()
    }
}
