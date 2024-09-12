//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import bLinkup
import SwiftUI

struct CustomerSelectorView: View {
    @Binding var customer: Customer?
    @Binding var appType: Int
    
    @State var customs: [Customer] = DB.shared.get(key: .keyCustomCustomers) ?? []
    
    var body: some View {
        
        Picker("Choose", selection: $appType) {
            Text("Demo").tag(0)
            Text("SDK-UI").tag(1)
        }
        .pickerStyle(.segmented)
        .padding()
        
        Form {
                if !customs.isEmpty {
                    Section(header: Text("Private")) {
                        ForEach(customs, id: \.id) { customer in
                            Button(action: {
                                self.customer = customer
                            }, label: {
                                HStack {
                                    Image(systemName: "person")
                                    Text(customer.name ?? customer.id)
                                    Spacer()
                                    Button(action: {
                                        customs = DB.shared.removeCustomer(customer)
                                    }, label: {
                                        Image(systemName: "trash")
                                    })
                                }
                            })
                        }
                    }
                }
                Section(header: Text("Public")) {
                    ForEach(Target.customers, id: \.id) { customer in
                        Button(action: {
                            self.customer = customer
                        }, label: {
                            HStack {
                                Image(systemName: "person")
                                Text(customer.name ?? customer.id)
                            }
                            .foregroundStyle(customer.id == bLinkup.customer?.id ? .black : .blue)
                        })
                    }
                }
        }
        .refreshable {
            let list: [Customer] = DB.shared.get(key: .keyCustomCustomers) ?? []
            customs = list
        }
    }
}

#Preview {
    CustomerSelectorView(customer: .constant(Customer(id: "")), appType: .constant(0))
}
