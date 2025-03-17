//
//  MyPresenceCell.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkup
import SwiftUI

struct MyPresenceCell: View {
    typealias ARecord = MyPresenceView.ARecord
    let rec: ARecord
    let updater: (ARecord) -> Void
    
    var body: some View {
        HStack {
            let isPresent = rec.presence?.isPresent ?? false
            if isPresent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "circle")
            }
            
            Text(rec.place.name)
                .foregroundStyle(isPresent ? Color.accentColor : .black)
            
            Spacer()
            
            Button(action: {
                updater(rec)
            }, label: {
                HStack {
                    Text(isPresent ? "Out" : "In")
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: 130)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius:5))
            })
        }
    }
}

#Preview {
    MyPresenceCell(rec: .init(place: .init(id: "1", name: "Place1"),
                              presence: .init(id: "1",
                                              user: .init(id: "1", name: "User"),
                                              place: .init(id: "1", name: "Place1"),
                                              isPresent: true, insertedAt: nil)),
                   updater: { _ in })
}
