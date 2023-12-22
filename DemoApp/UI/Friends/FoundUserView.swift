//
//  FoundUserView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 22.12.2023.
//

import bLinkup
import SwiftUI

struct FoundUserView: View {
    let user: User
    var icon = "person.badge.plus"
    var highlightIcon = false
    
    var body: some View {
        HStack {
            Text(user.name ?? "?")
            Spacer()
            Image(systemName: icon)
                .foregroundColor(highlightIcon ? .blue : .gray)
                .frame(width: 50)
        }
    }
}

#Preview {
    FoundUserView(user: .init(id: "a", name: "Will"))
}
