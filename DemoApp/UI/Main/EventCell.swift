//
//  EventCell.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 30.10.2023.
//

import bLinkup
import SwiftUI

extension View {
  func navigationLink<Destination: View>(_ destination: @escaping () -> Destination) -> some View {
    modifier(NavigationLinkModifier(destination: destination))
  }
}

fileprivate struct NavigationLinkModifier<Destination: View>: ViewModifier {

  @ViewBuilder var destination: () -> Destination

  func body(content: Content) -> some View {
    content
      .background(
        NavigationLink(destination: self.destination) { EmptyView() }.opacity(0)
      )
  }
}

struct EventCell: View {
    let place: Place
    
    @State private var isLoading = false
    @State private var viewState: Int? = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Text(place.name)
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 0) {
                
                Image(systemName: "square.and.arrow.down")
                    .padding()
                    .onTapGesture(perform: enter)
                
                Image(systemName: "square.and.arrow.up")
                    .padding()
                    .onTapGesture(perform: leave)
                
                Spacer()
                
                ActivityIndicator(isAnimating: $isLoading, style: .large)
                
                Spacer()

                NavigationLink(
                    destination: TrackView(),
                    tag: 1,
                    selection: $viewState,
                    label: { EmptyView() }
                )
                .frame(width: 0)
                .hidden()
                
                NavigationLink(
                    destination: VenueMapView(place: place),
                    tag: 2,
                    selection: $viewState,
                    label: { EmptyView() }
                )
                .frame(width: 0)
                .hidden()
                
                NavigationLink(
                    destination: PresenceView(place: place),
                    tag: 3,
                    selection: $viewState,
                    label: { EmptyView() }
                )
                .frame(width: 0)
                .hidden()
                
                Image(systemName: "lasso")
                    .padding()
                    .onTapGesture {
                        viewState = 1
                    }
                
                Image(systemName: "map")
                    .padding()
                    .onTapGesture {
                        viewState = 2
                    }
                
                Image(systemName: "person.wave.2")
                    .padding()
                    .onTapGesture {
                        viewState = 3
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func enter() { updatePresense(true) }
    
    func leave() { updatePresense(false) }
    
    func updatePresense(_ p: Bool) {
        isLoading = true
        bLinkup.setUserAtEvent(p, at: place, completion: { _ in
            isLoading = false
        })
    }
}

#Preview {
    EventCell(place: Place(id: "1", name: "Stadium"))
        .padding(.horizontal)
}
