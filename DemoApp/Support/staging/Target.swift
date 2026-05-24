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
