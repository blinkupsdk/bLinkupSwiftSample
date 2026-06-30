//
//  CustomerView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 28/10/25.
//

import bLinkupSDK
import SwiftUI

struct CustomerView: View {
    enum Action: CaseIterable { case open, edit, delete, copyToken, favorite }
    
    let customer: AppCustomer
    let isFavorite: Bool
    var actions: Set<Action> = Set(Action.allCases)
    var onEdit: ((Action) -> ())?
    
    var body: some View {
        Button(action: {
            if actions.contains(.open) {
                onEdit?(.open)
            }
        }, label: {
            HStack {
                Text(customer.name ?? customer.id)
                    .fontWeight(customer.cid == bLinkup.customer?.id ? .bold : .regular)
                
                if isFavorite {
                    Text("*")
                }
                Spacer()
                HStack {
                    if let onEdit, !actions.isEmpty {
                        Menu(content: {
                            if actions.contains(.open) {
                                Button("open", action: { onEdit(.open) })
                            }
                            if actions.contains(.copyToken) {
                                Button("copy token", action: { onEdit(.copyToken) })
                            }
                            if actions.contains(.edit) {
                                Button("edit", action: { onEdit(.edit) })
                            }
                            if actions.contains(.favorite) {
                                let text = isFavorite == true
                                ? "remove from favorites"
                                : "add to favorites"
                                Button(text, action: { onEdit(.favorite) })
                            }
                            if actions.contains(.delete) {
                                Button("delete", action: { onEdit(.delete) })
                            }
                            #if DEBUG
                            Divider()
                            Button("copy token", action: { onEdit(.copyToken) })
                            #endif
                        }, label: {
                            Image(systemName: "ellipsis")
                                .frame(width: 30, height: 30)
                        })
                    }
                }
            }
        })
    }
}
