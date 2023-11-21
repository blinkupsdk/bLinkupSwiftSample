//
//  MyPresenceCell.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkup
import SwiftUI

struct MyPresenceCell: View {
    let presence: Presence
    let isSelected: Bool
    
    init(presence: Presence, isSelected: Bool) {
        self.presence = presence
        self.isSelected = isSelected
    }
    
    var body: some View {
        HStack {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "circle")
            }
            
            Text(presence.place?.name ?? "?")
                .bold(presence.isPresent)
                .underline(presence.isPresent)
                .foregroundStyle(presence.isPresent ? Color.accentColor : .black)
            
            Spacer()
            
            if presence.isPresent {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    MyPresenceCell(presence: .init(id: "1",
                                   user: .init(id: "1", name: "User"),
                                   place: .init(id: "1", name: "Place1"),
                                   isPresent: true, insertedAt: nil),
                   isSelected: false)
}
