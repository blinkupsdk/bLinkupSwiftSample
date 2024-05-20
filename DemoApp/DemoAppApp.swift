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
    @State var customer: Customer?
    @State var appType: Int = UserDefaults.standard.integer(forKey: "AppType")
    
    init() {
        bLinkup.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if let customer = customer {
                switch appType {
                case 0:
                    DemoRootView(customer: $customer)
                default:
                    BlinkupRootScreen(customer: customer,
                                      branding: branding(for: customer),
                                      onClose: { self.customer = nil })
                    .onChange(of: customer) { print($0.name ?? "-") }
                }
            } else {
                CustomerSelectorView(customer: $customer, appType: $appType)
            }
        }
        .onChange(of: appType) { v in
            UserDefaults.standard.set(v, forKey: "AppType")
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
            let c = Customer(id: id, name: name)
            DB.shared.addCustomer(c)
        default:
            print("Unknown URL, we can't handle this one!")
        }
    }
    
    
    func branding(for c: Customer) -> Branding {
        switch c.id {
        case "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=": //"Chicago Demo"
            return .init(primary: UIColor(red: 0, green: 0.14, blue: 0.3, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoDemo",
                         name: c.name)
        case "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=": //Milwaukee Bucks
            return .init(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "AmericanTypewriter",
                         logo: "logoMilwaukee",
                         name: c.name)
        case "iqPbaubl_9FtQTTBGrueAdom0TnlSbTPZO675ZLQS1o=": //Charlotte Hornets"
            return .init(primary: UIColor(red: 0, green: 0.54, blue: 0.64, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "GillSans",
                         logo: "logoHornets",
                         name: c.name)
        case "uzU20c9Zs6_-Sn3o_lv9jrPM4kZeH5nnnn05iNfc1FE=": //Atlanta Braves
            return .init(primary: UIColor(red: 0.75, green: 0.02, blue: 0.20, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "HelveticaNeue",
                         logo: "logoAtlanta",
                         name: c.name)
        case "ssD1qVnNw1KFPT3eFFtquHiSo0qlZzcK783Kwku9xWU=": // Clemson Tigers
            return .init(primary: UIColor(red: 0.9, green: 0.45, blue: 0.18, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoTigers",
                         name: c.name)
        default:
            return .init(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoDemo",
                         name: c.name)
        }
    }
}
