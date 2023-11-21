//
//  MapView.swift
//  DemoApp
//
//  Created by Surielis Rodriguez on 11/20/23.
//

import SwiftUI

import bLinkup
import SwiftUI

struct MapView: View {
    @Binding var isLoggedIn: Bool
    

    var body: some View {
        ZStack {
            Form {

            }
            .accentColor(.blBlue)
        }
        .navigationTitle("Map")
    }
}

#Preview {
    MapView(isLoggedIn: .constant(true))
}
