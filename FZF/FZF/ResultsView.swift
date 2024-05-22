////
////  ResultsView.swift
////  FZF
////
////  Created by Tracy on 2024/5/21.
////
//
//import SwiftUI
//import Combine
//
//// Model to represent each ranking result
//struct RankingResult: Codable, Identifiable {
//    var id: UUID = UUID()
//    var name: String
//    var address: String
//    var fitness: String
//    
//    enum CodingKeys: String, CodingKey {
//        case name, address, fitness
//    }
//}
//
//// Model to represent the API response
//struct RankingsResponse: Codable {
//    var status: String
//    var ranking: [RankingResult]
//}
//
//// Network manager to fetch data from the backend
//class NetworkManager: ObservableObject {
//    @Published var rankings: [RankingResult] = []
//
//    private var cancellable: AnyCancellable?
//
//    func fetchRankings() {
//        guard let url = URL(string: "\(Constants.baseURL)/api/ranking") else { return }
//
//        cancellable = URLSession.shared.dataTaskPublisher(for: url)
//            .map { $0.data }
//            .decode(type: RankingsResponse.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error fetching rankings: \(error)")
//                }
//            }, receiveValue: { [weak self] response in
//                self?.rankings = response.ranking
//            })
//    }
//
//    deinit {
//        cancellable?.cancel()
//    }
//}
//
//// ResultsView to display the fetched data
//struct ResultsView: View {
//    @StateObject private var networkManager = NetworkManager()
//
//    var body: some View {
//        VStack {
//            Text("Focus Zones Found!")
//                .font(.title2)
//                .padding()
//
//            List(networkManager.rankings) { ranking in
//                VStack(alignment: .leading) {
//                    Text(ranking.name)
//                        .font(.headline)
//                    Text(ranking.address)
//                        .font(.subheadline)
//                    Text("Fitness Score: \(ranking.fitness)%")
//                        .font(.body)
//                }
//                .padding(.vertical, 5)
//            }
//
//            Spacer() // Adds space between the list and the label
//
//            if networkManager.rankings.isEmpty {
//                Text("Fetching data...")
//                    .padding()
//            }
//        }
//        .onAppear {
//            networkManager.fetchRankings()
//        }
//        .navigationBarTitle("Focus Zones Found!", displayMode: .inline)
//    }
//}
//
//struct ResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultsView()
//    }
//}
import SwiftUI
import Combine

// Model to represent each ranking result
struct RankingResult: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var address: String
    var fitness: String
    
    enum CodingKeys: String, CodingKey {
        case name, address, fitness
    }
    
    init(id: UUID = UUID(), name: String, address: String, fitness: String) {
        self.id = id
        self.name = name
        self.address = address
        self.fitness = fitness
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try container.decode(String.self, forKey: .address)
        self.fitness = try container.decode(String.self, forKey: .fitness)
    }
}

// Model to represent the API response
struct RankingsResponse: Codable {
    var status: String
    var ranking: [RankingResult]
}

// Network manager to fetch data from the backend and send selected address
class NetworkManager: ObservableObject {
    @Published var rankings: [RankingResult] = []

    private var cancellable: AnyCancellable?

    func fetchRankings() {
        guard let url = URL(string: "\(Constants.baseURL)/api/ranking") else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: RankingsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching rankings: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.rankings = response.ranking
            })
    }

    func sendSelectedAddress(_ address: String) {
        guard let url = URL(string: "\(Constants.baseURL)/api/choosen-address") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["address": address]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending address: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }

            print("Address sent successfully")
        }.resume()
    }
}

// ResultsView to display the fetched data and handle item selection
struct ResultsView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var selectedRanking: RankingResult?

    var body: some View {
        VStack {
            Text("Focus Zones Found!")
                .font(.title2)
                .padding()

            if networkManager.rankings.isEmpty {
                Text("Fetching data...")
                    .padding()
            } else {
                List(networkManager.rankings) { ranking in
                    VStack(alignment: .leading) {
                        Text(ranking.name)
                            .font(.headline)
                        Text(ranking.address)
                            .font(.subheadline)
                        Text("Fitness Score: \(ranking.fitness)%")
                            .font(.body)
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        selectedRanking = ranking
                        networkManager.sendSelectedAddress(ranking.address)
                    }
                }
            }

            Spacer() // Adds space between the list and the bottom
        }
        .onAppear {
            networkManager.fetchRankings()
        }
        .navigationBarTitle("Focus Zones Found!", displayMode: .inline)
        .alert(item: $selectedRanking) { ranking in
            Alert(title: Text("Location Selected"),
                  message: Text("You have selected \(ranking.name)"),
                  dismissButton: .default(Text("OK")))
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
