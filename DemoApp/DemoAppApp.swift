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
        }
    }
}
