//
//  AppCustomer.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13/11/2024.
//

import bLinkupSDK
import SwiftUI

struct AppCustomer: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    let cid: String
    var name: String?
    var primary: String?
    var secondary: String?
    var logo: String?
    var font: String?
    var group: String?
    
    func asBlinkupCustomer() -> Customer {
        Customer(id: cid, name: name)
    }
    
    func asBlinkupBranding() -> Branding {
        Branding(primaryHEX: primary,
                 secondaryHEX: secondary,
                 fontName: font,
                 logo: logo,
                 name: name)
    }
}
