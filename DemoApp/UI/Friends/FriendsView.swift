//
//  FriendsView.swift
//  DemoApp
//
//  Created by Surielis Rodriguez on 11/20/23.
//

import SwiftUI

import bLinkup
import SwiftUI

struct FriendsView: View {
    @Binding var isLoggedIn: Bool
    

    var body: some View {
        ZStack {
            Form {

            }
            .accentColor(.blBlue)
        }
        .navigationTitle("Friends")
    }
}

#Preview {
    FriendsView(isLoggedIn: .constant(true))
}
