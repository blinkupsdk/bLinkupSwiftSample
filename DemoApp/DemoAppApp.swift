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
        bLinkup.configure("Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
