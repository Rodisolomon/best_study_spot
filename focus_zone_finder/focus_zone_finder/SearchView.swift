//
//  SearchView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-21.
//

import SwiftUI

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            Spacer(minLength:10)
            Text("Start focusing today!")
                .font(.title)
                .padding()

            NavigationLink("Search for study zone", destination: ResultsView())
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)

            Spacer()
        }
        .navigationTitle("Search for focus zone!")
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
