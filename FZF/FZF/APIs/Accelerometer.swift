//
//  Accelerometer.swift
//  FZF
//
//  Created by Tracy on 2024/5/15.
//

import Foundation

class AccelerometerService {
    func processAccelerometerData(data: [String: Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "http://yourserver.com/api/location/accelerometer") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
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
                   let settled = jsonResponse["settled"] as? Bool {
                    completion(.success(settled))
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
