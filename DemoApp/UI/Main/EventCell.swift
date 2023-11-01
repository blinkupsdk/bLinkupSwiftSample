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
        Text(place.name)
            .lineLimit(3)
            .padding()
            .frame(width: 200, height: 70)
    }
}

#Preview {
    EventCell(place: Place(id: "1", name: "Stadium"))
        .padding(.horizontal)
}
