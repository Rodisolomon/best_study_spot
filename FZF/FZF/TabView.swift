//
//  TabView.swift
//  FZF
//
//  Created by Tracy on 2024/5/21.
//

import SwiftUI

struct MainTabView: View {
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

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

