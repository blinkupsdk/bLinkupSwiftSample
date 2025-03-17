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
    @State var error: Error? = nil {
        didSet { showError = error != nil }
    }
    @State var showError = false

    let tracker: TrackingObject
    
    init(isLoggedIn: Binding<Bool>) {
        tracker = TrackingObject()
        
        self._isLoggedIn = isLoggedIn
        
        tracker.onLocationUpdate = {
            if let l = $0 {
                LogsManager.shared.addLogLocation(l, nearest: $1)
            }
        }
        tracker.onPresenceUpdate = {
            LogsManager.shared.addLogPresence($0)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            TabView {
                NavigationView {
                    FriendsView()
                        .navigationTitle("Friends")
                }
                .tabItem {
                    Label("Friends", systemImage: "person.3")
                }

                NavigationView {
                    MyPresenceView(error: $error)
                        .navigationTitle("Presence")
                }
                .tabItem {
                    Label("Presence", systemImage: "location.fill")
                }

                NavigationView {
                    MapListView()
                        .navigationTitle("Map")
                }
                .tabItem {
                    Label("Map", systemImage: "map")
                }

                NavigationView {
                    SettingsView(isLoggedIn: $isLoggedIn)
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .alert(error?.localizedDescription ?? "?", isPresented: $showError) {
            Button("OK", role: .cancel) { error = nil }
        }
        .navigationBarTitle("", displayMode: .inline)
    }
}
