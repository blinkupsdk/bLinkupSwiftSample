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
    init() {
        bLinkup.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleIncomigURL(url)
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
            let c = Customer(id: id, name: name)
            DB.shared.addCustomer(c)
        default:
            print("Unknown URL, we can't handle this one!")
        }
    }
}
