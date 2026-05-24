//
//  Target.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import bLinkupSDK
import UIKit

enum Target {
    static let customers = [
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
        AppCustomer(cid: "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=",
                    name: "Test",
                    primary: "004020",
                    secondary: "CC0D33",
                    logo: "logoDemo",
                    font: "AmericanTypewriter"),
        AppCustomer(cid: "h9AQnvY33HmMLhYD88lyFFcrp4WqjhW-2PVwlmzo6kE=",
                    name: "West Virginia University"),
        AppCustomer(cid: "Mb9QPCopsCNBr8QI8jAZ0qqUWrAXIMCgkr_PuvaUY08=",
                    name: "HOCR"),
        AppCustomer(cid: "845hxVpXeRyfJ2IlVfF6fNSNfUU3w0V3W1VZ0R6bhlI=",
                    name: "Marquette University"),
        AppCustomer(cid: "cXeF3FiXlOrybzxjYbpV025tj4xg2Y-utetNd1VNAM8=",
                    name: "DePaul University"),
        AppCustomer(cid: "J0xpNvE6i7wT4j41ZuXT2efA21ZgKbmm85Q_rF0-i6s=",
                    name: "Philadelphia 76ers"),
        AppCustomer(cid: "blXZyvR8f2s54U948MuU9rSxeinYE1G1sYGq0V2P0GM=",
                    name: "Scrut.io",
                    logo: "logoDemo"),
    ]
    
    static var hosts = [
        "https://blinkup.fly.dev/api/",
    ]
}
