//
//  MyPresenceCell.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkupSDK
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
    let u1 = User.intInit(id: "1", name: "User1")
    let pl1 = Place(id: "1", name: "Place1", latitude: 0, longitude: 0, radius: 10)
    let pr1 = Presence(id: "1", user: u1, place: pl1, isPresent: true, insertedAt: nil)
    MyPresenceCell(rec: .init(place: pl1, presence: pr1), updater: { _ in })
}
