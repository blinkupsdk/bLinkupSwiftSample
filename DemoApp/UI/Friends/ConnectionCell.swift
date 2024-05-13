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
    let presence: [Place]
    let withMe: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person")
                VStack(alignment: .leading) {
                    Text(user?.name ?? "?")
                        .fontWeight(withMe ? .bold : .regular)
                        .underline(withMe)
                        .foregroundStyle(withMe ? Color.accentColor : .black)
                    
                    Text(user?.phoneNumber ?? "?")
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(withMe ? .accentColor : .gray)
            }
            ForEach(presence, id: \.id) { presence in
                Text(presence.name)
                    .foregroundStyle(.gray)
                    .font(.system(size: 12))
                    .padding(.leading, 27)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ConnectionCell(user: .init(id: "1", name: "Friend"), presence: [], withMe: false)
}
