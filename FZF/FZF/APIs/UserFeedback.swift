//
//  UserFeedback.swift
//  FZF
//
//  Created by Tracy on 2024/5/15.
//

import Foundation

class FeedbackService {
    func submitFeedback(rating: Int, comments: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "http://yourserver.com/api/user/feedback") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let json: [String: Any] = ["rating": rating, "comments": comments]
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
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
            }
        }
        
        task.resume()
    }
}
