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
    @State var isLoadingFromMenu = false

    @State var places: [Place]?
    @State var place: Place?
    
    enum Navigation: Hashable {
        case presence(Place)
        case map(Place)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(places ?? [], id: \.id) { place in
                            EventCell(place: place)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(place == self.place ? .green : .clear, lineWidth: 2)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill( place == self.place ? .green : .blue)
                                                .opacity(0.3)
                                        }
                                })
                                .padding(.all, 2)
                                .onTapGesture {
                                    self.place = place
                                }
                        }
                    }
                    .refreshable {
                        try? await loadEvents()
                    }
                }
                .frame(height: 70)
                
                EventMenu(place: place, isLoading: $isLoadingFromMenu)
                    .frame(width: 250)
                    .opacity(isLoading ? 0 : (place == nil ? 0.5 : 1))
                    .disabled(place == nil)

                Spacer()
            }
            .padding()
                        
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
            
            LoadingView(isShowing: $isLoadingFromMenu) { Rectangle().fill(.clear) }
        }
        .onAppear(perform: {
            guard places == nil else { return }
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
            self.place = self.places?.first
            self.isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        EventsView(isLoading: false, places: [Place(id: "1", name: "Fiserv Forum"),
                                              Place(id: "2", name: "American Family field field")])
    }
}
