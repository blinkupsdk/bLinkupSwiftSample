//
//  TabbarView.swift
//  bLinkup
//
//  Created on 11.10.2023.
//

import SwiftUI

struct TabbarView: View {
    @Binding var isLoggedIn: Bool
    
    @State var showPortfolio: Bool = false
    @State private var showSettingsView = false
    
    var body: some View {
        VStack {
            Spacer()
            
            TabView {
                NavigationStack {
                    EventsView()
                }
                .tabItem {
                    Label("Places", systemImage: "photo.stack")
                }

                NavigationStack {
                    MyPresenceView()
                        .navigationTitle("Presence")
                }
                .tabItem {
                    Label("My Presence", systemImage: "person.3")
                }

                NavigationStack {
                    MapListView()
                        .navigationTitle("Map")
                }
                .tabItem {
                    Label("Map", systemImage: "map")
                }
//
//                NavigationStack {
//                    SearchView()
//                        .tabItem {
//                            Label("", systemImage: "person.badge.plus")
//                        }
//                }
//                
                NavigationStack {
                    ProfileView(isLoggedIn: $isLoggedIn)
                }
                .tabItem {
                    Label("Profile", systemImage: "gearshape")
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
