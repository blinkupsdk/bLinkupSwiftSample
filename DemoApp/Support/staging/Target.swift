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
    static let currentCustomers = [
        AppCustomer(cid: "ravens-mobbin-local-demo",
                    name: "Test This One ✅"),
        AppCustomer(cid: "76ers-local-demo",
                    name: "Philadelphia 76ers 🏀"),
        AppCustomer(cid: "sabres-local-demo",
                    name: "Buffalo Sabres 🏒"),
        AppCustomer(cid: "bucks-local-demo",
                    name: "Milwaukee Bucks x Michelob ULTRA 🏀"),
        AppCustomer(cid: "chargers2-local-demo",
                    name: "LA Chargers ⚡"),
        AppCustomer(cid: "commanders2-local-demo",
                    name: "Washington Commanders 🏈"),
        AppCustomer(cid: "cavs-local-demo",
                    name: "Cleveland Cavaliers 🏀"),
    ]

    static let legacyCustomers = [
        AppCustomer(cid: "ravens-local-demo",
                    name: "Baltimore Ravens 🦅"),
        AppCustomer(cid: "ravens2-local-demo",
                    name: "Ravens V2 🦅"),
        AppCustomer(cid: "ravens-bl-local-demo",
                    name: "Ravens x Bud Light 🍺"),
        AppCustomer(cid: "sixers-local-demo",
                    name: "Philadelphia 76ers (Old) 🏀"),
        AppCustomer(cid: "eugene-local-demo",
                    name: "Ravens Demo Eugene 🦅"),
        AppCustomer(cid: "wvu-local-demo",
                    name: "West Virginia University 🏟️"),
        AppCustomer(cid: "boty-local-demo",
                    name: "Back of the Yards Coffee ☕"),
        AppCustomer(cid: "sbux-local-demo",
                    name: "Starbucks ☕"),
        AppCustomer(cid: "TkPnD3_yP3j6dUEAksgRjJ-auYijyUECLxVEnFqHJVE=",
                    name: "Demo"),
    ]

    static let customers = currentCustomers + legacyCustomers
    
    static var hosts = [
        "https://blinkup-staging.fly.dev/api/",
        "http://dev01.mobilauto.com.ua:4000/api/",
    ]
}
