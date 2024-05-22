////
////  TabView.swift
////  FZF
////
////  Created by Tracy on 2024/5/21.
////
//
//import SwiftUI
//
//struct MainTabView: View {
//    var body: some View {
//        TabView {
//            NavigationView {
//                StudyView()
//            }
//            .tabItem {
//                Image(systemName: "book.fill")
//                Text("Study")
//            }
//            
//            NavigationView {
//                SearchView()
//            }
//            .tabItem {
//                Image(systemName: "magnifyingglass")
//                Text("Search")
//            }
//            
//            NavigationView {
//                PreferencesView()
//            }
//            .tabItem {
//                Image(systemName: "gearshape.fill")
//                Text("Preferences")
//            }
//        }
//    }
//}
//
//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .search

    enum Tab {
        case search
        case study
        case preferences
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                StudyView()
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Study")
            }
            .tag(Tab.study)

            NavigationView {
                SearchView(selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .tag(Tab.search)

            NavigationView {
                PreferencesView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Preferences")
            }
            .tag(Tab.preferences)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(LocationManager()) // Ensure LocationManager is available in the environment
    }
}
