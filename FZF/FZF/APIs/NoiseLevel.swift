//
//  NoiseLevel.swift
//  FZF
//
//  Created by Tracy on 2024/5/15.
//

import Foundation

class NoiseService {
    func processNoiseData(noiseLevel: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "http://yourserver.com/api/environment/noise") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let json: [String: Any] = ["level": noiseLevel]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let level = jsonResponse["noise_level"] as? Int {
                    completion(.success(level))
                } else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch let parsingError {
                completion(.failure(parsingError))
            }
        }
        
        task.resume()
    }
}
