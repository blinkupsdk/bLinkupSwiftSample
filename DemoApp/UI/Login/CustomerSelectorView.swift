//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import bLinkup
import SwiftUI

private let kCustomers = [
    Customer(id: "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=", name: "Chicago Demo"),
    Customer(id: "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=", name: "Milwaukee Bucks"),
    Customer(id: "iqPbaubl_9FtQTTBGrueAdom0TnlSbTPZO675ZLQS1o=", name: "Charlotte Hornets"),
    Customer(id: "uzU20c9Zs6_-Sn3o_lv9jrPM4kZeH5nnnn05iNfc1FE=", name: "Atlanta Braves"),
    Customer(id: "ssD1qVnNw1KFPT3eFFtquHiSo0qlZzcK783Kwku9xWU=", name: "Clemson Tigers"),
    Customer(id: "7x1oDfFEpUj4LVIzz8XSskomH5dINsRZmLY6XZSfPvE=", name: "Test"),
]

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
                    ForEach(kCustomers, id: \.id) { customer in
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
