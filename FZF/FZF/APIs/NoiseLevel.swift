
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

    var sensingInterval: TimeInterval = 2 // interval between each sensing in seconds
    var sensingDuration: TimeInterval = 5  // duration of each sensing period in seconds

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
        print(["average_level": noiseLevels.average, "highest_level": noiseLevels.highest, "lowest_level": noiseLevels.lowest])
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
