//
//  Target.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import bLinkup
import UIKit

enum Target {
    static let customers = [
        Customer(id: "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=", name: "Chicago Demo"),
        Customer(id: "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=", name: "Milwaukee Bucks"),
        Customer(id: "iqPbaubl_9FtQTTBGrueAdom0TnlSbTPZO675ZLQS1o=", name: "Charlotte Hornets"),
        Customer(id: "uzU20c9Zs6_-Sn3o_lv9jrPM4kZeH5nnnn05iNfc1FE=", name: "Atlanta Braves"),
        Customer(id: "ssD1qVnNw1KFPT3eFFtquHiSo0qlZzcK783Kwku9xWU=", name: "Clemson Tigers"),
        Customer(id: "7x1oDfFEpUj4LVIzz8XSskomH5dINsRZmLY6XZSfPvE=", name: "Test"),
    ]
    
    static func branding(for c: Customer) -> Branding {
        switch c.id {
        case "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=": //"Chicago Demo"
            return .init(primary: UIColor(red: 0, green: 0.14, blue: 0.3, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoDemo",
                         name: c.name)
        case "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=": //Milwaukee Bucks
            return .init(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "AmericanTypewriter",
                         logo: "logoMilwaukee",
                         name: c.name)
        case "iqPbaubl_9FtQTTBGrueAdom0TnlSbTPZO675ZLQS1o=": //Charlotte Hornets"
            return .init(primary: UIColor(red: 0, green: 0.54, blue: 0.64, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "GillSans",
                         logo: "logoHornets",
                         name: c.name)
        case "uzU20c9Zs6_-Sn3o_lv9jrPM4kZeH5nnnn05iNfc1FE=": //Atlanta Braves
            return .init(primary: UIColor(red: 0.75, green: 0.02, blue: 0.20, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: "HelveticaNeue",
                         logo: "logoAtlanta",
                         name: c.name)
        case "ssD1qVnNw1KFPT3eFFtquHiSo0qlZzcK783Kwku9xWU=": // Clemson Tigers
            return .init(primary: UIColor(red: 0.9, green: 0.45, blue: 0.18, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoTigers",
                         name: c.name)
        default:
            return .init(primary: UIColor(red: 0, green: 0.25, blue: 0.125, alpha: 1),
                         secondary: UIColor(red: 0.8, green: 0.05, blue: 0.2, alpha: 1),
                         fontName: nil,
                         logo: "logoDemo",
                         name: c.name)
        }
    }
}
