//
//  CustomerSelectorView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import Contacts
import bLinkupSDK
import SwiftUI

private let kPubFavsDataKey = "pubFavs"

struct CustomerSelectorView: View {
    typealias Action = CustomerView.Action

    @State var customers: [AppCustomer] = DB.shared.get(key: .keyCustomCustomers) ?? []
    
    @State private var customerToEdit: AppCustomer?
    @State private var customerToFull: AppCustomer?
    @State private var customerToPresent: AppCustomer?

    @AppStorage("overFullScreen") private var overFullScreen: Bool?
    @AppStorage("Favorite") private var onlyFavoriteState: Bool?
    var onlyFavorite: Bool { onlyFavoriteState ?? false }
    
    @State private var pubFavs: [String] = []
    @State private var legacyExpanded: Bool = false

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                let priv = customers.filter({ $0.isFavorite ?? !onlyFavorite })
                if !priv.isEmpty {
                    Section(header: Text("Private")) {
                        ForEach(priv, id: \.id) { customer in
                            CustomerView(
                                customer: customer,
                                isFavorite: customer.isFavorite == true
                            ) { action in
                                process(customer, action, pub: false)
                            }
                        }
                    }
                }
                let f = pubFavs
                let current = Target.currentCustomers.filter({ f.contains($0.cid) || !onlyFavorite })
                if !current.isEmpty {
                    Section(header: Text("Current Demos")) {
                        ForEach(current, id: \.id) { customer in
                            CustomerView(
                                customer: customer,
                                isFavorite: pubFavs.contains(customer.cid),
                                actions: [.open, .favorite]
                            ) {
                                process(customer, $0, pub: true)
                            }
                        }
                    }
                }
                let legacy = Target.legacyCustomers.filter({ f.contains($0.cid) || !onlyFavorite })
                if !legacy.isEmpty {
                    Section {
                        DisclosureGroup(isExpanded: $legacyExpanded) {
                            ForEach(legacy, id: \.id) { customer in
                                CustomerView(
                                    customer: customer,
                                    isFavorite: pubFavs.contains(customer.cid),
                                    actions: [.open, .favorite]
                                ) {
                                    process(customer, $0, pub: true)
                                }
                            }
                        } label: {
                            Text("Legacy Demos")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
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
        .task({
            loadData()
        })
        .navigationTitle("")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            onlyFavoriteState = !onlyFavorite
                        }
                    }, label: {
                        Image(systemName: onlyFavorite ? "heart.fill" : "heart")
                    })
                    
                    Button(action: { customerToEdit = AppCustomer() },
                           label: { Image(systemName: "plus") })
                    
                    Menu {
                        Button(action: {
                            overFullScreen = true
                        }, label: {
                            if overFullScreen ?? false { Image(systemName: "checkmark" ) }
                            Text("Full")
                        })
                        Button(action: {
                            overFullScreen = false
                        }, label: {
                            if !(overFullScreen ?? false) { Image(systemName: "checkmark" ) }
                            Text("Card")
                        })
                        #if DEBUG
                        Divider()
                        Button(action: { addDummyContacts() },
                               label: { Image(systemName: "person.badge.plus") })
                        #endif
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        })
        .sheet(item: $customerToEdit) { c in
            NavigationView {
                NewCustomerView(c)
                    .onDisappear(perform: loadData)
            }
        }
        .sheet(item: $customerToPresent) {
            blinkupScreen($0, exit: false)
        }
        .fullScreenCover(item: $customerToFull) {
            blinkupScreen($0, exit: true)
        }
    }
    
    func loadData() {
        let pubFavs = loadPublicFavs()
        let customers = DB.shared.get(key: .keyCustomCustomers) ?? [AppCustomer]()
        
        for r in Target.customers {
            print("\(r.cid) - \(r.name ?? "-")")
        }
        withAnimation {
            self.pubFavs = pubFavs
            self.customers = customers
        }
    }
    
    func togleIsFavorit(_ customer: AppCustomer, pub: Bool) {
        var c = customer
        if pub {
            if pubFavs.contains(customer.cid) {
                pubFavs.removeAll(where: { $0 == c.cid })
            } else {
                pubFavs.append(c.cid)
            }
            savePublicFavs(pubFavs)
        } else {
            c.togleFavorite()
            DB.shared.addCustomer(c)
            loadData()
        }
    }
    
    func infoString() -> String {
        let buildKey = kCFBundleVersionKey as String
        let info = Bundle.main.infoDictionary
        let target = info?["CFBundleName"] as? String ?? "?"
        let app = target == "DemoAppSTG" ? "ST" : "PR"
        let build = info?[buildKey] as? String ?? "?"
        
        var str = app + " #" + build
        if #available(iOS 17, *) {
            str += "/" + bLinkupSDK.kBUILD
        }
        
        return str
    }
    
    func process(_ customer: AppCustomer, _ action: Action, pub: Bool) {
        switch action {
        case .open:
            if overFullScreen ?? false {
                customerToFull = customer
            } else {
                customerToPresent = customer
            }
        case .edit:
            customerToEdit = customer
        case .delete:
            customers = DB.shared.removeCustomer(customer)
            loadData()
        case .copyToken:
            UIPasteboard.general.string = customer.cid
        case .favorite:
            togleIsFavorit(customer, pub: pub)
        }
    }
    
    func blinkupScreen(_ c: AppCustomer?, exit: Bool) -> BlinkupRootScreen? {
        guard let c else {
            return nil
        }
        UserDefaults.standard.setValue(c.host ?? Target.hosts.first, forKey: "com.blinktech.sdk.host")
        UserDefaults.standard.setValue(c.helper, forKey: "com.blinktech.sdk.helper")

        return BlinkupRootScreen(
            customer: c.asBlinkupCustomer(),
            branding: c.asBlinkupBranding(),
            onClose: exit ? { customerToFull = nil; customerToPresent = nil } : nil
        )
    }
    
    // MARK: - public favs
    
    func loadPublicFavs() -> [String] {
        let pubData = UserDefaults.standard.data(forKey: kPubFavsDataKey) ?? Data()
        let pubFavs: [String] = (try? JSONDecoder().decode([String].self, from: pubData)) ?? []
        return pubFavs
    }
    
    func savePublicFavs(_ favs: [String]) {
        let data = try? JSONSerialization.data(withJSONObject: pubFavs)
        UserDefaults.standard.set(data, forKey: kPubFavsDataKey)
    }
    
    #if DEBUG
    func addDummyContacts() {
        let store = CNContactStore()
        
        for i in 1...1000 {
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

#Preview {
    NavigationView {
        CustomerSelectorView()
    }
}
