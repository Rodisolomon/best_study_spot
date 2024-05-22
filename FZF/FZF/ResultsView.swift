//
//  ResultsView.swift
//  FZF
//
//  Created by Tracy on 2024/5/21.
//

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
}

// Model to represent the API response
struct RankingsResponse: Codable {
    var status: String
    var ranking: [RankingResult]
}

// Network manager to fetch data from the backend
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

    deinit {
        cancellable?.cancel()
    }
}

// ResultsView to display the fetched data
struct ResultsView: View {
    @StateObject private var networkManager = NetworkManager()

    var body: some View {
        VStack {
            Text("Focus Zones Found!")
                .font(.title2)
                .padding()

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
            }

            Spacer() // Adds space between the list and the label

            if networkManager.rankings.isEmpty {
                Text("Fetching data...")
                    .padding()
            }
        }
        .onAppear {
            networkManager.fetchRankings()
        }
        .navigationBarTitle("Focus Zones Found!", displayMode: .inline)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
