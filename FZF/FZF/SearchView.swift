//
//  SearchView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-21.
//
import SwiftUI

struct SearchView: View {
    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        VStack {
            Spacer(minLength: 10)
            Text("Start focusing today!")
                .font(.title)
                .padding()

            NavigationLink(destination: ResultsView(selectedTab: $selectedTab)) {
                Text("Search for study zone")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.teal)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .navigationTitle("Search for focus zone!")
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(selectedTab: .constant(.search))
            .environmentObject(LocationManager())
    }
}
