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
                    FriendsView()
                        .navigationTitle("Friends")
                }
                .tabItem {
                    Label("Friends", systemImage: "person.3")
                }

                NavigationStack {
                    MyPresenceView()
                        .navigationTitle("Presence")
                }
                .tabItem {
                    Label("Presence", systemImage: "location.fill")
                }

                NavigationStack {
                    MapListView()
                        .navigationTitle("Map")
                }
                .tabItem {
                    Label("Map", systemImage: "map")
                }

                NavigationStack {
                    SettingsView(isLoggedIn: $isLoggedIn)
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
