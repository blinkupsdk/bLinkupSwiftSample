//
//  ContentView.swift
//  DemoApp
//
//  Created on 30.10.2023.
//

import SwiftUI
import bLinkup

struct ContentView: View {

    @State var isLoggedIn: Bool
    
    init(isLoggedIn: Bool? = nil) {
        self.isLoggedIn = isLoggedIn ?? !bLinkup.isLoginRequired
    }
  
    var body: some View {
        switch isLoggedIn {
        case false:
            StartView(isLoggedIn: $isLoggedIn)
        case true:
            TabbarView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView(isLoggedIn: false)
}

