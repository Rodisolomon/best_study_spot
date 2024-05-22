//
//  ResultsView.swift
//  FZF
//
//  Created by Tracy on 2024/5/21.
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

//            NavigationLink(destination: MainTabView()) {
//                Text("Continue")
//                    .foregroundColor(.white)
//                    .frame(width: 280, height: 50)
//                    .background(Color.teal)
//                    .cornerRadius(10)
//            }
//            .padding(.bottom, 20)
        }
        .navigationBarTitle("Focus Zones Found!", displayMode: .inline)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}

