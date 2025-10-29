//
//  CustomerView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 28/10/25.
//

import bLinkupSDK
import SwiftUI

struct CustomerView: View {
    enum Action { case edit, delete, copyToken, favorite }
    
    let customer: AppCustomer
    var actions: Set<Action> = [.edit , .delete, .copyToken, .favorite]
    var onEdit: ((Action) -> ())?
    
    var body: some View {
        HStack {
            Text(customer.name ?? customer.id)
//                .fontWeight(customer.cid == bLinkup.customer?.id ? .bold : .regular)

            if let g = customer.group?.nonEmpty {
                Text("/\(g)")
            }
            if (customer.isFavorite == true) {
                Text("*")
            }
            Spacer()
            HStack {
                if let onEdit, !actions.isEmpty {
                    Menu(content: {
                        if actions.contains(.copyToken) {
                            Button("copy token", action: { onEdit(.copyToken) })
                        }
                        if actions.contains(.edit) {
                            Button("edit", action: { onEdit(.edit) })
                        }
                        if actions.contains(.favorite) {
                            let text = customer.isFavorite == true
                            ? "remove from favorites"
                            : "add to favorites"
                            Button(text, action: { onEdit(.favorite) })
                        }
                        if actions.contains(.delete) {
                            Button("delete", action: { onEdit(.delete) })
                        }
                    }, label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                    })
                }
            }
        }
    }
}
