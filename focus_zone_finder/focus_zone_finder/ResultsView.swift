//
//  ResultsView.swift
//  focus_zone_finder
//
//  Created by 天豪刘 on 2024-05-21.
//

import SwiftUI

struct ResultsView: View {
    var body: some View {
        VStack {
            Text("Focus Zones Found!")
                .font(.title2)
                .padding()

            List {
                Text("Poetry Foundation Library - 95% Match")
                Text("Blue Bottle River North - 91% Match")
                Text("Starbucks Reserve - 87% Match")
                // More results can be added here
            }

            Spacer() // Adds space between the list and the button

            NavigationLink(destination: ContentView()) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(width: 280, height: 50)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20) // Adds padding at the bottom of the button
        }
        .navigationBarTitle("Focus Zones Found!", displayMode: .inline)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}

