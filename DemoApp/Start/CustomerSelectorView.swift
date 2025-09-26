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

    @State var customs: [AppCustomer] = DB.shared.get(key: .keyCustomCustomers) ?? []
    @State private var showAddCustomer = false
    @State private var customerToEdit: AppCustomer?
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
    //            Picker("Choose", selection: $appType) {
    //                Text("Demo").tag(0)
    //                Text("SDK-UI").tag(1)
    //            }
    //            .pickerStyle(.segmented)
        Spacer()

            Button(action: { showAddCustomer = true },
                   label: { Image(systemName: "plus") })
        }
        .padding()
        
        Form {
            if !customs.isEmpty {
                Section(header: Text("Private")) {
                    ForEach(customs, id: \.id) { customer in
                        Button(action: {
                            onSelection?(customer)
                        }, label: {
                            CustomerView(customer: customer) { action in
                                switch action {
                                case .edit:
                                    customerToEdit = customer
                                case .delete:
                                    customs = DB.shared.removeCustomer(customer)
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
                        CustomerView(customer: customer)
                    })
                }
            }
        }
        .refreshable {
            let list: [AppCustomer] = DB.shared.get(key: .keyCustomCustomers) ?? []
            customs = list
        }
        .sheet(item: $customerToEdit) { c in
            NavigationView {
                NewCustomerView(c)
                    .onDisappear() {
                        customs = DB.shared.get(key: .keyCustomCustomers) ?? []
                    }
            }
        }
        .sheet(isPresented: $showAddCustomer) {
            NavigationView {
                NewCustomerView(nil)
                    .onDisappear() {
                        customs = DB.shared.get(key: .keyCustomCustomers) ?? []
                    }
            }
        }
    }
}

fileprivate struct CustomerView: View {
    enum Action { case edit, delete }
    
    let customer: AppCustomer
    var onEdit: ((Action) -> ())?
    
    var body: some View {
        HStack {
            Text("*" + customer.cid.suffix(5).prefix(4))
            Text(customer.name ?? customer.id)
            if let g = customer.group?.nonEmpty {
                Text("/\(g)")
            }
            Spacer()
            HStack {
                if let onEdit {
                    Menu(content: {
                        Button("edit", action: { onEdit(.edit) })
                        Button("delete", action: { onEdit(.delete) })
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
