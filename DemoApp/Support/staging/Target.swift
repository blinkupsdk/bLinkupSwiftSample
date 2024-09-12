//
//  Target.swift
//  DemoAppSTG
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import Foundation

import bLinkup
import UIKit

enum Target {
    static let customers = [
        Customer(id: "CzWgbh_Y0-Lod0VCjhwkiIDt5y3QxLLcoy0FcEDoc9E=", name: "STG-Test"),
    ]
    
    static func branding(for c: Customer) -> Branding {
        switch c.id {
        case "CzWgbh_Y0-Lod0VCjhwkiIDt5y3QxLLcoy0FcEDoc9E=": // Staging
            return Branding(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                            secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                            fontName: "AmericanTypewriter",
                            logo: "logoMilwaukee",
                            name: c.name)
        default:
            return Branding(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                            secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                            fontName: nil,
                            logo: "logoDemo",
                            name: c.name)
        }
    }
}
