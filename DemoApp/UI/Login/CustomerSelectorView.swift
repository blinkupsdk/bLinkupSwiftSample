//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import bLinkup
import SwiftUI

struct CustomerSelectorView: View {
    @Binding var customer: AppCustomer?
    @Binding var appType: Int
    
    @State var customs: [AppCustomer] = DB.shared.get(key: .keyCustomCustomers) ?? []
    @State private var showAddCustomer = false
    @State private var customerForMenu: AppCustomer?
    @State private var customerToEdit: AppCustomer?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        HStack {
            Picker("Choose", selection: $appType) {
                Text("Demo").tag(0)
                Text("SDK-UI").tag(1)
            }
            .pickerStyle(.segmented)
            
            Button(action: { showAddCustomer = true },
                   label: { Image(systemName: "plus") })
        }
        .padding()
        Form {
                if !customs.isEmpty {
                    Section(header: Text("Private")) {
                        ForEach(customs, id: \.id) { customer in
                            CustomerView(customer: customer)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.customer = customer
                            }
                            .onLongPressGesture(minimumDuration: 0.6, perform: {
                                customerForMenu = customer
                            })
                        }
                    }
                }
                Section(header: Text("Public")) {
                    ForEach(Target.customers, id: \.id) { customer in
                        Button(action: {
                            self.customer = customer
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
            NewCustomerView(c)
                .onDisappear() {
                    customs = DB.shared.get(key: .keyCustomCustomers) ?? []
                }
        }
        .sheet(isPresented: $showAddCustomer,  content: {
            NewCustomerView(nil)
                .onDisappear() {
                    customs = DB.shared.get(key: .keyCustomCustomers) ?? []
                }
        })
        .actionSheet(item: $customerForMenu, content: { c in
            ActionSheet(title: Text(c.name ?? c.id),
                        message: nil,
                        buttons: [
                            .default(Text("Edit"), action: {
                                customerToEdit = c
                            }),
                            .destructive(Text("Delete"), action: {
                                customs = DB.shared.removeCustomer(c)
                            }),
                            .cancel()
                        ])
        })
    }
}

fileprivate struct CustomerView: View {
    let customer: AppCustomer
    var body: some View {
        HStack {
            Image(systemName: "person")
            Text(customer.name ?? customer.id)
            if customer.id == bLinkup.customer?.id {
                Spacer()
                Image(systemName: "checkmark")
                    .tint(bLinkup.isLoginRequired ? .blue : .green)
            }
        }
    }
}

#Preview {
    CustomerSelectorView(customer: .constant(AppCustomer(id: "")), appType: .constant(0))
}
