//
//  ConnectionCell.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 24.11.2023.
//

import bLinkup
import SwiftUI

struct ConnectionCell: View {
    let user: User?
    let isPresent: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "person")
            VStack(alignment: .leading) {
                Text(user?.name ?? "?")
                    .bold(isPresent)
                    .underline(isPresent)
                    .foregroundStyle(isPresent ? Color.accentColor : .black)
                
                Text(user?.phone_number ?? "?")
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(isPresent ? .accentColor : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ConnectionCell(user: .init(id: "1", name: "Friend"), isPresent: false)
}
