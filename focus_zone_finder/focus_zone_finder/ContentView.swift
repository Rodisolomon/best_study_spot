//
//  ContentView.swift
//  focus_zone_finder
//
//  Created by Tracy on 2024/5/21.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                StudyView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Study")
            }
            
            NavigationView {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            
            NavigationView {
                PreferencesView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Preferences")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
