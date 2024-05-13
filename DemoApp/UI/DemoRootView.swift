//
//  ContentView.swift
//  DemoApp
//
//  Created on 30.10.2023.
//

import SwiftUI
import bLinkup

struct DemoRootView: View {
    @State var isLoggedIn: Bool = !bLinkup.isLoginRequired
    @Binding var customer: Customer?
    
    var body: some View {
        switch isLoggedIn {
        case false:
            StartView(isLoggedIn: $isLoggedIn, customer: $customer)
        case true:
            TabbarView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    DemoRootView(isLoggedIn: false, customer: .constant(nil))
}

