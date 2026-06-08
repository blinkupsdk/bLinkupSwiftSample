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
    static let customers = [
        AppCustomer(cid: "TkPnD3_yP3j6dUEAksgRjJ-auYijyUECLxVEnFqHJVE=",
                    name: "Demo"),
        AppCustomer(cid: "wvu-local-demo",
                    name: "West Virginia University 🏟️"),

        AppCustomer(cid: "boty-local-demo",
                    name: "Back of the Yards Coffee ☕"),
        AppCustomer(cid: "sbux-local-demo",
                    name: "Starbucks ☕"),
        AppCustomer(cid: "ravens-local-demo",
                    name: "Baltimore Ravens 🦅"),
        AppCustomer(cid: "ravens2-local-demo",
                    name: "Ravens V2 🦅"),
        AppCustomer(cid: "chargers2-local-demo",
                    name: "LA Chargers ⚡"),
        AppCustomer(cid: "commanders2-local-demo",
                    name: "Washington Commanders 🏈"),
        AppCustomer(cid: "ravens-bl-local-demo",
                    name: "Ravens x Bud Light 🍺"),
        AppCustomer(cid: "ravens-mobbin-local-demo",
                    name: "Test This One ✅"),
        AppCustomer(cid: "bucks-local-demo",
                    name: "Milwaukee Bucks x Michelob ULTRA 🏀"),
        AppCustomer(cid: "76ers-local-demo",
                    name: "Philadelphia 76ers 🏀"),
        AppCustomer(cid: "sixers-local-demo",
                    name: "Philadelphia 76ers 🏀"),
        AppCustomer(cid: "eugene-local-demo",
                    name: "Ravens Demo Eugene 🦅"),
//        AppCustomer(cid: "wWephArCWZ3bCkvizZ5dTnaUrn_YhZ0h8pEUnMM2Cf8=",
//                    name: "Scrut.io /Maxim"),
//        AppCustomer(cid: "Fo5TH-WjHh4THu1ges-EzCrWs-oRrzEu-20cOVOc0oE=",
//                    name: "DePaul /Maxim")
    ]
    
    static var hosts = [
        "https://blinkup-staging.fly.dev/api/",
        "http://dev01.mobilauto.com.ua:4000/api/",
    ]
}
