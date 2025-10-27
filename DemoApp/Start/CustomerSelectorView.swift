//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import bLinkupSDK
import SwiftUI

struct CustomerSelectorView: View {
    @Binding var appType: Int
    var onSelection: ((AppCustomer) -> ())?

    @State var customers: [AppCustomer] = DB.shared.get(key: .keyCustomCustomers) ?? []
    @State private var showAddCustomer = false
    @State private var customerToEdit: AppCustomer?
    @AppStorage("Favorite") private var onlyFavorite: Bool = false
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
    //            Picker("Choose", selection: $appType) {
    //                Text("Demo").tag(0)
    //                Text("SDK-UI").tag(1)
    //            }
    //            .pickerStyle(.segmented)
        Spacer()

            Button(action: {
                onlyFavorite.toggle()
            }, label: {
                Image(systemName: onlyFavorite ? "heart.fill" : "heart")
            })
            
            Button(action: { showAddCustomer = true },
                   label: { Image(systemName: "plus") })
        }
        .padding()
        
        Form {
            let list = customers.filterFavorite(onlyFavorite)
            if !list.isEmpty {
                Section(header: Text("Private")) {
                    ForEach(list, id: \.id) { customer in
                        Button(action: {
                            onSelection?(customer)
                        }, label: {
                            CustomerView(customer: customer) { action in
                                switch action {
                                case .edit:
                                    customerToEdit = customer
                                case .delete:
                                    customers = DB.shared.removeCustomer(customer)
                                    loadData()
                                case .copyToken:
                                    UIPasteboard.general.string = customer.cid
                                case .favorite:
                                    togleIsFavorit(customer)
                                }
                            }
                        })
                    }
                }
            }
            Section(header: Text("Public")) {
                ForEach(Target.customers, id: \.id) { customer in
                    Button(action: {
                        onSelection?(customer)
                    }, label: {
                        CustomerView(customer: customer, actions: [.copyToken]) {
                            switch $0 {
                            case .copyToken:
                                UIPasteboard.general.string = customer.cid
                            case .edit, .delete, .favorite: ()
                            }
                        }
                    })
                }
            }
        }
        .refreshable {
            loadData()
        }
        .sheet(item: $customerToEdit) { c in
            NavigationView {
                NewCustomerView(c)
                    .onDisappear(perform: loadData)
            }
        }
        .sheet(isPresented: $showAddCustomer) {
            NavigationView {
                NewCustomerView(nil)
                    .onDisappear(perform: loadData)
            }
        }
    }
    
    func loadData() {
        withAnimation {
            customers = DB.shared.get(key: .keyCustomCustomers) ?? []
        }
    }
    
    func togleIsFavorit(_ customer: AppCustomer) {
        var c = customer
        c.togleFavorite()
        DB.shared.addCustomer(c)
        loadData()
    }
}

extension [AppCustomer] {
    func filterFavorite(_ filter: Bool) -> [AppCustomer]{
        self
            .filter({ !filter || $0.isFavorite == true })
    }
}

fileprivate struct CustomerView: View {
    enum Action { case edit, delete, copyToken, favorite }
    
    let customer: AppCustomer
    var actions: Set<Action> = [.edit , .delete, .copyToken, .favorite]
    var onEdit: ((Action) -> ())?
    
    var body: some View {
        HStack {
            Text("*" + customer.cid.suffix(5).prefix(4))
            Text(customer.name ?? customer.id)
            if let g = customer.group?.nonEmpty {
                Text("/\(g)")
            }
            if (customer.isFavorite == true) {
                Text("*")
            }
            Spacer()
            HStack {
                if let onEdit {
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
                if customer.id == bLinkup.customer?.id {
                    Image(systemName: "checkmark")
                        .tint(bLinkup.isLoginRequired ? .blue : .green)
                }
            }
        }
    }
}

#Preview {
    CustomerSelectorView(
        appType: .constant(0),
        onSelection: { _ in }
    )
}
