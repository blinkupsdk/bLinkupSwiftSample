//
//  EventMenu.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.11.2023.
//

import bLinkup
import SwiftUI

struct EventMenu: View {
    let place: Place?
    
    @Binding var isLoading: Bool
    
    //                    "lasso", "map", "person.wave.2")

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                MenuButton("IN",  "square.and.arrow.down", makeMeIn)
                
                MenuButton("OUT",  "square.and.arrow.up", makeMeOut)
            }
            .font(.headline)
            
            Rectangle()
                .fill(.clear)
                .frame(height: 10)
                        
            NavigationLink(destination: {
                PresenceView(place: place)
            }, label: {
                Text("Presence")
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule().fill(.gray))
            })
            
            NavigationLink(destination: {
                VenueMapView(place: place)
            }, label: {
                Text("Venue map")
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule().fill(.gray))
            })
            
            NavigationLink(destination: {
                TrackView()
                    .navigationBarTitleDisplayMode(.inline)
            }, label: {
                Text("Tracking for devs")
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule().fill(.gray))
            })

        }
        .padding(.vertical)
        .foregroundColor(.black)
        .font(.title3)
    }
    
    // MARK: - Helpers
    
    
    // MARK: - Data
    
    func makeMeIn() { updatePresense(true) }
    
    func makeMeOut() { updatePresense(false) }
    
    func updatePresense(_ presence: Bool) {
        guard let place else { return }
        isLoading = true
        bLinkup.setUserAtEvent(presence, at: place, completion: { _ in
            isLoading = false
        })
    }
}

#Preview {
    EventMenu(place: Place(id: "1", name: "Stadium"), isLoading: .constant(false))
}

struct MenuButton: View {
    let title: String
    let imageSystemName: String?
    let action: () -> ()
    
    init(_ title: String, _ imageSystemName: String?, _ action: @escaping () -> Void) {
        self.title = title
        self.imageSystemName = imageSystemName
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: {
            HStack {
                if let imageSystemName {
                    Image(systemName: imageSystemName)
                }
                Text(title)
            }
        })
        .padding()
        .padding(.horizontal)
        .background(Capsule().fill(.gray))
        .frame(width: 130)
    }
}
