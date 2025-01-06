//
//  AppCustomer.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13/11/2024.
//

import bLinkup
import SwiftUI

struct AppCustomer: Codable, Identifiable, Equatable {
    let id: String
    var name: String?
    var primary: String?
    var secondary: String?
    var logo: String?
    var font: String?

    func asBlinkupCustomer() -> Customer {
        Customer(id: id, name: name)
    }
    
    func asBlinkupBranding() -> Branding {
        Branding(primary: UIColor(hex: primary ?? ""),
                 secondary: UIColor(hex: primary ?? ""),
                 fontName: font,
                 logo: logo,
                 name: name)
    }
}
