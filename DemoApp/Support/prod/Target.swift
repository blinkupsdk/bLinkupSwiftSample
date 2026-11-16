//
//  Target.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import bLinkupSDK
import UIKit

enum Target {
    static let currentCustomers = [
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
        AppCustomer(cid: "sixers-local-demo",
                    name: "Philadelphia 76ers 🏀"),
        AppCustomer(cid: "philadelphia-76ers-local-demo",
                    name: "Philadelphia 76ers V2 🏀"),
        AppCustomer(cid: "arizona-state-sun-devils-local-demo",
                    name: "Arizona State Sun Devils 🏈"),
        AppCustomer(cid: "new-york-knicks-local-demo",
                    name: "New York Knicks x Michelob ULTRA 🏀"),
        AppCustomer(cid: "los-angeles-lakers-local-demo",
                    name: "Los Angeles Lakers x Michelob ULTRA 🏀"),
        AppCustomer(cid: "colorado-avalanche-local-demo",
                    name: "Colorado Avalanche V2 🏒"),
        AppCustomer(cid: "team-canada-local-demo",
                    name: "Team Canada V2 🍁"),
        AppCustomer(cid: "charlotte-hornets-local-demo",
                    name: "Charlotte Hornets V2 🏀"),
        AppCustomer(cid: "carolina-hurricanes-local-demo",
                    name: "Carolina Hurricanes 🏒"),
        AppCustomer(cid: "rb-leipzig-local-demo",
                    name: "RB Leipzig V2 ⚽"),
        AppCustomer(cid: "meetup-local-demo",
                    name: "Meet Up — Website Demo 🎬"),
        AppCustomer(cid: "houston-texans-local-demo",
                    name: "Houston Texans V2 🏈"),
        AppCustomer(cid: "miami-dolphins-local-demo",
                    name: "Miami Dolphins V2 🏈"),
        AppCustomer(cid: "milwaukee-bucks-local-demo",
                    name: "Milwaukee Bucks V2 🏀"),
        AppCustomer(cid: "matchday-dallas-local-demo",
                    name: "MATCHDAY Rewards · Dallas 🏓"),
        AppCustomer(cid: "marquette-golden-eagles-local-demo",
                    name: "Marquette Golden Eagles V2 🏀"),
        AppCustomer(cid: "michigan-wolverines-local-demo",
                    name: "Michigan Wolverines V2 🏈"),
        AppCustomer(cid: "new-york-red-bulls-local-demo",
                    name: "New York Red Bulls V2 ⚽"),
        AppCustomer(cid: "portland-trail-blazers-local-demo",
                    name: "Portland Trail Blazers 🏀"),
        AppCustomer(cid: "new-york-giants-local-demo",
                    name: "New York Giants x Modelo 🏈"),
        AppCustomer(cid: "cleveland-browns-local-demo",
                    name: "Cleveland Browns x Bud Light 🏈"),
        AppCustomer(cid: "baltimore-ravens-local-demo",
                    name: "Baltimore Ravens 🏈"),
        AppCustomer(cid: "seattle-seahawks-local-demo",
                    name: "Seattle Seahawks 🏈"),
        AppCustomer(cid: "philadelphia-flyers-local-demo",
                    name: "Philadelphia Flyers x Yuengling 🏒"),
        AppCustomer(cid: "brooklyn-nets-local-demo",
                    name: "Brooklyn Nets x Juan, Please 🏀"),
        AppCustomer(cid: "los-angeles-kings-local-demo",
                    name: "LA Kings V2 🏒"),
        AppCustomer(cid: "boston-legacy-fc-local-demo",
                    name: "Boston Legacy FC V2 ⚽"),
        AppCustomer(cid: "eugene-local-demo",
                    name: "Ravens Demo Eugene 🦅"),
    ]

    static let legacyCustomers = [
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

    static let customers = currentCustomers + legacyCustomers

    static var hosts = [
        "https://blinkup.fly.dev/api/",
    ]
}
