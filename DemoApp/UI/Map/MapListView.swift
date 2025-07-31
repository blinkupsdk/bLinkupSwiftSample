//
//  MapListView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkupSDK
import SwiftUI

struct MapListView: View {
    @State var places: [Place]?
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            List(places ?? [], id: \.id) { place in
                Text(place.name)
//                NavigationLink(destination: VenueMapView(place: place),
//                               label: { Text(place.name) })
//                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .refreshable(action: {
                loadData()
            })
            
            ActivityIndicator(isAnimating: $isLoading, style: .large)
        }
        .onAppear{
            guard places == nil else { return }
            loadData()
        }
    }
    
    func loadData() {
        isLoading = true
        bLinkup.getEvents(completion: {
            isLoading = false
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let list):
                self.places = list
            }
        })
    }
}

#Preview {
    let pl1 = Place(id: "1", name: "Place1", latitude: 0, longitude: 0, radius: 10)
    let pl2 = Place(id: "2", name: "Place2", latitude: 0, longitude: 0, radius: 10)
    
    NavigationView {
        MapListView(places: [pl1, pl2])
            .navigationTitle("Map")
    }
}
