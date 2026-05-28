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
    @State private var showBotyDemo = false
    @State private var showWvuDemo = false
    @State private var showSbuxDemo = false
    @State private var showRavensDemo = false
    @State private var showRavensV2Demo = false
    @State private var showRavensBudLightDemo = false
    @State private var showSixersDemo = false
    @State private var showEugeneDemo = false
    @AppStorage("overFullScreen") private var overFullScreen: Bool?
    @AppStorage("Favorite") private var onlyFavoriteState: Bool?
    var onlyFavorite: Bool { onlyFavoriteState ?? false }
    
    @State private var pubFavs: [String] = []

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
                let pub = Target.customers.filter({ f.contains($0.cid) || !onlyFavorite })
                if !pub.isEmpty {
                    Section(header: Text("Public")) {
                        ForEach(pub, id: \.id) { customer in
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
                        Button(action: { resetBotyDemo() },
                               label: { Text("Reset BOTY Demo") })
                        Button(action: { resetWvuDemo() },
                               label: { Text("Reset WVU Demo") })
                        Button(action: { resetSbuxDemo() },
                               label: { Text("Reset Starbucks Demo") })
                        Button(action: { resetRavensDemo() },
                               label: { Text("Reset Ravens Demo") })
                        Button(action: { resetRavensV2StadiumDemo() },
                               label: { Text("Reset V2 — Stadium Demo") })
                        Button(action: { resetRavensV2BarDemo() },
                               label: { Text("Reset V2 — Bar Demo") })
                        Button(action: { resetSixersDemo() },
                               label: { Text("Reset Sixers Demo") })
                        Button(action: { resetEugeneDemo() },
                               label: { Text("Reset Eugene Demo") })
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
        .fullScreenCover(isPresented: $showWvuDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#002855",
                secondaryHEX: "#EAAA00",
                customerName: "wvu",
                arenaMapImage: UIImage(named: "wvu_stadium_map"),
                onClose: { showWvuDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showBotyDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#3A6896",
                secondaryHEX: "#EDE5D3",
                customerName: "boty",
                onClose: { showBotyDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showSbuxDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#00704A",
                secondaryHEX: "#CBA258",
                customerName: "sbux",
                onClose: { showSbuxDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showRavensDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#241773",
                secondaryHEX: "#000000",
                customerName: "ravens",
                onClose: { showRavensDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showRavensV2Demo) {
            BlinkupLocalDemo(
                primaryHEX: "#241773",
                secondaryHEX: "#000000",
                customerName: "ravens2",
                onClose: { showRavensV2Demo = false }
            )
        }
        .fullScreenCover(isPresented: $showRavensBudLightDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#241773",
                secondaryHEX: "#000000",
                customerName: "ravens-bl",
                onClose: { showRavensBudLightDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showSixersDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#006BB6",
                secondaryHEX: "#ED174C",
                customerName: "sixers",
                onClose: { showSixersDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showEugeneDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#241773",
                secondaryHEX: "#000000",
                customerName: "eugene",
                onClose: { showEugeneDemo = false }
            )
        }
    }
    
    func loadData() {
        let pubFavs = loadPublicFavs()
        let customers = DB.shared.get(key: .keyCustomCustomers) ?? [AppCustomer]()
        
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
        if #available(iOS 16, *) {
            str += "/" + bLinkupSDK.kBUILD
        }
        
        return str
    }
    
    func process(_ customer: AppCustomer, _ action: Action, pub: Bool) {
        switch action {
        case .open:
            if customer.cid == "wvu-local-demo" {
                showWvuDemo = true
                return
            }
            if customer.cid == "boty-local-demo" {
                showBotyDemo = true
                return
            }
            if customer.cid == "sbux-local-demo" {
                showSbuxDemo = true
                return
            }
            if customer.cid == "ravens-local-demo" {
                showRavensDemo = true
                return
            }
            if customer.cid == "ravens2-local-demo" {
                showRavensV2Demo = true
                return
            }
            if customer.cid == "ravens-bl-local-demo" {
                showRavensBudLightDemo = true
                return
            }
            if customer.cid == "sixers-local-demo" {
                showSixersDemo = true
                return
            }
            if customer.cid == "eugene-local-demo" {
                showEugeneDemo = true
                return
            }
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
        UserDefaults.standard.setValue(c.group, forKey: "com.blinktech.sdk.group")
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
    func resetBotyDemo() {
        let defaults = UserDefaults.standard
        let botyIds = ["boty-main", "boty-cart-1", "boty-cart-2"]
        for id in botyIds {
            defaults.removeObject(forKey: "boty_invites_\(id)")
            defaults.removeObject(forKey: "boty_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
    }

    func resetWvuDemo() {
        let defaults = UserDefaults.standard
        let wvuIds = ["wvu-keglers", "wvu-goat", "wvu-msb-downtown", "wvu-msb-evansdale",
                      "wvu-bww-suncrest", "wvu-bww-utc", "wvu-bigtimes", "wvu-lakehouse", "wvu-tropics"]
        for id in wvuIds {
            defaults.removeObject(forKey: "wvu_invites_\(id)")
            defaults.removeObject(forKey: "wvu_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
    }

    func resetSbuxDemo() {
        let defaults = UserDefaults.standard
        let sbuxIds = ["sbux-beacon", "sbux-la-costa", "sbux-via-campanile", "sbux-encinitas", "sbux-bressi", "sbux-carlsbad", "sbux-oceanside"]
        for id in sbuxIds {
            defaults.removeObject(forKey: "sbux_invites_\(id)")
            defaults.removeObject(forKey: "sbux_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "sbux_demo_last_reset")
    }

    func resetRavensDemo() {
        let defaults = UserDefaults.standard
        let ravensIds = ["ravens-pickles", "ravens-pratt", "ravens-sliders", "ravens-dempsey", "ravens-bullpen"]
        for id in ravensIds {
            defaults.removeObject(forKey: "ravens_invites_\(id)")
            defaults.removeObject(forKey: "ravens_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "ravens_demo_last_reset")
        defaults.removeObject(forKey: "ravens_attendance")
        defaults.removeObject(forKey: "ravens_passport")
        defaults.removeObject(forKey: "ravens_popup_date")
        defaults.removeObject(forKey: "ravens_bonus_outcome")
        defaults.removeObject(forKey: "ravens_v2_points")
        defaults.removeObject(forKey: "ravens_v2_stadium_checkin")
        defaults.removeObject(forKey: "ravens_v2_bar_checkin")
        defaults.removeObject(forKey: "ravens_v2_demo_mode")
    }

    func resetRavensV2StadiumDemo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ravens_v2_points")
        defaults.removeObject(forKey: "ravens_v2_stadium_checkin")
        defaults.removeObject(forKey: "ravens_v2_bar_checkin")
        defaults.removeObject(forKey: "ravens_v2_concession_date")
        defaults.removeObject(forKey: "ravens_popup_date")
        defaults.set("stadium", forKey: "ravens_v2_demo_mode")
    }

    func resetRavensV2BarDemo() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ravens_v2_points")
        defaults.removeObject(forKey: "ravens_v2_stadium_checkin")
        defaults.removeObject(forKey: "ravens_v2_bar_checkin")
        defaults.removeObject(forKey: "ravens_v2_concession_date")
        defaults.removeObject(forKey: "ravens_popup_date")
        defaults.set("bar", forKey: "ravens_v2_demo_mode")
    }

    func resetSixersDemo() {
        let defaults = UserDefaults.standard
        let sixersIds = ["sixers-arena", "sixers-xfinity", "sixers-chickies", "sixers-stogies", "sixers-fado", "sixers-mcgillin"]
        for id in sixersIds {
            defaults.removeObject(forKey: "sixers_invites_\(id)")
            defaults.removeObject(forKey: "sixers_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "sixers_demo_last_reset")
        defaults.removeObject(forKey: "sixers_attendance")
        defaults.removeObject(forKey: "sixers_passport")
        defaults.removeObject(forKey: "sixers_popup_date")
        defaults.removeObject(forKey: "sixers_bonus_outcome")
        defaults.removeObject(forKey: "sixers_is_checked_in")
    }

    func resetEugeneDemo() {
        let defaults = UserDefaults.standard
        let eugeneIds = ["eugene-pickles", "eugene-pratt", "eugene-sliders", "eugene-dempsey", "eugene-stadium"]
        for id in eugeneIds {
            defaults.removeObject(forKey: "eugene_invites_\(id)")
            defaults.removeObject(forKey: "eugene_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "eugene_demo_last_reset")
        defaults.removeObject(forKey: "eugene_is_checked_in")
        defaults.removeObject(forKey: "eugene_is_gameday")
        defaults.removeObject(forKey: "eugene_popup_date")
    }

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
