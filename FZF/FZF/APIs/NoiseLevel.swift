////
////  NoiseLevel.swift
////  FZF
////
////  Created by Tracy on 2024/5/15.
////
//import Foundation
//import AVFoundation
//
//class NoiseService: NSObject, ObservableObject {
//    @Published var isRecording = false  // Published property to track recording state
//
//    private var audioRecorder: AVAudioRecorder?
//    private var timer: Timer?
//    private var sensingTimer: Timer? // Timer for the delay before restarting recording
//    private var accelerometerService = AccelerometerService()
//    
//    private var highestNoiseLevel: Float = -Float.greatestFiniteMagnitude
//    private var lowestNoiseLevel: Float = Float.greatestFiniteMagnitude
//    private var totalNoiseLevel: Float = 0
//    private var noiseCount: Int = 0
//
//    var sensingInterval: TimeInterval = 3  // Interval between each sensing in seconds
//    var sensingDuration: TimeInterval = 2  // Duration of each sensing in seconds
//
//    override init() {
//        super.init()
//        accelerometerService.motionDetected = { [weak self] isMoving in
//            guard let self = self else { return }
//            if isMoving {
//                if self.isRecording {
//                    self.stopRecording()
//                    print("Movement detected, stopping noise sensing.")
//                }
//                self.sensingTimer?.invalidate() // Cancel any pending restart
//            } else {
//                self.sensingTimer?.invalidate() // Cancel any pending restart
//                self.sensingTimer = Timer.scheduledTimer(withTimeInterval: self.sensingInterval, repeats: false) { _ in
//                    if !self.isRecording {
//                        self.startRecording()
//                        print("Phone is stationary, restarting noise sensing.")
//                    }
//                }
//            }
//        }
//        accelerometerService.startAccelerometerUpdates()
//    }
//
//    func startRecording() {
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default)
//            try audioSession.setActive(true)
//
//            let settings: [String: Any] = [
//                AVFormatIDKey: Int(kAudioFormatAppleLossless),
//                AVSampleRateKey: 44100.0,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ]
//
//            let url = URL(fileURLWithPath: "/dev/null")
//
//            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            audioRecorder?.isMeteringEnabled = true
//
//            startSensing()
//            sensingTimer = Timer.scheduledTimer(timeInterval: sensingInterval, target: self, selector: #selector(startSensing), userInfo: nil, repeats: true)
//            
//            accelerometerService.startAccelerometerUpdates()
//            isRecording = true // Update state to true when recording starts
//        } catch {
//            print("Failed to set up recording: \(error)")
//        }
//    }
//
//    func stopRecording() {
//        audioRecorder?.stop()
//        audioRecorder = nil
//        timer?.invalidate()
//        timer = nil
//        sensingTimer?.invalidate()
//        sensingTimer = nil
//        accelerometerService.stopAccelerometerUpdates()
//        isRecording = false // Update state to false when recording stops
//    }
//
//    @objc private func startSensing() {
//        resetNoiseLevels()
//        audioRecorder?.prepareToRecord()
//        audioRecorder?.record()
//        timer = Timer.scheduledTimer(timeInterval: sensingDuration, target: self, selector: #selector(stopSensing), userInfo: nil, repeats: false)
//    }
//
//    @objc private func stopSensing() {
//        audioRecorder?.stop()
//        timer?.invalidate()
//        timer = nil
//
//        audioRecorder?.updateMeters()
//        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? 0
//        updateNoiseLevels(averagePower: averagePower)
//        let noiseLevels = getNoiseLevels()
////        sendNoiseLevel(noiseLevels)
//    }
//
//    private func resetNoiseLevels() {
//        highestNoiseLevel = -Float.greatestFiniteMagnitude
//        lowestNoiseLevel = Float.greatestFiniteMagnitude
//        totalNoiseLevel = 0
//        noiseCount = 0
//    }
//
//    private func updateNoiseLevels(averagePower: Float) {
//        highestNoiseLevel = max(highestNoiseLevel, averagePower)
//        lowestNoiseLevel = min(lowestNoiseLevel, averagePower)
//        totalNoiseLevel += averagePower
//        noiseCount += 1
//    }
//
//    private func getNoiseLevels() -> (average: Int, highest: Int, lowest: Int) {
//        let averageLevel = noiseCount > 0 ? totalNoiseLevel / Float(noiseCount) : -Float.greatestFiniteMagnitude
//        return (convertToDecibels(averagePower: averageLevel), convertToDecibels(averagePower: highestNoiseLevel), convertToDecibels(averagePower: lowestNoiseLevel))
//    }
//
//    private func convertToDecibels(averagePower: Float) -> Int {
//        let minDb: Float = -80.0
//        let level = max(0.0, min(1.0, (averagePower - minDb) / -minDb))
//        return Int(level * 100)
//    }
////
////    private func sendNoiseLevel(_ noiseLevels: (average: Int, highest: Int, lowest: Int)) {
////        guard let url = URL(string: "\(Constants.baseURL)/api/environment/noise") else { return }
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////
////        let json: [String: Any] = ["average_level": noiseLevels.average, "highest_level": noiseLevels.highest, "lowest_level": noiseLevels.lowest]
////        let jsonData = try? JSONSerialization.data(withJSONObject: json)
////
////        request.httpBody = jsonData
////        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////
////        let task = URLSession.shared.dataTask(with: request) { data, response, error in
////            if let error = error {
////                print("Error sending noise level: \(error)")
////                return
////            }
////
////            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
////                print("Invalid response")
////                return
////            }
////
////            print("Noise levels sent successfully")
////        }
////
////        task.resume()
////    }
//}
import Foundation
import AVFoundation

class NoiseService: NSObject, ObservableObject {
    @Published var isSensing = false

    private var audioRecorder: AVAudioRecorder?
    private var sensingTimer: Timer?
    var accelerometerService = AccelerometerService()
    
    private var highestNoiseLevel: Float = -Float.greatestFiniteMagnitude
    private var lowestNoiseLevel: Float = Float.greatestFiniteMagnitude
    private var totalNoiseLevel: Float = 0
    private var noiseCount: Int = 0

    var sensingInterval: TimeInterval = 5  // Interval between each sensing in seconds
    var sensingDuration: TimeInterval = 3  // Duration of each sensing period in seconds

    override init() {
        super.init()
        accelerometerService.motionDetected = { [weak self] isMoving in
            guard let self = self else { return }
            if isMoving {
                self.stopSensing()
                self.stopSensingCycle()
                print("Movement detected, stopping noise sensing.")
            }
        }
    }

    func startSensingCycle() {
        isSensing = true
        sensingTimer = Timer.scheduledTimer(timeInterval: sensingInterval, target: self, selector: #selector(startSensing), userInfo: nil, repeats: true)
        startSensing()
    }

    func stopSensingCycle() {
        isSensing = false
        sensingTimer?.invalidate()
        sensingTimer = nil
        stopSensing()
    }

    @objc private func startSensing() {
        if !isSensing {
            return
        }

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

            self.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            self.audioRecorder?.isMeteringEnabled = true

            self.resetNoiseLevels()
            self.audioRecorder?.prepareToRecord()
            self.audioRecorder?.record()
            print("Started sensing noise.")

            Timer.scheduledTimer(timeInterval: sensingDuration, target: self, selector: #selector(stopSensing), userInfo: nil, repeats: false)
        } catch {
            print("Failed to set up sensing: \(error)")
        }
    }

    @objc private func stopSensing() {
        if !isSensing {
            return
        }

        self.audioRecorder?.updateMeters() // Ensure meters are updated before reading values
        let averagePower = self.audioRecorder?.averagePower(forChannel: 0) ?? -160.0 // Use a default value if nil
        self.updateNoiseLevels(averagePower: averagePower)
        
        self.audioRecorder?.stop()
        self.audioRecorder = nil
        print("Stopped sensing noise.")
        print("Raw sensing data: \(averagePower) dB")

        let noiseLevels = self.getNoiseLevels()
        print("Noise Levels - Average: \(noiseLevels.average), Highest: \(noiseLevels.highest), Lowest: \(noiseLevels.lowest)")
        sendNoiseLevel(noiseLevels)
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
        // Assuming -160 dB is the minimum and 0 dB is the maximum
        let minDb: Float = -160.0
        let maxDb: Float = 0.0
        let normalizedValue = max(0.0, min(1.0, (averagePower - minDb) / (maxDb - minDb)))
        return Int(normalizedValue * 100)
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
