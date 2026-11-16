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
        AppCustomer(cid: "commanders-home-v6-local-demo",
                    name: "Commanders Connect Home v6 🏈"),
        AppCustomer(cid: "76ers-home-v6-test-local-demo",
                    name: "76ers Home v6 · user test 🧪"),
        AppCustomer(cid: "76ers-home-v6-local-demo",
                    name: "76ers Home v6 (the mix) 🏀"),
        AppCustomer(cid: "seattle-seahawks-local-demo",
                    name: "Seattle Seahawks 🏈"),
        AppCustomer(cid: "baltimore-ravens-local-demo",
                    name: "Baltimore Ravens 🏈"),
        AppCustomer(cid: "prodref-local-demo",
                    name: "🏗️ Production Reference (WIP)"),
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
        AppCustomer(cid: "philadelphia-flyers-local-demo",
                    name: "Philadelphia Flyers x Yuengling 🏒"),
        AppCustomer(cid: "brooklyn-nets-local-demo",
                    name: "Brooklyn Nets x Juan, Please 🏀"),
        AppCustomer(cid: "denver-nuggets-local-demo",
                    name: "Denver Nuggets x Miller Lite 🏀"),
        AppCustomer(cid: "los-angeles-kings-local-demo",
                    name: "LA Kings V2 🏒"),
        AppCustomer(cid: "boston-legacy-fc-local-demo",
                    name: "Boston Legacy FC V2 ⚽"),
    ]

    #if PARTNER_DEMO
    /// The only demos a partner build (DemoAppPartner, com.blinktech.partnerdemo) lists.
    /// Order is the order shown. Names here must read clean for a first-time viewer — no
    /// "V2", no internal labels. Everything else in this file is hidden in that build.
    static let partnerCustomers: [AppCustomer] = [
        AppCustomer(cid: "carolina-hurricanes-local-demo",
                    name: "Carolina Hurricanes"),
        AppCustomer(cid: "portland-trail-blazers-local-demo",
                    name: "Portland Trail Blazers"),
        AppCustomer(cid: "matchday-dallas-local-demo",
                    name: "MATCHDAY Rewards · Dallas"),
    ]
    #endif

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
