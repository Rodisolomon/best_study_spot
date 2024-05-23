//
//import Foundation
//import AVFoundation
//
//class NoiseService: NSObject, ObservableObject {
//    @Published var isSensing = false
//
//    private var audioRecorder: AVAudioRecorder?
//    private var sensingTimer: Timer?
//    var accelerometerService = AccelerometerService()
//    
//    private var highestNoiseLevel: Float = -Float.greatestFiniteMagnitude
//    private var lowestNoiseLevel: Float = Float.greatestFiniteMagnitude
//    private var totalNoiseLevel: Float = 0
//    private var noiseCount: Int = 0
//
//    var sensingInterval: TimeInterval = 5  // interval between each sensing in seconds
//    var sensingDuration: TimeInterval = 3  // duration of each sensing period in seconds
//
//    override init() {
//        super.init()
//        accelerometerService.motionDetected = { [weak self] isMoving in
//            guard let self = self else { return }
//            if isMoving {
//                self.stopSensing()
//                self.stopSensingCycle()
//                print("Movement detected, stopping noise sensing.")
//            }
//        }
//    }
//
//    func startSensingCycle() {
//        isSensing = true
//        sensingTimer = Timer.scheduledTimer(timeInterval: sensingInterval, target: self, selector: #selector(startSensing), userInfo: nil, repeats: true)
//        startSensing()
//    }
//
//    func stopSensingCycle() {
//        isSensing = false
//        sensingTimer?.invalidate()
//        sensingTimer = nil
//        stopSensing()
//        
//        // Send accumulated data to the backend
//        let noiseLevels = self.getNoiseLevels()
//        sendNoiseLevel(noiseLevels)
//    }
//
//    @objc private func startSensing() {
//        if !isSensing {
//            return
//        }
//
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
//            self.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
//            self.audioRecorder?.isMeteringEnabled = true
//
//            self.audioRecorder?.prepareToRecord()
//            self.audioRecorder?.record()
//            print("Started sensing noise.")
//
//            Timer.scheduledTimer(timeInterval: sensingDuration, target: self, selector: #selector(stopSensing), userInfo: nil, repeats: false)
//        } catch {
//            print("Failed to set up sensing: \(error)")
//        }
//    }
//
//    @objc private func stopSensing() {
//        if !isSensing {
//            return
//        }
//
//        self.audioRecorder?.updateMeters() // Ensure meters are updated before reading values
//        let averagePower = self.audioRecorder?.averagePower(forChannel: 0) ?? -160.0 // Use a default value if nil
//        self.updateNoiseLevels(averagePower: averagePower)
//        
//        self.audioRecorder?.stop()
//        self.audioRecorder = nil
//        print("Stopped sensing noise.")
//        print("Raw sensing data: \(averagePower) dB")
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
//        // Assuming -160 dB is the minimum and 0 dB is the maximum
//        let minDb: Float = -160.0
//        let maxDb: Float = 0.0
//        let normalizedValue = max(0.0, min(1.0, (averagePower - minDb) / (maxDb - minDb)))
//        return Int(normalizedValue * 100)
//    }
//
//    private func sendNoiseLevel(_ noiseLevels: (average: Int, highest: Int, lowest: Int)) {
//        guard let url = URL(string: "\(Constants.baseURL)/api/environment/noise") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let json: [String: Any] = ["average_level": noiseLevels.average, "highest_level": noiseLevels.highest, "lowest_level": noiseLevels.lowest]
//        let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//        request.httpBody = jsonData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error sending noise level: \(error)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Invalid response")
//                return
//            }
//
//            print("Noise levels sent successfully")
//        }
//
//        task.resume()
//    }
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

    private var noiseData: [[String: Float]] = []

    var sensingInterval: TimeInterval = 0  // Interval between each sensing in seconds
    var sensingDuration: TimeInterval = 5  // Duration of each sensing period in seconds

    override init() {
        super.init()
        accelerometerService.motionDetected = { [weak self] isStable in
            guard let self = self else { return }
            isStable ? self.startSensingCycle() : self.stopSensingCycle()
        }
    }

    func startSensingCycle() {
        guard !isSensing else { return }
        isSensing = true
        sensingTimer = Timer.scheduledTimer(timeInterval: sensingInterval, target: self, selector: #selector(startSensing), userInfo: nil, repeats: true)
        startSensing()
    }

    func stopSensingCycle() {
        guard isSensing else { return }
        isSensing = false
        sensingTimer?.invalidate()
        sensingTimer = nil
        stopSensing()
    }

    func manualStopSensingCycle() {
        stopSensingCycle()
        sendNoiseData()
    }

    @objc private func startSensing() {
        guard isSensing else { return }
        
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

            Timer.scheduledTimer(timeInterval: sensingDuration, target: self, selector: #selector(stopSensing), userInfo: nil, repeats: false)
        } catch {
            print("Failed to set up sensing: \(error)")
        }
    }

    @objc private func stopSensing() {
        guard isSensing else { return }

        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160.0
        updateNoiseLevels(averagePower: averagePower)
        
        let noiseLevels = getNoiseLevels()
        noiseData.append(["average_level": noiseLevels.average, "highest_level": noiseLevels.highest, "lowest_level": noiseLevels.lowest])

        resetNoiseLevels()
        audioRecorder?.stop()
        audioRecorder = nil
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

    private func getNoiseLevels() -> (average: Float, highest: Float, lowest: Float) {
        let averageLevel = noiseCount > 0 ? totalNoiseLevel / Float(noiseCount) : -Float.greatestFiniteMagnitude
        return (averageLevel, highestNoiseLevel, lowestNoiseLevel)
    }

    private func sendNoiseData() {
        guard let url = URL(string: "\(Constants.baseURL)/api/environment/noise") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let json: [String: Any] = ["noise_data": noiseData]
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
        }

        task.resume()
        noiseData.removeAll()
    }
}
