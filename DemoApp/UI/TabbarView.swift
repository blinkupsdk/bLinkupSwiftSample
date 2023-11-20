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
                    Label("Places", systemImage: "person.3")
                }

                NavigationStack {
//                  FriendListView()
                }
                .tabItem {
                    Label("", systemImage: "location.fill")
                }
//
                NavigationStack {
//                  StadiumView()
                }
                .tabItem {
                    Label("", systemImage: "map.fill")
                }

                NavigationStack {
                    SettingsView(isLoggedIn: $isLoggedIn)
                }
                .tabItem {
                    Label("Profile", systemImage: "gearshape")
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
