//
//  DemoAppApp.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 30.10.2023.
//

import SwiftUI
import bLinkup

@main
struct DemoAppApp: App {
    @State var customer: AppCustomer?
    @State var showApp: Bool = false
    @State var appType: Int = UserDefaults.standard.integer(forKey: "AppType")
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        bLinkup.configure()
        delegate.onMessagingToken = { token in
            bLinkup.setPushID(token, completion: { _ in })
            print("FIRToken: \(token ?? "-")")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CustomerSelectorView(customer: $customer, appType: $appType)
                .sheet(isPresented: $showApp) {
                    if let customer = customer {
                        switch appType {
                        case 0:
                            DemoRootView(customer: $customer)
                        default:
                            BlinkupRootScreen(customer: customer.asBlinkupCustomer(),
                                              branding: customer.asBlinkupBranding(),
                                              onClose: { self.customer = nil })
                            .onChange(of: customer) { print($0.name ?? "-") }
                        }
                    } else {
                        EmptyView()
                    }
                }
        }
        .onChange(of: appType) { v in
            UserDefaults.standard.set(v, forKey: "AppType")
        }
        .onChange(of: customer) { v in
                showApp = v != nil
        }
        .onChange(of: showApp) { v in
            if !v {
                customer = nil
            }
        }
    }
    
    func handleIncomigURL(_ url: URL) {
        guard url.scheme == "blinkupapp" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }

        switch components.host {
        case "customer":
            guard let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                print("Customer id not found")
                return
            }
            let name = components.queryItems?.first(where: { $0.name == "name" })?.value
            let c = AppCustomer(id: id, name: name)
            DB.shared.addCustomer(c)
        default:
            print("Unknown URL, we can't handle this one!")
        }
    }

}
