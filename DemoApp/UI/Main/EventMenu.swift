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
                    .background(RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.5)))
            })
            
            NavigationLink(destination: {
                VenueMapView(place: place)
            }, label: {
                Text("Venue map")
                    .padding()
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.5)))
            })
            
            NavigationLink(destination: {
                TrackView()
                    .navigationBarTitleDisplayMode(.inline)
            }, label: {
                Text("Tracking for devs")
                    .padding()
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.5)))
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
        .frame(width: 100)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black)
                .shadow(color: .black.opacity(0.5), radius: 7, x: 0, y: 3)
        )

    }
}
