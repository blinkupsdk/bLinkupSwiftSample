//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import Contacts
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
        VStack(spacing: 0) {
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
                            CustomerView(customer: customer, actions: []) {
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
            .animation(.easeInOut, value: onlyFavorite)
            .modify({
                if #available(iOS 17, *) {
                    $0.transition(.blurReplace)
                } else {
                    $0.transition(.slide)
                }
            })
            .refreshable {
                loadData()
            }
                        
            Text(infoString())
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.5))
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .navigationTitle("")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onlyFavorite.toggle()
                    }
                }, label: {
                    Image(systemName: onlyFavorite ? "heart.fill" : "heart")
                })
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showAddCustomer = true },
                       label: { Image(systemName: "plus") })

            }
            #if DEBUG
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { addDummyContacts() },
                       label: { Image(systemName: "person.badge.plus") })

            }
            #endif
        })
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
    
    func infoString() -> String {
        let buildKey = kCFBundleVersionKey as String
        let info = Bundle.main.infoDictionary
        let target = info?["CFBundleName"] as? String ?? "?"
        let app = target == "DemoAppSTG" ? "ST" : "PR"
        let build = info?[buildKey] as? String ?? "?"
        
        var str = app + " #" + build
        if #available(iOS 16, *) {
            str += "/" + bLinkupSDK.kBUILD
        }
        
        return str
    }
    
    #if DEBUG
    func addDummyContacts() {
        let store = CNContactStore()
        
        for i in 1...1500 {
            let contact = CNMutableContact()
            let suffix = String(format: "%05i", i)
            contact.givenName = "Test"
            contact.familyName = "User" + suffix
            var phones = [CNLabeledValue(
                label: CNLabelPhoneNumberMobile,
                value: CNPhoneNumber(stringValue: "555-50"+suffix)
            )]
            if i%2 == 0 {
                phones.append(CNLabeledValue(
                    label: CNLabelPhoneNumberiPhone,
                    value: CNPhoneNumber(stringValue: "555-51"+suffix)
                ))
            }
            
            contact.phoneNumbers = phones
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try? store.execute(saveRequest)
        }
    }
    #endif
}

extension [AppCustomer] {
    func filterFavorite(_ filter: Bool) -> [AppCustomer]{
        self
            .filter({ !filter || $0.isFavorite == true })
    }
}

#Preview {
    NavigationView {
        CustomerSelectorView(
            appType: .constant(0),
            onSelection: { _ in }
        )
    }
}
