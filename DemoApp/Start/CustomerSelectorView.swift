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
    @State private var showMobbinUXDemo = false
    @State private var showBucksDemo = false
    @State private var showSixers76Demo = false
    @State private var showChargersV2Demo = false
    @State private var showCommandersV2Demo = false
    @State private var showSabresDemo = false
    @State private var showCavsDemo = false
    @State private var showSixersDemo = false
    @State private var showEugeneDemo = false
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
                        Button(action: { resetChargersV2Demo() },
                               label: { Text("Reset Chargers Demo") })
                        Button(action: { resetCommandersV2Demo() },
                               label: { Text("Reset Commanders Demo") })
                        Button(action: { resetSixersDemo() },
                               label: { Text("Reset Sixers Demo") })
                        Button(action: { resetEugeneDemo() },
                               label: { Text("Reset Eugene Demo") })
                        Button(action: { resetMobbinUXDemo() },
                               label: { Text("Reset Mobbin UX/UI Demo") })
                        Button(action: { resetBucksDemo() },
                               label: { Text("Reset Bucks Demo") })
                        Button(action: { resetSixers76Demo() },
                               label: { Text("Reset 76ers Demo") })
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
        .fullScreenCover(isPresented: $showMobbinUXDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#241773",
                secondaryHEX: "#000000",
                customerName: "ravens-mobbin",
                onClose: { showMobbinUXDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showBucksDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#00471B",
                secondaryHEX: "#EEE1C6",
                customerName: "bucks",
                onClose: { showBucksDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showSixers76Demo) {
            BlinkupLocalDemo(
                primaryHEX: "#006BB6",
                secondaryHEX: "#002963",
                customerName: "76ers",
                onClose: { showSixers76Demo = false }
            )
        }
        .fullScreenCover(isPresented: $showChargersV2Demo) {
            BlinkupLocalDemo(
                primaryHEX: "#0080C6",
                secondaryHEX: "#002A5E",
                customerName: "chargers2",
                onClose: { showChargersV2Demo = false }
            )
        }
        .fullScreenCover(isPresented: $showCommandersV2Demo) {
            BlinkupLocalDemo(
                primaryHEX: "#5A1414",
                secondaryHEX: "#FFB612",
                customerName: "commanders2",
                onClose: { showCommandersV2Demo = false }
            )
        }
        .fullScreenCover(isPresented: $showSabresDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#002654",
                secondaryHEX: "#FCB81C",
                customerName: "sabres",
                onClose: { showSabresDemo = false }
            )
        }
        .fullScreenCover(isPresented: $showCavsDemo) {
            BlinkupLocalDemo(
                primaryHEX: "#860038",
                secondaryHEX: "#FDBB30",
                customerName: "cavs",
                onClose: { showCavsDemo = false }
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
            if customer.cid == "ravens-mobbin-local-demo" {
                showMobbinUXDemo = true
                return
            }
            if customer.cid == "bucks-local-demo" {
                showBucksDemo = true
                return
            }
            if customer.cid == "76ers-local-demo" {
                showSixers76Demo = true
                return
            }
            if customer.cid == "chargers2-local-demo" {
                showChargersV2Demo = true
                return
            }
            if customer.cid == "commanders2-local-demo" {
                showCommandersV2Demo = true
                return
            }
            if customer.cid == "sabres-local-demo" {
                showSabresDemo = true
                return
            }
            if customer.cid == "cavs-local-demo" {
                showCavsDemo = true
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

    func resetChargersV2Demo() {
        let defaults = UserDefaults.standard
        let chargersIds = ["chargers-stadium", "chargers-toms", "chargers-tavern", "chargers-busbys",
                           "chargers-33taps", "chargers-lopez", "chargers-harp", "chargers-cruisers"]
        for id in chargersIds {
            defaults.removeObject(forKey: "chargers_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "chargers_bonus_outcome")
        defaults.removeObject(forKey: "chargers_popup_date")
        defaults.set(false,  forKey: "chargers_v2_stadium_checkin")
        defaults.set("",     forKey: "chargers_v2_bar_checkin")
        defaults.set(0,      forKey: "chargers_v2_points")
        defaults.set(false,  forKey: "chargers_v2_simulate_not_at_venue")
        defaults.set("",     forKey: "chargers_v2_pending_bar")
        defaults.set(false,  forKey: "chargers_is_checked_in")
        defaults.set(6,      forKey: "chargers_first_mover_count")
        defaults.removeObject(forKey: "chargers_v2_concession_date")
        defaults.removeObject(forKey: "chargers_v2_bar_deal_date")
        defaults.set(2,      forKey: "chargers_season_checkins_v3")
        defaults.set(1,      forKey: "chargers_season_stadium_games_v3")
        defaults.set(1,      forKey: "chargers_season_stadium_deals_v3")
        defaults.set(0,      forKey: "chargers_season_bar_deals")
        defaults.set(false,  forKey: "chargers_v2_deal_saved")
        defaults.set(false,  forKey: "chargers_v2_spinner_shown")
        defaults.set("",     forKey: "chargers_v2_detected_venue")
        defaults.set(false,  forKey: "chargers_v2_account_saved")
        defaults.set("",     forKey: "chargers_v2_phone")
        defaults.set(false,  forKey: "chargers_v2_intro_shown")
    }

    func resetCommandersV2Demo() {
        let defaults = UserDefaults.standard
        let commandersIds = ["commanders-stadium", "commanders-pennquarter", "commanders-duffys",
                             "commanders-brotherjimmys", "commanders-brasstap", "commanders-irishwhisper",
                             "commanders-cornerstone", "commanders-looneys"]
        for id in commandersIds {
            defaults.removeObject(forKey: "commanders_redeemed_\(id)")
            defaults.removeObject(forKey: "checkin_\(id)")
        }
        defaults.removeObject(forKey: "commanders_bonus_outcome")
        defaults.removeObject(forKey: "commanders_popup_date")
        defaults.set(false,  forKey: "commanders_v2_stadium_checkin")
        defaults.set("",     forKey: "commanders_v2_bar_checkin")
        defaults.set(0,      forKey: "commanders_v2_points")
        defaults.set(false,  forKey: "commanders_v2_simulate_not_at_venue")
        defaults.set("",     forKey: "commanders_v2_pending_bar")
        defaults.set(false,  forKey: "commanders_is_checked_in")
        defaults.set(6,      forKey: "commanders_first_mover_count")
        defaults.removeObject(forKey: "commanders_v2_concession_date")
        defaults.removeObject(forKey: "commanders_v2_bar_deal_date")
        defaults.set(2,      forKey: "commanders_season_checkins_v3")
        defaults.set(1,      forKey: "commanders_season_stadium_games_v3")
        defaults.set(1,      forKey: "commanders_season_stadium_deals_v3")
        defaults.set(0,      forKey: "commanders_season_bar_deals")
        defaults.set(false,  forKey: "commanders_v2_deal_saved")
        defaults.set(false,  forKey: "commanders_v2_spinner_shown")
        defaults.set("",     forKey: "commanders_v2_detected_venue")
        defaults.set(false,  forKey: "commanders_v2_account_saved")
        defaults.set("",     forKey: "commanders_v2_phone")
        defaults.set(false,  forKey: "commanders_v2_intro_shown")
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

    func resetMobbinUXDemo() {
        let d = UserDefaults.standard
        d.set(false,  forKey: "ravens_v2_stadium_checkin")
        d.set("",     forKey: "ravens_v2_bar_checkin")
        d.set(0,      forKey: "ravens_v2_points")
        d.set(false,  forKey: "ravens_v2_location_denied")
        d.set(false,  forKey: "ravens_v2_simulate_not_at_venue")
        d.set("",     forKey: "ravens_v2_pending_bar")
        d.set(false,  forKey: "ravens_is_checked_in")
        d.removeObject(forKey: "ravens_v2_concession_date")
        d.removeObject(forKey: "ravens_v2_bar_deal_date")
        d.set(2,      forKey: "ravens_season_checkins")
        d.set(false,  forKey: "ravens_v2_deal_saved")
        d.set(false,  forKey: "ravens_v2_spinner_shown")
        d.set("",     forKey: "ravens_v2_detected_venue")
        d.set(false,  forKey: "ravens_v2_account_saved")
        d.set("",     forKey: "ravens_v2_phone")
        d.set(false,  forKey: "ravens_v2_intro_shown")
        d.set(false,  forKey: "ravens_v2_home_checkin")
        d.set(false,  forKey: "ravens_demo_bud_winner")
        d.set("stadium", forKey: "ravens_v2_demo_mode")
        d.set(0,      forKey: "mobbin_prize_scenario")
        d.set(true,   forKey: "ravens_is_gameday")
        d.removeObject(forKey: "mobbin_won_prizes")
    }

    func resetSixers76Demo() {
        let d = UserDefaults.standard
        let ids = ["sixers76-arena", "sixers76-tradesmans", "sixers76-xfinity", "sixers76-chickies", "sixers76-fado", "sixers76-garage"]
        for id in ids {
            d.removeObject(forKey: "sixers76_redeemed_\(id)")
            d.removeObject(forKey: "checkin_\(id)")
        }
        d.set(false,  forKey: "ravens_v2_stadium_checkin")
        d.set("",     forKey: "ravens_v2_bar_checkin")
        d.set(21000,  forKey: "ravens_v2_points")
        d.set(false,  forKey: "ravens_v2_spinner_shown")
        d.set("",     forKey: "ravens_v2_detected_venue")
        d.set(false,  forKey: "ravens_v2_account_saved")
        d.set("",     forKey: "ravens_v2_phone")
        d.set(false,  forKey: "ravens_v2_intro_shown")
        d.set(20,     forKey: "ravens_season_checkins_v3")
        d.set(30,     forKey: "ravens_season_stadium_games_v3")
        d.removeObject(forKey: "ravens_v2_concession_date")
        d.removeObject(forKey: "ravens_v2_bar_deal_date")
        d.set(0,      forKey: "sixers76_prize_scenario")
        d.set("stadium", forKey: "sixers76_demo_mode")
        d.removeObject(forKey: "mobbin_won_prizes")
    }

    func resetBucksDemo() {
        let d = UserDefaults.standard
        let bucksIds = ["bucks-arena", "bucks-district14", "bucks-highbury", "bucks-drink-wisc", "bucks-mos-irish", "bucks-swig"]
        for id in bucksIds {
            d.removeObject(forKey: "bucks_redeemed_\(id)")
            d.removeObject(forKey: "checkin_\(id)")
        }
        d.set(false,  forKey: "ravens_v2_stadium_checkin")
        d.set("",     forKey: "ravens_v2_bar_checkin")
        d.set(0,      forKey: "ravens_v2_points")
        d.set(false,  forKey: "ravens_v2_spinner_shown")
        d.set("",     forKey: "ravens_v2_detected_venue")
        d.set(false,  forKey: "ravens_v2_account_saved")
        d.set("",     forKey: "ravens_v2_phone")
        d.set(false,  forKey: "ravens_v2_intro_shown")
        d.set(2,      forKey: "ravens_season_checkins_v3")
        d.removeObject(forKey: "ravens_v2_concession_date")
        d.removeObject(forKey: "ravens_v2_bar_deal_date")
        d.set(0,      forKey: "bucks_prize_scenario")
        d.set("stadium", forKey: "bucks_demo_mode")
        d.removeObject(forKey: "mobbin_won_prizes")
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
