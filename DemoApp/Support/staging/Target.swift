//
//  Target.swift
//  DemoAppSTG
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import Foundation

import bLinkupSDK
import UIKit

enum Target {
    static let currentCustomers: [AppCustomer] = [
        AppCustomer(cid: "ravens-mobbin-local-demo",
                    name: "Ravens Meet Up (Local) ✅"),
        AppCustomer(cid: "TkPnD3_yP3j6dUEAksgRjJ-auYijyUECLxVEnFqHJVE=",
                    name: "Demo"),
        AppCustomer(cid: "aJOqtaqHfIhnMn9xzcEgMC_vN9_WXWKpsTtOn04DEAU=",
                    name: "Internal")
    ]

    static let legacyCustomers: [AppCustomer] = []

    static let customers = currentCustomers + legacyCustomers
    
    static var hosts = [
        "https://blinkup-staging.fly.dev/api/",
        "http://dev01.mobilauto.com.ua:4000/api/",
    ]
}
