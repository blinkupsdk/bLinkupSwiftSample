//
//  EventsView.swift
//  bLinkupSDKTestShellApp
//
//  Created by Oleksandr Chernov on 27.10.2023.
//

import SwiftUI
import bLinkup

struct EventsView: View {
    @State var isLoading = true

    @State var places: [Place] = []

    enum Navigation: Hashable {
        case presence(Place)
        case map(Place)
    }

    var body: some View {
        LoadingView(isShowing: $isLoading) {
            List {
                ForEach(places, id: \.id) { place in
                    EventCell(place: place)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .refreshable {
                try? await loadEvents()
            }
        }
        .onAppear(perform: {
            Task { try? await loadEvents() }
        })
        .transition(.opacity)
        .navigationTitle("Places")
        .navigationDestination(for: Navigation.self, destination: { nav in
            switch nav {
            case .presence(let p):
                PresenceView(place: p)
            case .map(let p):
                VenueMapView(place: p)
            }
        })
    }
    
    func loadEvents() async throws {
        Task {
            self.isLoading = true
            self.places = try await bLinkup.getEvents()
            self.isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        EventsView(isLoading: false, places: [Place(id: "1", name: "Stadium")])
    }
}
