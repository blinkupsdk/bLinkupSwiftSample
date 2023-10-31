//
//  PresenceCell.swift
//  bLinkupSDKTestShellApp
//
//  Created by Oleksandr Chernov on 27.10.2023.
//

import SwiftUI
import bLinkup

struct PresenceCell: View {
    let presence: Presence

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(presence.user.name ?? "?")
                    .font(.title)
                Text(presence.user.phone_number ?? "?")
                    .font(.headline)
                    .foregroundStyle(.gray)
                Text(presence.insertedAt ?? "?")
                    .font(.body)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: presence.isPresent ? "square.and.arrow.down" : "square.and.arrow.up")
        }
    }
}

#Preview {
    PresenceCell(presence: Presence(id: "1", 
                                    user: .init(id: "2", name: "Jim Snow",
                                                phone_number: "+234", email_address: "jim@snow.com"),
                                    place: nil, isPresent: true, insertedAt: "24.02.22"))
    .padding(.horizontal)
}
