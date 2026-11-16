//
//  SixersHomeV6Demo.swift
//  DemoApp
//
//  The 76ers Meet Up home "v6 · the mix": today's app with only the picked changes —
//  the points card, How are you watching?, How to earn points and a few updated cards.
//  Everything else follows the current UI. All data is local; nothing calls the API.
//

import MapKit
import SwiftUI
import UIKit

// MARK: - Look

private enum V6 {
    static let brand = Color(red: 1 / 255, green: 60 / 255, blue: 167 / 255)
    static let brand10 = Color(red: 1 / 255, green: 60 / 255, blue: 167 / 255).opacity(0.10)
    static let strip = Color(red: 10 / 255, green: 31 / 255, blue: 102 / 255)
    static let gray = Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255)
    static let hair = Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255)
    static let ink = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    static let ink2 = Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255)
    static let ok = Color(red: 36 / 255, green: 138 / 255, blue: 61 / 255)
    static let green = Color(red: 60 / 255, green: 165 / 255, blue: 72 / 255)
    static let gold = Color(red: 246 / 255, green: 196 / 255, blue: 69 / 255)
    static let pin = Color(red: 239 / 255, green: 159 / 255, blue: 52 / 255)
    static let on2 = Color.white.opacity(0.82)
    static let navGradient = LinearGradient(colors: [Color(red: 26 / 255, green: 85 / 255, blue: 201 / 255),
                                                     Color(red: 1 / 255, green: 7 / 255, blue: 203 / 255),
                                                     Color(red: 16 / 255, green: 0, blue: 163 / 255)],
                                            startPoint: .leading, endPoint: .trailing)
}

private extension Font {
    static let v6t24 = Font.system(size: 24, weight: .bold)
    static let v6t22 = Font.system(size: 22, weight: .bold)
    static let v6t17 = Font.system(size: 17, weight: .bold)
    static let v6t13b = Font.system(size: 13, weight: .bold)
    static let v6t13 = Font.system(size: 13)
}

// MARK: - Data (real 76ers Meet Up bars, deals and points; fan statuses, store items and counts are examples)

private struct V6Venue {
    let kind: V6Model.Mode
    let name: String
    let mi: String
    let deal: String
    let pts: Int
    let botg: Bool
}

private struct V6Bar: Identifiable {
    let id: String
    let name: String
    let address: String
    let deal: String
    let coordinate: CLLocationCoordinate2D
}

private struct V6Item: Identifiable {
    var id: String { name }
    let name: String
    let price: Int
    let symbol: String
}

private enum V6Data {
    static let venues: [String: V6Venue] = [
        "botg": V6Venue(kind: .bar, name: "O'Neals Pub", mi: "2.6", deal: "$3.50 for One Mystery Beer", pts: 700, botg: true),
        "close": V6Venue(kind: .bar, name: "Garage Fishtown", mi: "0.3", deal: "$5 for One Corona & Koozie", pts: 350, botg: false),
        "arena": V6Venue(kind: .arena, name: "Xfinity Mobile Arena", mi: "5.1", deal: "$2 Off Any Draft Beer", pts: 500, botg: false),
        "home": V6Venue(kind: .home, name: "Home Watch Party", mi: "", deal: "", pts: 250, botg: false)
    ]
    static let bars = [
        V6Bar(id: "close", name: "Garage Fishtown", address: "100 E Girard Ave, Philadelphia, PA 19125",
              deal: "$5 for One Corona & Koozie", coordinate: .init(latitude: 39.9690, longitude: -75.1340)),
        V6Bar(id: "mor", name: "Moriarty's", address: "1116 Walnut St, Philadelphia, PA 19107",
              deal: "$20 for 5 Wings & a Draft Beer", coordinate: .init(latitude: 39.9487, longitude: -75.1601)),
        V6Bar(id: "botg", name: "O'Neals Pub", address: "611 S 3rd St, Philadelphia, PA 19147",
              deal: "$3.50 for One Mystery Beer", coordinate: .init(latitude: 39.9412, longitude: -75.1478))
    ]
    // Bar Duel (Will, 11-15): two bars, the one with more check-ins tonight wins and every fan checked in there gets a bonus
    static let duel = ["botg", "close"]
    static let duelBonus = 200
    static let duelBarPrize = "a framed 76ers jersey"   // what the winning bar itself takes home (example)
    static let store = [
        V6Item(name: "Rally towel", price: 1000, symbol: "flag"),
        V6Item(name: "Sixers tee", price: 2000, symbol: "tshirt"),
        V6Item(name: "Signed mini ball", price: 4000, symbol: "basketball")
    ]
    static let tiers: [(name: String, min: Int)] = [("Rookie", 0), ("Fan", 500), ("Super Fan", 2000), ("Die-Hard", 5000), ("Hall of Famer", 10000)]
    // how rare each fan status is, so it means something
    static let tierShare = ["Every fan starts here", "Top 41% of fans", "Top 12% of fans", "Top 3% of fans", "Top 0.4% of fans"]
    static let titleRewards = [
        V6TitleReward(tier: 1, name: "Rally towel", symbol: "flag", total: 500, left: 212, pickup: true),
        V6TitleReward(tier: 2, name: "Sixers tee", symbol: "tshirt", total: 200, left: 37, pickup: false),
        V6TitleReward(tier: 3, name: "Signed mini ball", symbol: "basketball", total: 25, left: 9, pickup: false),
        V6TitleReward(tier: 4, name: "Signed jersey", symbol: "star.square", total: 5, left: 2, pickup: false)
    ]
    // everyone else on the leaderboard; your rank is where your points land in this list
    static let field: [(name: String, pts: Int)] = [("Spencer K.", 8450), ("Keanu P.", 7900), ("Lisa M.", 7350), ("Tom B.", 6100), ("Ana R.", 5200),
                                                    ("Chris D.", 4400), ("Maria L.", 3700), ("Kev O.", 3050), ("Dre W.", 2640), ("Mike R.", 2360),
                                                    ("Jess T.", 1920), ("Sam K.", 1725), ("Lena P.", 1610)]
    static let prize = "Exclusive 76ers Fan Gear"
    // the season's grand prize, one name everywhere (home card, Season Rewards, leaderboard, welcome)
    static let grandPrize = "2 tickets + $100 F&B credit"
    static let seasonEnds = "Apr 12"
    static let base = 1800
    static let fanCount = 1152          // the 76ers' real sign-ups, Nov 11
    static let rankFirstCutoff = 25     // auto card: rank first from here up
    static let signUpBonus = 150        // a fan with only this has never checked in, so has no real rank
    // a typical fan who has been to two games: sign-up bonus + two bar check-ins, somewhere in the middle
    static let typicalFan = V6Persona(points: 850, rank: 412, next: (name: "Nina K.", pts: 1000), floor: 700)
    static let unlockNote = "Reach a status to unlock its reward, while supplies last. Your status only goes up."

    // Starting Five (example fans): each bar's fans by visits this season, most first; equal counts are already in the order they got there
    static let starterFloor = 2          // visits a fan needs before taking a spot
    static let barFans: [String: [(name: String, visits: Int)]] = [
        "botg": [("Mike R.", 14), ("Dana K.", 11), ("Mystery Fan", 9), ("Jo P.", 7), ("Chris M.", 5), ("Nina K.", 4), ("Rob T.", 3)],
        "close": [("Kev O.", 9), ("Lena P.", 8), ("Mystery Fan", 7), ("Tom B.", 6), ("Sam K.", 3), ("Gabe L.", 2)],
        "mor": [("Pat D.", 6), ("Rich S.", 4), ("Gina F.", 2)]
    ]
    static let myBarVisits = ["botg": 5, "close": 4, "mor": 0]   // Andy, before tonight
    static let barFanCount = ["botg": 38, "close": 24, "mor": 9]  // fans who have checked in at each bar this season
    // each bar sets two deals: its regular one, and a better one for its Starting Five (a starter gets it instead of the regular one)
    static let starterDeals = ["botg": "One Free Mystery Beer", "close": "Free Corona & Koozie", "mor": "Free Wings with Any Draft"]
}

// milestones (the default): each fan status unlocks its own reward, in limited numbers; the store spends points instead
private enum V6RewardsMode: String, Codable { case spend, unlock }
// what leads the points card: your own points and fan status, or your rank against other fans
// auto: rank first for the top fans, whose number is worth showing; status first for everyone else
private enum V6CardMode: String, Codable { case status, rank, auto }
// someone other than the demo fan, for the side-by-side card test
private struct V6Persona {
    let points: Int
    let rank: Int
    let next: (name: String, pts: Int)   // the fan to pass
    let floor: Int                       // the fan just behind, where the rank bar starts
}

private struct V6TitleReward: Identifiable {
    var id: Int { tier }
    let tier: Int
    let name: String
    let symbol: String
    let total: Int
    let left: Int
    let pickup: Bool
}

// MARK: - Model

@MainActor
private final class V6Model: ObservableObject {
    enum Moment: Int { case off, gameday, at, checkedIn, live, after }
    enum Mode: String, CaseIterable { case bar, arena, home }
    enum Sheet: Identifiable {
        case bar(String), prize(String), deal, notAtSpot, profile, leaderboard
        var id: String {
            switch self {
            case .bar(let k): return "bar-" + k
            case .prize(let k): return "prize-" + k
            case .deal: return "deal"
            case .notAtSpot: return "nas"
            case .profile: return "profile"
            case .leaderboard: return "leaderboard"
            }
        }
        var label: String {
            switch self {
            case .bar(let k): return "Opened bar card · " + (V6Data.bars.first { $0.id == k }?.name ?? k)
            case .prize(let k): return k == "fotg" ? "Opened Fan Gear prize" : "Opened Sixers Shop prize"
            case .deal: return "Opened deal screen"
            case .notAtSpot: return "Saw \"Get to a 76ers Meet Up Bar\""
            case .profile: return "Opened profile"
            case .leaderboard: return "Opened the leaderboard"
            }
        }
    }

    @Published var moment: Moment = .gameday
    @Published var mode: Mode = .bar
    @Published var venue = "botg"
    @Published var homeGame = true
    @Published var won = true
    // Bar Duel night (⋯ menu switches back to Bar of the Game); the final goes your bar's way unless the menu says otherwise
    @Published var duelNight = true
    @Published var duelYouWin = true
    @Published var duelScore = [23, 19]     // check-ins tonight: [O'Neals Pub, Garage Fishtown]
    @Published var duelPlus: Int?           // the side that just got your +1
    var duelTicks = 0
    @Published var finding = false
    @Published var lookingForFriends = false
    @Published var planOpen = true
    @Published var redeemed: Set<String> = []
    @Published var confirmItem: String?
    @Published var votes: [String: Int] = ["close": 18, "mor": 6, "botg": 31]
    @Published var myVotes: Set<String> = []
    @Published var displayPoints = V6Data.base
    // demo: Andy (1,800), a fan with one check-in (500), or one who just joined (150, the sign-up bonus)
    @Published var basePoints = V6Data.base { didSet { displayPoints = points } }
    @Published var levelUpTier: Int? {
        // a new fan status and a new Starting Five spot on the same check-in: the status shows first, then the five
        didSet {
            guard levelUpTier == nil, oldValue != nil, let k = pendingStarter else { return }
            pendingStarter = nil
            let e = epoch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                guard let self, e == self.epoch else { return }
                self.showStarterUp(k)
            }
        }
    }
    @Published var showShare = false
    // Starting Five
    @Published var samPassed = false        // demo: Sam K. passes Andy at Garage Fishtown
    @Published var starterUp: String?       // bar key while "You made it" shows
    @Published var showStarterShare = false
    @Published var bumpSeen = false         // the lost-spot line on the points card goes once it's opened
    @Published var dealUsed = false           // tonight's regular deal has been redeemed
    @Published var usedFive: Set<String> = []   // bars where tonight's Starting Five deal is used
    var dealFive = false                     // which deal the deal screen shows
    var pendingStarter: String?
    var focusFive = false
    @Published var showFanMessage = false
    @Published var toastText: String?
    @Published var sheet: Sheet? {
        didSet {
            guard let s = sheet, s.id != oldValue?.id else { return }
            if case .deal = s { sawDeal = true }
            track(s.label)
        }
    }
    @Published var scrollTarget: String?
    @Published var tipoff = Date().addingTimeInterval(2991)
    @Published var drawAt = Date().addingTimeInterval(10152)

    // user test: what the tester tapped, and whether each task's goal was reached
    @Published var testMode = false
    @Published var trail: [String] = []
    @Published var showWelcome = false
    @Published var showSeason = false
    var seasonAnchor: String?
    @Published var rewardsMode: V6RewardsMode = .unlock
    @Published var cardMode: V6CardMode = .auto
    @Published var claimedRewards: Set<Int> = []
    @Published var askLocation = false

    var rewardToClaim: V6TitleReward? { V6Data.titleRewards.first { $0.tier <= tierIndex(points) && !claimedRewards.contains($0.tier) } }
    var nextTitleReward: V6TitleReward? { V6Data.titleRewards.first { $0.tier > tierIndex(points) } }
    // at a regular Meet Up bar's 350 points a visit
    func checkInsTo(_ tier: Int) -> Int { max(1, Int((Double(V6Data.tiers[tier].min - points) / 350).rounded(.up))) }

    func claimTitleReward(_ r: V6TitleReward) {
        claimedRewards.insert(r.tier)
        track("Claimed season reward · \(r.name)")
        toast(r.pickup ? "Claimed! Pick it up at any Meet Up bar on game night" : "Claimed! Opens the shipping form")
    }
    var claimed = false, openedSeason = false, sawDeal = false, welcomeDone = false
    var directionsTo: String?
    // bumped on every reset so delayed animations from an earlier run don't land in the next one
    private var epoch = 0

    func track(_ step: String) { if testMode { trail.append(step) } }

    var settled: Bool { [.checkedIn, .live, .after].contains(moment) }
    // the greeting follows the night (Will, 11-15): a brand-new account still gets "Welcome" until it checks in
    // only the first "Welcome, Andy" right after sign-up (Will, 11-15): elsewhere the greeting repeated what the strip,
    // the picker or YOU WON already say, and took a line above the check-in, the deal and the points
    // and not once you're detected (Will, 11-15): the check-in is the first thing on the page then
    var greeting: String? { welcomeDone && !arrived ? "Welcome, Andy" : nil }
    // tonight's (or tomorrow's) game, by name, and the one after it (example opponents)
    var gameName: String { homeGame ? "76ers vs. Knicks" : "76ers at Knicks" }
    var gameWhen: String { moment == .off ? "Tomorrow · 7:00 PM" : "Tonight · 7:30 PM" }
    let nextGame = "Next game Sun 6:00 PM"
    // the featured card (Bar of the Game, or the arena on an arena pick) shows until you're checked in
    var featuredUp: Bool { !settled && shownMode != .home && !(moment == .at && (shownMode == .arena || venue == "botg")) }
    // while the Bar of the Game card is up, that bar isn't repeated in the bar list
    var botgCardUp: Bool { featuredUp && shownMode == .bar && !duelNight }
    // the duel card replaces Bar of the Game for bar fans and stays up all night (the score is the point), final included
    var duelUp: Bool { duelNight && shownMode == .bar }
    // checked in (Will, 11-15): the section under the points card is just the deal left to redeem; once it's used it goes away
    // one deal per bar for everyone, Starting Five included (Will, 11-15: hard to get two deals from every bar; starters get other rewards)
    var dealLeft: Bool { settled && moment != .after && v.kind != .home && !dealUsed }
    var planUp: Bool { !settled || moment == .after || dealLeft }
    // your side: the duel bar you're at (detected or checked in)
    var duelSide: Int? { arrived ? V6Data.duel.firstIndex(of: venue) : nil }
    var duelWinner: Int? { moment == .after ? (duelScore[0] > duelScore[1] ? 0 : 1) : nil }
    var duelBonus: Int { duelNight && settled && duelSide != nil && duelSide == duelWinner ? V6Data.duelBonus : 0 }
    var arrived: Bool { moment == .at || settled }
    var v: V6Venue { venueInfo(venue) }
    // duel night has no Bar of the Game, so O'Neals is a regular +350 bar
    func venueInfo(_ k: String) -> V6Venue {
        let x = V6Data.venues[k]!
        // duel night: both duel bars are 2x, like Bar of the Game (Will, 11-15: "join the bar duel - 700 points")
        guard duelNight, V6Data.duel.contains(k) else { return x }
        return V6Venue(kind: x.kind, name: x.name, mi: x.mi, deal: x.deal, pts: 700, botg: true)
    }
    var shownMode: Mode { arrived ? v.kind : mode }
    var points: Int { settled ? basePoints + v.pts + duelBonus : basePoints }
    var rank: Int { rankFor(points) }
    // the named leaderboard is only the top; below it the rank is an estimate between known points
    // (one check-in = 500 ≈ #472, the top 41%), and a fan with only the sign-up bonus isn't ranked yet
    func rankFor(_ p: Int) -> Int {
        let low = V6Data.field.last!.pts, named = V6Data.field.count + 1
        if p >= low { return V6Data.field.filter { $0.pts > p }.count + 1 }
        if p >= 500 { return 472 - Int(Double(p - 500) / Double(low - 500) * Double(472 - named)) }
        let b = V6Data.signUpBonus
        return V6Data.fanCount - Int(Double(max(0, p - b)) / Double(500 - b) * Double(V6Data.fanCount - 472))
    }
    func isRanked(_ p: Int) -> Bool { p > V6Data.signUpBonus }
    var inNamedBoard: Bool { points >= V6Data.field.last!.pts }
    // whether a fan's rank is worth leading with: always for "rank", never for "status", top fans only for "auto"
    func leadsWithRank(_ mode: V6CardMode, points p: Int, rank r: Int) -> Bool {
        (mode == .rank || (mode == .auto && r <= V6Data.rankFirstCutoff)) && p > V6Data.signUpBonus
    }
    var fanAbove: (name: String, pts: Int)? { V6Data.field.last { $0.pts > points } }
    var fanBelow: (name: String, pts: Int)? { V6Data.field.first { $0.pts <= points } }
    var spent: Int { V6Data.store.filter { redeemed.contains($0.name) }.reduce(0) { $0 + $1.price } }
    var available: Int { max(0, points - spent) }
    func tierIndex(_ p: Int) -> Int { V6Data.tiers.lastIndex { p >= $0.min } ?? 0 }

    // MARK: Starting Five: each bar's top fans by visits (one per game), ties to whoever got there first
    struct FiveRow { let name: String; let visits: Int; let you: Bool }
    func barName(_ k: String) -> String { V6Data.bars.first { $0.id == k }?.name ?? k }
    // past visits follow the demo fan: Andy's history, one earlier check-in at Garage Fishtown (500 pts), or none (just joined)
    func myVisits(_ k: String) -> Int {
        let past = basePoints >= V6Data.base ? (V6Data.myBarVisits[k] ?? 0) : basePoints > V6Data.signUpBonus ? (k == "close" ? 1 : 0) : 0
        return past + (settled && venue == k ? 1 : 0)
    }
    // everyone at a bar, you included, most visits first; you reached your count last, so you go after anyone level with you
    func lineup(_ k: String) -> [FiveRow] {
        let others = (V6Data.barFans[k] ?? []).enumerated()
            .map { i, f in (row: FiveRow(name: f.name, visits: samPassed && k == "close" && f.name == "Sam K." ? 5 : f.visits, you: false), i: i) }
            .sorted { $0.row.visits != $1.row.visits ? $0.row.visits > $1.row.visits : $0.i < $1.i }
            .map(\.row)
        let mine = myVisits(k)
        var all = others
        all.insert(FiveRow(name: "You", visits: mine, you: true), at: others.firstIndex { $0.visits < mine } ?? others.count)
        return all
    }
    // only fans with 2+ visits take a spot; fewer than five of them leaves open spots
    func ranked(_ k: String) -> [FiveRow] { lineup(k).filter { $0.visits >= V6Data.starterFloor } }
    func fiveRank(_ k: String) -> Int? { ranked(k).firstIndex { $0.you }.map { $0 + 1 } }
    func isStarter(_ k: String) -> Bool { (fiveRank(k) ?? 99) <= 5 }
    var starterBars: [String] { V6Data.bars.map(\.id).filter { isStarter($0) }.sorted { (fiveRank($0) ?? 9) < (fiveRank($1) ?? 9) } }
    func starterBar(of name: String) -> String? { V6Data.bars.first { b in ranked(b.id).prefix(5).contains { !$0.you && $0.name == name } }?.name }
    // a starter gets both of the bar's deals: the regular one everyone gets, and the Starting Five one
    func starterDeal(_ k: String) -> String { V6Data.starterDeals[k] ?? "" }
    func showDeal(five: Bool) { dealFive = five; sheet = .deal }
    // visits it takes to get a spot: pass the #5 fan (a tie goes to them), or reach 2 visits when a spot is open
    func visitsToFive(_ k: String) -> Int {
        let others = ranked(k).filter { !$0.you }, floorNeed = max(0, V6Data.starterFloor - myVisits(k))
        guard others.count >= 5 else { return max(1, floorNeed) }
        return max(floorNeed, others[4].visits - myVisits(k) + 1)
    }

    func showStarterUp(_ k: String) {
        starterUp = k
        track("Made the Starting Five · \(barName(k))")
    }

    // demo: another fan passes Andy at Garage Fishtown; the points card tells him (we can't count on a push from the team's app)
    func passAndy() {
        guard !samPassed else { samPassed = false; return }
        let was = isStarter("close")
        samPassed = true
        bumpSeen = false
        track("Sam K. passed Andy at Garage Fishtown")
        if was && !isStarter("close") { scrollTarget = "top" } else { toast("Sam K. passed you at Garage Fishtown") }
    }
    // shows under the points until it's opened, or until the fan gets the spot back
    var lostSpot: Bool { samPassed && !bumpSeen && !isStarter("close") }

    func openBump() {
        bumpSeen = true
        track("Tapped the lost-spot line")
        focusFive = true
        sheet = .bar("close")
    }

    func setMoment(_ m: Moment) {
        moment = m
        if m != .checkedIn { seedDuel() }   // checking in adds your +1 to the board instead
        confirmItem = nil
        planOpen = m != .after
        displayPoints = points
        switch m {
        case .off: tipoff = Date().addingTimeInterval(92502); drawAt = Date().addingTimeInterval(99702)
        case .live: drawAt = Date().addingTimeInterval(272)
        case .checkedIn: tipoff = Date().addingTimeInterval(2690); drawAt = Date().addingTimeInterval(9850)
        default: tipoff = Date().addingTimeInterval(2991); drawAt = Date().addingTimeInterval(10152)
        }
    }

    // where the duel stands at each point of the night (examples); your own check-in is already on the board once you're in
    func seedDuel() {
        duelTicks = 0; duelPlus = nil
        var s: [Int]
        switch moment {
        case .off: s = [0, 0]
        case .gameday, .at: s = [23, 19]
        case .checkedIn: s = [27, 24]
        case .live: s = [46, 44]
        case .after:
            let mine = duelSide ?? 1, win = duelYouWin ? mine : 1 - mine
            s = [0, 0]; s[win] = 66; s[1 - win] = 61
        }
        if settled && moment != .after, let i = duelSide { s[i] += 1 }
        duelScore = s
    }
    // the board keeps moving until the final: other fans checking in, the trailing bar a bit more often so it stays close
    func tickDuel() {
        guard duelNight, [.gameday, .at, .checkedIn, .live].contains(moment), duelTicks < 24, !testMode else { return }
        duelTicks += 1
        let trailing = duelScore[0] <= duelScore[1] ? 0 : 1
        let side = Double.random(in: 0...1) < 0.6 ? trailing : 1 - trailing
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { duelScore[side] += 1 }
    }

    func reset() {
        epoch += 1
        finding = false; lookingForFriends = false; askLocation = false
        pendingStarter = nil; starterUp = nil; showStarterShare = false; bumpSeen = false; samPassed = false; usedFive = []
        claimedRewards = []
        mode = .bar; venue = "botg"; redeemed = []; myVotes = []; won = true; homeGame = true; dealUsed = false
        setMoment(.gameday)
        scrollTarget = "top"
    }

    // demo: open as a fan who is already at a spot — the app has found them, and checking in is one tap
    func detect(at k: String) {
        reset()
        venue = k
        mode = k == "arena" ? .arena : .bar
        setMoment(.at)
        scrollTarget = "top"
        track("Demo: detected at \(v.name)")
    }

    func toast(_ text: String) {
        toastText = text
        track("Message: \(text)")
        let current = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            if self?.toastText == current { self?.toastText = nil }
        }
    }

    func pick(_ m: Mode) {
        track("Picked " + (m == .bar ? "At a bar" : m == .arena ? "At the arena" : "At home"))
        if m == shownMode {
            if m == .bar { scrollTarget = "bars" }
            if m == .home { scrollTarget = "hwp" }
            return
        }
        mode = m
        if moment == .at { setMoment(.gameday) }
        if m == .home { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.scrollTarget = "hwp" } }
    }

    // one way to tell the app where you are: a short search, then the spot for that pick (a home pick finds nothing)
    func find() {
        guard !finding else { return }
        guard moment == .gameday || moment == .at else { toast("Check-in opens on gameday"); return }
        track("Tapped find my spot")
        finding = true
        let e = epoch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [self] in
            guard e == epoch else { return }
            finding = false
            if moment == .at {
                if venue != "arena" { venue = venue == "botg" ? "close" : "botg"; mode = .bar }
                toast("Found you at \(v.name)")
                return
            }
            if mode == .home { sheet = .notAtSpot; return }
            venue = mode == .arena ? "arena" : "botg"
            checkIn()
            toast("You're checked in at \(v.name)")
        }
    }

    // a new account usually starts at the bar: once location is allowed the fan is detected there, and checking in is one tap
    func finishSignUp() {
        welcomeDone = true
        showWelcome = false
        guard moment == .gameday else { toast("You're all set, Andy!"); return }
        let e = epoch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [self] in
            guard e == epoch else { return }
            askLocation = true
        }
    }

    func locationAnswer(_ allowed: Bool) {
        track(allowed ? "Allowed location" : "Didn't allow location")
        guard allowed else { toast("You can still check in with \"I'm here now\""); return }
        finding = true
        let e = epoch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [self] in
            guard e == epoch else { return }
            finding = false
            guard moment == .gameday else { return }
            venue = "close"; mode = .bar
            setMoment(.at)
            scrollTarget = "top"
            track("Detected at \(v.name)")
        }
    }

    func checkIn() {
        track("Checked in · \(v.name)")
        let from = points
        let barKey = v.kind == .bar ? venue : nil
        let wasStarter = barKey.map { isStarter($0) } ?? true
        moment = .checkedIn
        setMoment(.checkedIn)
        // your check-in lands on the duel board as a +1 for your bar
        if duelNight, let i = duelSide {
            let e = epoch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard e == self.epoch else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) { self.duelScore[i] += 1; self.duelPlus = i }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { if e == self.epoch { withAnimation { self.duelPlus = nil } } }
            }
        }
        let to = points
        countUp(from: from, to: to)
        scrollTarget = "top"
        // tonight's visit took this bar's Starting Five spot
        let madeFive = barKey.flatMap { k in !wasStarter && isStarter(k) ? k : nil }
        if let k = madeFive, tierIndex(to) <= tierIndex(from) {
            let e = epoch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                guard e == self.epoch else { return }
                self.showStarterUp(k)
            }
        }
        if tierIndex(to) > tierIndex(from) {
            pendingStarter = madeFive
            let e = epoch
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                guard e == self.epoch else { return }
                self.levelUpTier = self.tierIndex(to)
                self.track("Saw new fan status: \(V6Data.tiers[self.tierIndex(to)].name)")
            }
        }
    }

    func countUp(from: Int, to: Int) {
        displayPoints = from
        let steps = 27, ep = epoch
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.033) { [weak self] in
                guard let self, self.epoch == ep else { return }
                let k = Double(i) / Double(steps), e = 1 - pow(1 - k, 3)
                self.displayPoints = from + Int(Double(to - from) * e)
            }
        }
    }

    func startParty() {
        guard moment == .gameday || moment == .at else { toast("Parties open on gameday"); return }
        track("Tapped Start a Watch Party")
        lookingForFriends = true
        let e = epoch
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [self] in
            guard e == epoch else { return }
            lookingForFriends = false
            mode = .home
            venue = "home"
            checkIn()
            toast("Maya and Dre joined My Crew")
        }
    }

    func vote(_ k: String) {
        track((myVotes.contains(k) ? "Removed upvote · " : "Upvoted · ") + (V6Data.bars.first { $0.id == k }?.name ?? k))
        if myVotes.contains(k) { myVotes.remove(k) } else { myVotes.insert(k) }
    }
    func voteCount(_ k: String) -> Int { (votes[k] ?? 0) + (myVotes.contains(k) ? 1 : 0) }
    var favorite: String { votes.keys.max { voteCount($0) < voteCount($1) } ?? "botg" }

    func redeem(_ item: V6Item) {
        track((confirmItem == item.name ? "Confirmed reward · " : "Tapped Redeem · ") + item.name)
        if confirmItem == item.name {
            redeemed.insert(item.name)
            confirmItem = nil
            toast("\(item.name) is yours · \(available.formatted()) left to use")
        } else {
            confirmItem = item.name
        }
    }

    func claim() {
        claimed = true
        toast("Opens the claim form")
    }

    func directions(_ name: String, to c: CLLocationCoordinate2D, open: OpenURLAction) {
        directionsTo = name
        track("Tapped Directions · \(name)")
        if testMode { toast("Opens Maps with directions to \(name)"); return }
        if let url = URL(string: "maps://?daddr=\(c.latitude),\(c.longitude)") { open(url) }
    }

    func openSeason(at anchor: String? = nil) {
        seasonAnchor = anchor
        openedSeason = true
        track(anchor == nil ? "Opened Season Rewards" : "Opened Season Rewards at \(anchor!)")
        showSeason = true
    }

    func closeOverlays() {
        pendingStarter = nil; starterUp = nil; showStarterShare = false
        sheet = nil; levelUpTier = nil; showShare = false; showFanMessage = false; showWelcome = false; showSeason = false; toastText = nil; askLocation = false
    }

    func startTest(_ task: V6TaskID) {
        closeOverlays()
        reset()
        claimed = false; openedSeason = false; sawDeal = false; welcomeDone = false; directionsTo = nil
        if task == .after { goSettled(.after) }
        if task == .off { setMoment(.off) }
        trail = []
    }

    func goalMet(_ task: V6TaskID) -> Bool? {
        switch task {
        case .bar: return settled && v.kind == .bar && (sawDeal || moment == .live)
        case .botg: return directionsTo == V6Data.venues["botg"]?.name
        case .arena: return settled && venue == "arena"
        case .home: return settled && venue == "home"
        case .season: return openedSeason && (rewardsMode == .unlock ? !claimedRewards.isEmpty : !redeemed.isEmpty)
        case .after: return claimed
        case .welcome: return welcomeDone && settled
        case .off, .compare, .compareTypical: return nil
        }
    }

    func goSettled(_ m: Moment) {
        if !settled { venue = mode == .arena ? "arena" : mode == .home ? "home" : "botg" }
        setMoment(m)
        scrollTarget = "top"
    }
}

// MARK: - Screen

@available(iOS 16.0, *)
struct SixersHomeV6Demo: View {
    var onClose: () -> Void
    var testMode = false
    @StateObject private var m = V6Model()
    @StateObject private var t = V6Test()

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        V6Hero().id("top")
                        V6Bands()
                    }
                    .padding(.bottom, 40)
                    .v6ScreenWidth()
                }
                .v6VerticalOnly()
                .background(V6.gray)
                .onChange(of: m.scrollTarget) { target in
                    guard let target else { return }
                    withAnimation(.easeInOut(duration: 0.5)) { proxy.scrollTo(target, anchor: .top) }
                    m.scrollTarget = nil
                }
            }
            // stands in for the iOS location prompt right after sign-up
            .alert("Allow “76ers Meet Up” to use your location?", isPresented: $m.askLocation) {
                Button("Allow Once") { m.locationAnswer(true) }
                Button("Allow While Using App") { m.locationAnswer(true) }
                Button("Don't Allow", role: .cancel) { m.locationAnswer(false) }
            } message: {
                Text("Finds the Meet Up bar you're at so you can check in.")
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                V6NavBar(onClose: testMode ? { t.backToList(m) } : onClose, showMenu: !testMode)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if testMode, let i = t.doing { V6TaskBanner(i: i) }
            }

            if let toast = m.toastText {
                Text(toast).font(.v6t13b).foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(V6.ink))
                    .padding(.top, 104)
                    .transition(.opacity)
                    .zIndex(5)
            }
            if let tier = m.levelUpTier {
                V6LevelUp(tier: tier).zIndex(6).transition(.opacity)
            }
            if m.showShare, let tier = m.levelUpTier {
                V6ShareCard(tier: tier).zIndex(7).transition(.opacity)
            }
            if let k = m.starterUp {
                V6StarterUp(key: k).zIndex(6.5).transition(.opacity)
            }
            if m.showStarterShare, let k = m.starterUp {
                V6StarterShare(key: k).zIndex(7).transition(.opacity)
            }
            if m.showFanMessage {
                V6FanMessage().zIndex(8).transition(.opacity)
            }
            if m.showSeason {
                V6SeasonPage().zIndex(4).transition(.move(edge: .trailing))
            }
            if m.showWelcome {
                V6Welcome().zIndex(9).transition(.opacity)
            }
            if testMode {
                V6TestOverlay(onClose: onClose).zIndex(20)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: m.toastText)
        .animation(.easeInOut(duration: 0.25), value: m.levelUpTier)
        .animation(.easeInOut(duration: 0.25), value: m.showShare)
        .animation(.easeInOut(duration: 0.25), value: m.starterUp)
        .animation(.easeInOut(duration: 0.25), value: m.showStarterShare)
        .animation(.easeInOut(duration: 0.25), value: m.showFanMessage)
        .animation(.easeInOut(duration: 0.25), value: m.showWelcome)
        .animation(.easeInOut(duration: 0.3), value: m.showSeason)
        .sheet(item: $m.sheet) { sheet in
            Group {
                switch sheet {
                case .bar(let k): V6BarCard(key: k)
                case .prize(let id): V6PrizeDetail(id: id)
                case .deal: V6DealSheet()
                case .notAtSpot: V6NotAtSpot()
                case .profile: V6Profile()
                case .leaderboard: V6Leaderboard()
                }
            }
            .environmentObject(m)
        }
        .environmentObject(m)
        .environmentObject(t)
        .animation(.easeInOut(duration: 0.2), value: t.phase)
        .onAppear {
            m.testMode = testMode
            m.duelNight = !testMode     // the user test was written around Bar of the Game
            // screenshots: `simctl launch … -autoDemo 76ers-home-v6 -fanPoints 150` opens as a newer fan
            let fp = UserDefaults.standard.integer(forKey: "fanPoints")
            if fp > 0 { m.basePoints = fp }
            if !testMode { m.showWelcome = true }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Nav bar, header, venue strip (same as today)

private struct V6NavBar: View {
    @EnvironmentObject var m: V6Model
    var onClose: () -> Void
    var showMenu = true
    var body: some View {
        HStack(spacing: 10) {
            Button { m.sheet = .profile } label: { V6NavIcon(symbol: "person") }
            Spacer()
            if showMenu {
            Menu {
                Button("Gameday (start over)") { m.reset() }
                // most fans open the app once they're already at the bar or the arena
                Button("Detected at a bar (Garage Fishtown)") { m.detect(at: "close") }
                Button(m.duelNight ? "Detected at a duel bar (O'Neals)" : "Detected at Bar of the Game (O'Neals)") { m.detect(at: "botg") }
                Button("Detected at the arena") { m.detect(at: "arena") }
                Button("No game today") { m.setMoment(.off); m.scrollTarget = "top" }
                Button("Game on") { m.goSettled(.live) }
                Button("After the game") { m.goSettled(.after) }
                Divider()
                Button(m.won ? "Fan of the Game: someone else wins" : "Fan of the Game: Andy wins") { m.won.toggle() }
                Button(m.homeGame ? "Make it an away game" : "Make it a home game") {
                    m.homeGame.toggle()
                    if !m.homeGame && m.mode == .arena { m.mode = .bar; if m.venue == "arena" { m.venue = "botg" } }
                }
                Button(m.duelNight ? "Tonight: Bar of the Game instead of the duel" : "Tonight: Bar Duel instead of Bar of the Game") {
                    m.duelNight.toggle(); m.seedDuel(); m.displayPoints = m.points
                }
                if m.duelNight {
                    Button(m.duelYouWin ? "Bar Duel: your bar loses" : "Bar Duel: your bar wins") {
                        m.duelYouWin.toggle(); m.seedDuel(); m.displayPoints = m.points
                    }
                }
                Picker("Fan", selection: $m.basePoints) {
                    Text("Fan: Andy · 1,800 pts").tag(V6Data.base)
                    Text("Fan: one check-in · 500 pts").tag(500)
                    Text("Fan: just joined · 150 pts").tag(V6Data.signUpBonus)
                }
                Button("Send a fan message") { m.showFanMessage = true }
                Button("Show the welcome") { m.showWelcome = true }
                Button(m.samPassed ? "Starting Five: undo Sam K.'s pass" : "Starting Five: Sam K. passes Andy") { m.passAndy() }
                Picker("Rewards", selection: $m.rewardsMode) {
                    Text("Rewards: milestones").tag(V6RewardsMode.unlock)
                    Text("Rewards: points store").tag(V6RewardsMode.spend)
                }
                Picker("Points card", selection: $m.cardMode) {
                    Text("Card: auto (rank for top 25)").tag(V6CardMode.auto)
                    Text("Card: status first").tag(V6CardMode.status)
                    Text("Card: rank first").tag(V6CardMode.rank)
                }
            } label: { V6NavIcon(symbol: "ellipsis") }
            }
            Button(action: onClose) { V6NavIcon(symbol: "xmark") }
        }
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(V6.navGradient.ignoresSafeArea(edges: .top))
    }
}

private struct V6NavIcon: View {
    let symbol: String
    var body: some View {
        Image(systemName: symbol).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
            .frame(width: 32, height: 32).background(Circle().fill(Color.white.opacity(0.16)))
    }
}

private struct V6Hero: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(spacing: 0) {
            // the hero stops at its red rule: the prize, deals and places it used to list are all on the page below
            Image("v6_header_home").resizable().scaledToFit()
                .accessibilityLabel("76ers Meet Up. Check in. Score big.")
            if m.arrived {
                HStack(spacing: 6) {
                    Image(systemName: m.venue == "home" ? "person.2.fill" : "location.fill").font(.system(size: 12, weight: .bold))
                    Text(m.venue == "home" ? "My Crew · Verified ✓" : "\(m.v.name) · \(m.moment == .at ? "Detected" : "Verified ✓")")
                        .font(.v6t13b)
                    Spacer()
                    // no check-in button here any more: the one big (moving) Check in in How to earn points sits right
                    // under this strip while you're detected, so there's a single next step
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(V6.strip)
            }
        }
    }
}

// MARK: - Bands: white where fans act, gray for showcases, merged when neighbours match

private struct V6Bands: View {
    @EnvironmentObject var m: V6Model
    private enum Section: Hashable { case won, season, prizes, picker, plan, party, featured, map, bars }

    private var order: [(gray: Bool, items: [Section])] {
        var secs: [(Bool, Section)] = []
        if m.moment == .after && m.won { secs.append((true, .won)) }
        // detected at a spot: checking in is the one thing to do, so How to earn points (with its big Check in) comes first
        let detected = m.moment == .at
        // the deal still to use goes above the points card too: it's the next thing to do (Will, 11-15); prizes stay below
        let dealFirst = m.dealLeft
        if detected || dealFirst { secs.append((false, .plan)) }
        secs.append((true, .season))
        if m.moment == .live { secs.append((false, .prizes)) }
        if !m.arrived { secs.append((false, .picker)) }
        if !detected && !dealFirst && m.planUp { secs.append((false, .plan)) }
        let homeUp = m.shownMode == .home
        if homeUp { secs.append((false, .party)) }
        let barsUp = m.shownMode == .bar && [.off, .gameday].contains(m.moment)
        if m.featuredUp || m.duelUp { secs.append((true, .featured)) }
        if barsUp { secs.append((true, .map)); secs.append((false, .bars)) }
        if m.moment != .live { secs.append((false, .prizes)) }
        if !homeUp { secs.append((false, .party)) }
        if !barsUp { secs.append((true, .map)); secs.append((false, .bars)) }
        var bands: [(gray: Bool, items: [Section])] = []
        for (g, s) in secs {
            if let last = bands.last, last.gray == g { bands[bands.count - 1].items.append(s) } else { bands.append((g, [s])) }
        }
        return bands
    }

    var body: some View {
        let bands = order
        VStack(spacing: 0) {
            // the greeting always opens the page (Will, 11-15): it sits above the bands, takes the first band's colour,
            // and stays put while the bands below reorder (detected → How to earn points comes first, under the greeting)
            if let hello = m.greeting {
                Text(hello).font(.v6t22).foregroundColor(V6.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16).padding(.top, 24)
                    .background((bands.first?.gray ?? true) ? V6.gray : Color.white)
            }
            // keyed by what's in each band, so a band that moves (How to earn points after check-in) slides instead of cross-fading
            ForEach(Array(bands.enumerated()), id: \.element.items) { i, band in
                VStack(spacing: 12) {
                    ForEach(Array(band.items.enumerated()), id: \.offset) { j, s in
                        if j > 0 {
                            if band.gray { Spacer().frame(height: 12) } else { Rectangle().fill(V6.hair).frame(height: 1).padding(.horizontal, -16).padding(.vertical, 12) }
                        }
                        section(s)
                    }
                }
                .padding(.horizontal, 16).padding(.top, i == 0 && m.greeting != nil ? (band.gray ? 12 : 22) : 24).padding(.bottom, 24)   // tighter under the greeting when it shows
                .frame(maxWidth: .infinity)
                .background(band.gray ? V6.gray : Color.white)
                .overlay(alignment: .top) { if i > 0 { Rectangle().fill(V6.hair).frame(height: 1) } }
            }
        }
    }

    @ViewBuilder private func section(_ s: Section) -> some View {
        switch s {
        case .won: V6YouWon()
        case .season:
            VStack(spacing: 12) {
                // the greeting moved above the bands (always on top)
                // no after-game recap card (Will, 11-15): the points card already shows where you are, YOU WON sits on top
                // when you win, and the plan header points at the next game
                V6SeasonCard()
            }
        case .prizes: V6Prizes()
        case .picker: V6Picker()
        case .plan: V6Plan()
        case .party: V6HomeParty().id("hwp")
        case .featured: if m.duelUp { V6Duel().id("duel") } else { V6Featured() }
        case .map: V6MapSection().id("bars")
        case .bars: V6BarList()
        }
    }
}

// MARK: - New: the points card (Grand Prize line, number, level by name, reward line)

private struct V6SeasonCard: View {
    @EnvironmentObject var m: V6Model
    // on Season Rewards itself the card doesn't open anything, and its line is about the leaderboard
    var onSeasonPage = false
    // set only by the side-by-side test task; otherwise the demo's own choice and the demo fan
    var mode: V6CardMode? = nil
    var persona: V6Persona? = nil
    var body: some View {
        let p = persona?.points ?? m.displayPoints, ti = m.tierIndex(p), tiers = V6Data.tiers
        let rankFirst = m.leadsWithRank(mode ?? m.cardMode, points: p, rank: persona?.rank ?? m.rankFor(p))
        VStack(spacing: 12) {
            Button { m.openSeason() } label: {
                VStack(spacing: 8) {
                    if !onSeasonPage {
                        Text("Top fan wins \(V6Data.grandPrize)").font(.v6t13b).foregroundColor(V6.on2).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if rankFirst {
                        // rank first: where you stand, and the one fan to pass next (counts with the points)
                        let above = persona.map { $0.next } ?? V6Data.field.last { $0.pts > p }
                        let floor = persona?.floor ?? V6Data.field.first { $0.pts <= p }?.pts ?? 0
                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("#\(persona?.rank ?? m.rankFor(p))").font(.system(size: 48, weight: .bold)).monospacedDigit()
                            Text("of \(V6Data.fanCount.formatted()) fans").font(.v6t17).foregroundColor(V6.on2)
                        }
                        if let a = above {
                            let pct = max(0.03, min(1, Double(p - floor) / Double(a.pts - floor)))
                            HStack(spacing: 10) {
                                Text("\(p.formatted()) pts").font(.v6t13b)
                                bar(pct)
                                Text("\((a.pts - p).formatted()) to pass \(a.name)").font(.v6t13b).foregroundColor(V6.on2)
                            }
                            .padding(.top, 4)
                        } else {
                            Text("You're the top fan. Stay there!").font(.v6t13b).padding(.top, 4)
                        }
                    } else {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(p.formatted()).font(.system(size: 48, weight: .bold)).monospacedDigit()
                        Text("pts").font(.v6t17).foregroundColor(V6.on2)
                    }
                    if ti + 1 < tiers.count {
                        let a = tiers[ti].min, b = tiers[ti + 1].min, pct = max(0.03, Double(p - a) / Double(b - a))
                        HStack(spacing: 10) {
                            Text(tiers[ti].name).font(.v6t13b)
                            bar(pct)
                            Text("\((b - p).formatted()) to \(tiers[ti + 1].name)").font(.v6t13b).foregroundColor(V6.on2)
                        }
                        .padding(.top, 4)
                    }
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .trailing) {
                    if !onSeasonPage {
                        Image(systemName: "chevron.right").font(.system(size: 15, weight: .bold)).foregroundColor(V6.brand)
                            .frame(width: 32, height: 32).background(Circle().fill(Color.white))
                            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                            .offset(x: 4, y: -6)
                    }
                }
                .foregroundColor(.white)
            }
            .buttonStyle(V6Press())
            .allowsHitTesting(!onSeasonPage)
            // lost a Starting Five spot: said right under the points, in the app (a push from the team's app isn't ours to send)
            if !onSeasonPage && persona == nil && m.lostSpot { V6LostSpotLine() }
            if onSeasonPage { V6LeaderboardLine() } else { V6RewardLine(persona: persona) }
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(V6.brand))
        .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }

    private func bar(_ pct: Double) -> some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.25))
                Capsule().fill(Color.white).frame(width: g.size.width * pct)
            }
        }
        .frame(height: 8)
    }
}

// on the home points card, under the points: someone took your Starting Five spot; opens that bar's five
private struct V6LostSpotLine: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        let n = m.visitsToFive("close")
        Button { m.openBump() } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.3.fill").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("You lost your Starting Five spot").font(.v6t13b).foregroundColor(.white)
                    Text("Sam K. passed you at Garage Fishtown. \(n == 1 ? "One visit gets" : n == 2 ? "Two visits get" : "\(n) visits get") you back in.")
                        .font(.v6t13).foregroundColor(V6.on2).multilineTextAlignment(.leading).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.14)))
        }
        .buttonStyle(V6Press())
    }
}

// Season Rewards: one card, two sides, so it never shows two big numbers at once. Points (what the status rewards run on)
// and Rank (what the grand prize runs on); tap Points / Rank (no swipe). It opens on the side that suits the fan:
// rank for the top 25 who have checked in, points for everyone else (the same rule as the home card).
private struct V6SeasonSlider: View {
    @EnvironmentObject var m: V6Model
    var toRewards: () -> Void
    @State private var side = 0
    @State private var chosen = false
    var body: some View {
        let p = m.displayPoints, ti = m.tierIndex(p), tiers = V6Data.tiers
        let above = V6Data.field.last { $0.pts > p }, floor = V6Data.field.first { $0.pts <= p }?.pts ?? 0
        VStack(spacing: 10) {
            HStack(spacing: 0) { tab("Points", 0); tab("Rank", 1) }
                .padding(3).background(Capsule().fill(Color.white.opacity(0.14)))
            // one side at a time, switched only by the toggle (no sideways swipe, so the page only ever scrolls up and down)
            ZStack(alignment: .top) {
                if side == 0 {
                    // points: the number the rewards below run on
                    VStack(spacing: 8) {
                        big(p.formatted(), "points")
                        if ti + 1 < tiers.count {
                            let a = tiers[ti].min, b = tiers[ti + 1].min
                            HStack(spacing: 10) {
                                Text(tiers[ti].name).font(.v6t13b)
                                bar(max(0.03, Double(p - a) / Double(b - a)))
                                Text("\((b - p).formatted()) to \(tiers[ti + 1].name)").font(.v6t13b).foregroundColor(V6.on2)
                            }
                        }
                        Spacer(minLength: 0)
                        line("gift", rewardText) { m.track("Season card · rewards line"); toRewards() }
                    }
                    .transition(.opacity)
                } else {
                    // rank: the number the grand prize runs on
                    VStack(spacing: 8) {
                        if !m.isRanked(p) {
                            // just joined: no rank until the first check-in
                            big("—", "not ranked yet")
                            Text("Check in once to get on the board").font(.v6t13b).foregroundColor(V6.on2)
                        } else {
                        big("#\(m.rankFor(p))", "of \(V6Data.fanCount.formatted()) fans")
                        if p < V6Data.field.last!.pts {
                            // below the named fans there's no one name to pass; keep it about moving up
                            Text("Every check-in moves you up").font(.v6t13b).foregroundColor(V6.on2)
                        } else if let a = above {
                            HStack(spacing: 10) {
                                bar(max(0.03, min(1, Double(p - floor) / Double(a.pts - floor))))
                                Text("\((a.pts - p).formatted()) points to pass \(a.name)").font(.v6t13b).foregroundColor(V6.on2).fixedSize()
                            }
                        } else {
                            Text("You're the top fan. Stay there!").font(.v6t13b)
                        }
                        }
                        Spacer(minLength: 0)
                        line("list.number", Text("See the Fan Leaderboard").bold().foregroundColor(.white)) { m.sheet = .leaderboard }
                    }
                    .transition(.opacity)
                }
            }
            .frame(height: 134)
            .animation(.easeInOut(duration: 0.2), value: side)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18).padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(V6.brand))
        .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
        .onChange(of: side) { s in m.track("Season card · \(s == 0 ? "Points" : "Rank")") }
        .onAppear {
            guard !chosen else { return }
            chosen = true
            // open straight on that side, without a slide
            var t = Transaction(); t.disablesAnimations = true
            withTransaction(t) { side = m.leadsWithRank(m.cardMode == .status ? .auto : m.cardMode, points: m.points, rank: m.rank) ? 1 : 0 }
        }
    }

    private var rewardText: Text {
        guard m.rewardsMode == .unlock else { return Text("\(m.available.formatted()) points").bold().foregroundColor(.white) + Text(" to use on rewards") }
        if let r = m.rewardToClaim { return Text(r.name).bold().foregroundColor(.white) + Text(" unlocked · claim it") }
        if let n = m.nextTitleReward { return Text(V6Data.tiers[n.tier].name).bold().foregroundColor(.white) + Text(" unlocks a \(n.name) · \(n.left) left") }
        return Text("Every reward unlocked")
    }

    private func tab(_ title: String, _ i: Int) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.25)) { side = i } } label: {
            Text(title).font(.v6t13b).foregroundColor(side == i ? V6.brand : .white)
                .frame(width: 84, height: 28)
                .background(Capsule().fill(side == i ? Color.white : Color.clear))
        }
        .buttonStyle(.plain)
    }

    private func big(_ value: String, _ unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text(value).font(.system(size: 48, weight: .bold)).monospacedDigit()
            Text(unit).font(.v6t17).foregroundColor(V6.on2)
        }
    }

    private func bar(_ pct: Double) -> some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.25))
                Capsule().fill(Color.white).frame(width: g.size.width * pct)
            }
        }
        .frame(height: 8)
    }

    private func line(_ symbol: String, _ text: Text, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                text.font(.v6t13).foregroundColor(V6.on2).lineLimit(1).minimumScaleFactor(0.85)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.14)))
        }
        .buttonStyle(V6Press())
    }
}

// on Season Rewards the card's line shows where you stand and opens the leaderboard
private struct V6LeaderboardLine: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        Button { m.sheet = .leaderboard } label: {
            HStack(spacing: 8) {
                Image(systemName: "list.number").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                line.font(.v6t13).foregroundColor(V6.on2).lineLimit(1).minimumScaleFactor(0.85)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.14)))
        }
        .buttonStyle(V6Press())
    }

    private var line: Text {
        let pass = m.fanAbove.map { "\(($0.pts - m.points).formatted()) to pass \($0.name)" }
        // the card above already leads with the rank
        if m.leadsWithRank(m.cardMode, points: m.points, rank: m.rank) { return Text("See the Fan Leaderboard").bold().foregroundColor(.white) }
        // outside the top, the next fan to pass without the big number
        if m.cardMode == .auto { return Text(pass ?? "See the Fan Leaderboard").bold().foregroundColor(.white) + Text(pass == nil ? "" : " · Fan Leaderboard") }
        return Text("#\(m.rank)").bold().foregroundColor(.white) + Text(" on the leaderboard") + Text(pass.map { " · " + $0 } ?? "")
    }
}

// the leaderboard fans already know: the top five, then the fans around you
private struct V6Leaderboard: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        // below the named fans (or not ranked yet), it's the top five, a gap, then you at your estimated rank
        let named = V6Data.field.map { (name: $0.name, pts: $0.pts) }, inField = m.inNamedBoard
        let all = inField ? (named + [(name: "You", pts: m.points)]).sorted { $0.pts > $1.pts } : Array(named.prefix(5)) + [(name: "You", pts: m.points)]
        let me = all.firstIndex { $0.name == "You" } ?? 0
        let shown = inField ? Array(Set(Array(0..<min(5, all.count)) + Array(max(0, me - 1)...min(all.count - 1, me + 1)))).sorted() : Array(0..<all.count)
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                V6SheetClose()
                Text("Fan Leaderboard").font(.v6t24).foregroundColor(V6.ink)
                Text("Top fan wins \(V6Data.grandPrize)").font(.v6t13).foregroundColor(V6.ink2).padding(.top, -8)
                VStack(spacing: 0) {
                    ForEach(Array(shown.enumerated()), id: \.element) { k, i in
                        if k > 0, inField ? i - shown[k - 1] > 1 : all[i].name == "You" {
                            Text("• • •").foregroundColor(V6.ink2).frame(maxWidth: .infinity).padding(8).background(Color.white)
                        }
                        let f = all[i], you = f.name == "You"
                        HStack {
                            Text(inField || f.name != "You" ? "#\(i + 1)" : m.isRanked(m.points) ? "#\(m.rank)" : "—")
                                .frame(width: 52, alignment: .leading)
                            // the Starting Five badge travels with the name
                            let mine = m.starterBars
                            let b = you ? (mine.count > 1 ? "\(mine.count) bars" : mine.first.map(m.barName)) : m.starterBar(of: f.name)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(f.name)
                                if let b { V6StarterChip(text: "Starting Five · \(b)", onDark: you) }
                            }
                            Spacer()
                            Text(f.pts.formatted())
                        }
                        .font(you ? .v6t13b : .v6t13)
                        .foregroundColor(you ? .white : V6.ink)
                        .padding(12)
                        .background(you ? V6.brand : Color.white)
                        .overlay(alignment: .bottom) { Rectangle().fill(V6.hair).frame(height: 1) }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(16)
        }
        .background(V6.gray)
        .presentationDetents([.medium, .large])
    }
}

// one line that ties the points to the store: how many points you can use
private struct V6RewardLine: View {
    @EnvironmentObject var m: V6Model
    var persona: V6Persona? = nil
    var body: some View {
        let line: Text = {
            // a persona has just reached its status and not claimed the reward yet
            if let persona, let r = V6Data.titleRewards.last(where: { $0.tier <= m.tierIndex(persona.points) }) {
                return Text(r.name).bold().foregroundColor(.white) + Text(" unlocked · claim it")
            }
            guard m.rewardsMode == .unlock else { return Text("\(m.available.formatted()) points").bold().foregroundColor(.white) + Text(" to use on rewards") }
            if let r = m.rewardToClaim { return Text(r.name).bold().foregroundColor(.white) + Text(" unlocked · claim it") }
            if let n = m.nextTitleReward { return Text(V6Data.tiers[n.tier].name).bold().foregroundColor(.white) + Text(" unlocks a \(n.name) · \(n.left) left") }
            return Text("Every reward unlocked")
        }()
        Group {
            Button { m.track("Tapped reward line"); m.openSeason(at: m.rewardsMode == .unlock ? "status" : "rewards") } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gift").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    line.font(.v6t13).foregroundColor(V6.on2).lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                }
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.14)))
            }
            .buttonStyle(V6Press())
        }
    }
}

private struct V6Recap: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("76ers Meet Up · tonight").font(.v6t13b).foregroundColor(V6.on2)
            Text("You showed up, Andy.").font(.v6t22)
            HStack(spacing: 10) {
                V6RecapNum(big: "+\(m.v.pts)", label: "Points tonight")
                V6RecapNum(big: "#\(m.rank) ↑", label: "Rank · was #12")
            }
            V6Flow(items: (m.v.kind == .bar ? ["✓ Checked in · \(m.v.name)", "✓ Deal used"] : m.v.kind == .arena ? ["✓ Checked in · \(m.v.name)"] : ["✓ My Crew · 3 fans"])
                   + ["★ New title: \(V6Data.tiers[m.tierIndex(m.points)].name)", m.won ? "★ Won Fan Gear" : "Fan Gear: not this time"])
            HStack {
                Text("Next game · Sun 6:00 PM"); Spacer(); Text("\(m.points.formatted()) pts")
            }
            .font(.v6t13b).padding(.top, 10)
            .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1) }
        }
        .foregroundColor(.white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(V6.brand))
        .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }
}

private struct V6RecapNum: View {
    let big: String, label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(big).font(.system(size: 24, weight: .bold))
            Text(label).font(.v6t13b).foregroundColor(V6.on2)
        }
        .padding(10).frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.12)))
    }
}

// simple wrapping row of stamps
private struct V6Flow: View {
    let items: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(stride(from: 0, to: items.count, by: 2).map { $0 }, id: \.self) { i in
                HStack(spacing: 6) {
                    ForEach(items[i..<min(i + 2, items.count)], id: \.self) { s in
                        Text(s).font(.v6t13b).lineLimit(1).minimumScaleFactor(0.8)
                            .foregroundColor(s.hasPrefix("Fan Gear: not") ? .white : V6.brand)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(s.hasPrefix("Fan Gear: not") ? Color.white.opacity(0.16) : Color.white))
                    }
                }
            }
        }
    }
}

// MARK: - Updated: How are you watching? (today's three options become the pick)

private struct V6Picker: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(spacing: 12) {
            // name the game, so the question is about a real night out (Will, 11-15)
            VStack(spacing: 4) {
                Text("How are you watching\n\(m.gameName)?").font(.v6t24).foregroundColor(V6.ink).multilineTextAlignment(.center)
                Text(m.gameWhen).font(.v6t13b).foregroundColor(V6.ink2)
            }
            HStack(spacing: 10) {
                ForEach(V6Model.Mode.allCases.filter { m.homeGame || $0 != .arena }, id: \.self) { mode in
                    let on = mode == m.shownMode
                    Button { m.pick(mode) } label: {
                        VStack(spacing: 6) {
                            Image(systemName: on && m.moment == .at ? "mappin.and.ellipse" : symbol(mode)).font(.system(size: 22, weight: .regular))
                            Text(label(mode)).font(.v6t13b)
                        }
                        .foregroundColor(on ? .white : V6.brand)
                        .frame(maxWidth: .infinity).frame(height: 88)
                        .background(RoundedRectangle(cornerRadius: 12).fill(on ? V6.brand : V6.brand10))
                    }
                    .buttonStyle(V6Press())
                }
            }
            if m.moment == .gameday && m.shownMode != .home {
                Button { m.find() } label: {
                    HStack(spacing: 8) {
                        if m.finding { ProgressView().tint(.white); Text("Finding your spot…") } else { Image(systemName: "location.fill"); Text("I'm here now — find my spot") }
                    }
                    .v6Primary()
                }
                .buttonStyle(V6Press())
            }
        }
    }
    func symbol(_ m: V6Model.Mode) -> String { m == .bar ? "wineglass" : m == .arena ? "sportscourt" : "house" }
    func label(_ m: V6Model.Mode) -> String { m == .bar ? "At a bar" : m == .arena ? "At the arena" : "At home" }
}

// MARK: - Updated: How to earn points (was the game plan) — every row leads with its points

private struct V6Step: Identifiable {
    var id: String { title }    // stable, so a row (and its button's motion) isn't rebuilt on every refresh
    var state: String           // done, active, locked, later
    var here = false
    var title: String
    var note: String
    var reward = ""
    var double = false          // Bar of the Game: gold 2x tag
    var cta: (label: String, action: () -> Void)?
    var link: (label: String, symbol: String, action: () -> Void)?
    var notHere = false         // detected spot: offer "Not at X? Find my spot" under the check-in
}

private struct V6Plan: View {
    @EnvironmentObject var m: V6Model
    private var steps: [V6Step] {
        let mo = m.moment, done1 = m.settled, v = m.arrived ? m.v : nil
        let s1 = mo == .off ? "later" : done1 ? "done" : "active"
        switch m.shownMode {
        case .bar:
            guard let v else {
                let b = V6Data.venues["botg"]!, c = V6Data.venues["close"]!
                if m.duelNight {
                    // the row is named for the two bars, like Bar of the Game is named for its bar (Will, 11-15)
                    // both duel bars are 2x, so the closest bar (Garage Fishtown) is in the duel and the plain row is "any other"
                    return [V6Step(state: s1, title: "\(b.name) vs \(c.name)", note: "Join the Bar Duel", reward: "+700", double: true,
                                   link: ("See the duel", "arrow.down", { m.scrollTarget = "duel" })),
                            V6Step(state: s1, title: "Any other 76ers Meet Up bar", note: "Like Moriarty's", reward: "+350",
                                   link: ("See bars near you", "mappin", { m.scrollTarget = "bars" }))]
                }
                return [V6Step(state: s1, title: "Bar of the Game", note: "\(b.name) · \(b.mi) mi", reward: "+\(b.pts)", double: true,
                               link: ("See \(b.name)", "star", { m.sheet = .bar("botg") })),
                        V6Step(state: s1, title: "Any 76ers Meet Up bar", note: "Closest: \(c.name) · \(c.mi) mi", reward: "+350",
                               link: ("See bars near you", "mappin", { m.scrollTarget = "bars" }))]
            }
            return [V6Step(state: s1, here: !done1, title: done1 ? "Checked in at \(v.name)" : v.name,
                           // checked in: the button names the deal; one deal for everyone, starters included (Will, 11-15)
                           // detected: just the check-in (Will, 11-15); the deal appears on the button once you're in
                           note: mo == .at || mo == .checkedIn ? "" : "You're in tonight's Fan Gear draw",
                           reward: "+\(v.pts)", double: v.botg,
                           cta: mo == .at ? ("Check in  +\(v.pts)", { m.checkIn() }) : mo == .checkedIn ? ("Get \(v.deal)", { m.showDeal(five: false) }) : nil,
                           notHere: mo == .at)]
                // your bar won the duel: the bonus gets its own green row, so the points card's jump adds up
                + (m.duelBonus > 0 ? [V6Step(state: "done", title: "\(v.name) won the Bar Duel", note: "", reward: "+\(V6Data.duelBonus)")] : [])
        case .arena:
            guard let v else {
                let a = V6Data.venues["arena"]!
                return [V6Step(state: s1, title: "Check in at the arena", note: "\(a.name) · \(a.mi) mi · from your seat", reward: "+500")]
            }
            return [V6Step(state: s1, here: !done1, title: done1 ? "Checked in at \(v.name)" : v.name,
                           // same as a bar: checking in unlocks the arena's deal; once it's used, the row says you're in the draw
                           note: mo == .at || mo == .checkedIn ? "" : "You're in tonight's Fan Gear draw",
                           reward: "+500",
                           cta: mo == .at ? ("Check in  +500", { m.checkIn() }) : mo == .checkedIn ? ("Get \(v.deal)", { m.showDeal(five: false) }) : nil,
                           notHere: mo == .at)]
        case .home:
            let crew = ("Go to Home Watch Party", "person.2", { m.scrollTarget = "hwp" })
            if v == nil {
                return [V6Step(state: s1, title: "Start or join a Home Watch Party", note: "Each friend you add is +1 entry in the party prize", reward: "+250",
                               link: crew)]
            }
            return [V6Step(state: "done", title: "My Crew is live", note: mo == .checkedIn ? "Add friends for more party prize entries" : "You're in tonight's Fan Gear draw",
                           reward: "+250", link: mo == .checkedIn ? crew : nil)]
        }
    }

    // checked in: no heading, no "+350", no "Checked in at…" (the points card and the Verified strip say that) — just the deal
    private var dealOnly: (label: String, action: () -> Void) {
        ("Get \(m.v.deal)", { m.showDeal(five: false) })
    }

    var body: some View {
        if m.settled && m.moment != .after {
            let d = dealOnly
            VStack(spacing: 12) {
                // a header like Tonight's Prizes (Will, 11-15)
                Text("Deal of the Game").font(.v6t24).foregroundColor(V6.ink)
                Button { m.track("Tapped \(d.label)"); d.action() } label: {
                    Text(d.label).lineLimit(1).minimumScaleFactor(0.8).padding(.horizontal, 12).v6Primary().modifier(V6Alive())
                }
                .buttonStyle(V6Press())
            }
        } else {
            plan
        }
    }

    private var plan: some View {
        let list = steps
        return VStack(alignment: .leading, spacing: 12) {
            Button { withAnimation { m.planOpen.toggle() } } label: {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        if m.settled {
                            // checked in (Will, 11-15): nothing left here earns points, so the game clock is the heading,
                            // the one thing that still changes tonight (no "Tonight", no small countdown line)
                            Group {
                                if m.moment == .live {
                                    HStack(spacing: 8) {
                                        Circle().fill(Color(red: 237 / 255, green: 23 / 255, blue: 76 / 255)).frame(width: 10, height: 10)
                                        Text("Game on")
                                    }
                                } else if m.moment == .after { Text(m.nextGame) }   // after the final, point at the next game
                                else { V6Countdown(prefix: "Tip-off in ", to: m.tipoff, symbol: nil) }
                            }
                            .font(.v6t22).foregroundColor(V6.ink)
                        } else {
                            Group {
                                if m.moment == .live { Label("Game on", systemImage: "circle.fill") }
                                else if m.moment == .after { Text("Final · \(m.nextGame)") }
                                // the countdown is for fans deciding when to head out; once you're detected you're already there
                                else if m.moment != .at { V6Countdown(prefix: "Tip-off in ", to: m.tipoff, symbol: "clock") }
                            }
                            .font(.v6t13b).foregroundColor(V6.brand)
                            Text("How to earn points").font(.v6t22).foregroundColor(V6.ink)
                        }
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        // no "+N tonight" here: the row's green ✓ +N pill already says it (Will 11-15)
                        if m.moment == .off { Text("Tomorrow") }
                        Image(systemName: "chevron.down").rotationEffect(.degrees(m.planOpen ? 0 : -90))
                    }
                    .font(.v6t13).foregroundColor(V6.ink2)
                }
            }
            .buttonStyle(.plain)
            if m.planOpen {
                if m.moment == .off {
                    Text(m.mode == .home ? "One watch party tomorrow makes you a Super Fan." : "One check-in tomorrow makes you a Super Fan.")
                        .font(.v6t13b).foregroundColor(V6.brand)
                }
                VStack(spacing: 0) {
                    ForEach(list) { step in V6StepRow(step: step) }
                }
                .padding(.horizontal, -16)
            }
        }
    }
}

private struct V6StepRow: View {
    @EnvironmentObject var m: V6Model
    let step: V6Step
    private let badge: CGFloat = 70
    var body: some View {
        let done = step.state == "done", on = step.state == "active"
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // the points lead each row: blue to earn, green once earned
                HStack(spacing: 3) {
                    if done { Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)) }
                    Text(step.reward).font(.system(size: 16, weight: .bold)).monospacedDigit()
                }
                .foregroundColor(done || on ? .white : V6.brand)
                .frame(width: badge, height: 34)
                .background(Capsule().fill(done ? V6.ok : on ? V6.brand : V6.brand10))
                VStack(alignment: .leading, spacing: 2) {
                    if step.here {
                        Label("You're at", systemImage: "mappin.and.ellipse").font(.v6t13b).foregroundColor(V6.brand)
                    }
                    HStack(spacing: 6) {
                        Text(step.title).font(step.here ? .v6t22 : .v6t17).foregroundColor(done ? V6.ink2 : V6.ink)
                        if step.double {
                            Text("2x").font(.v6t13b).foregroundColor(V6.ink).padding(.horizontal, 8).padding(.vertical, 3).background(Capsule().fill(V6.gold))
                        }
                    }
                    if !step.note.isEmpty { Text(step.note).font(.v6t13).foregroundColor(V6.ink2) }
                    if let link = step.link {
                        Button { m.track("Tapped \(link.label)"); link.action() } label: {
                            Label(link.label, systemImage: link.symbol).font(.v6t13b).foregroundColor(V6.brand)
                                .padding(.horizontal, 12).frame(height: 32)
                                .background(Capsule().fill(V6.brand10))
                        }
                        .padding(.top, 6)
                    }
                }
                .padding(.top, step.here ? 0 : 6)
                Spacer(minLength: 0)
            }
            if let cta = step.cta {
                // the one next step: a light sweep and a slow breath so it reads as "do this now"
                Button(action: cta.action) { Text(cta.label).lineLimit(1).minimumScaleFactor(0.8).padding(.horizontal, 12).v6Primary().modifier(V6Alive()) }.buttonStyle(V6Press()).padding(.top, 4)
            }
            if step.notHere {
                Button { m.find() } label: {
                    (m.finding ? Text("Finding your spot…") : Text("Not at \(m.v.name)? ") + Text("Find my spot").bold().foregroundColor(V6.brand))
                        .font(.v6t13).foregroundColor(V6.ink2)
                }
                .frame(maxWidth: .infinity).padding(.top, 2)
            }
        }
        .opacity(step.state == "locked" || step.state == "later" ? 0.5 : 1)
        .padding(.horizontal, 16).padding(.vertical, 12)
        .overlay(alignment: .top) { Rectangle().fill(V6.hair).frame(height: 1) }
    }
}

// MARK: - Updated: Bar of the Game (or arena) featured card

private struct V6Featured: View {
    @EnvironmentObject var m: V6Model
    @Environment(\.openURL) private var openURL
    var body: some View {
        let arena = m.shownMode == .arena, b = V6Data.venues[arena ? "arena" : "botg"]!, close = V6Data.venues["close"]!
        if m.moment == .at {
            Button { directions(to: "botg") } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bar of the Game tonight").font(.v6t13b).foregroundColor(V6.on2)
                        Text("\(b.name) · \(b.mi) mi").font(.v6t17)
                        if m.isStarter("botg") { V6StarterChip(text: "You're in the Starting Five", onDark: true).padding(.top, 2) }
                    }
                    Spacer()
                    V6TwoX(small: true)
                }
                .foregroundColor(.white).padding(18).v6Card()
            }
            .buttonStyle(V6Press())
        } else {
            VStack(alignment: .leading, spacing: 8) {
                // the one thing fans care about here is 2x points, so it's the biggest thing on the card (no deal, no "+700 instead of +350")
                // the bar isn't in the list below while this card is up, so the card opens its page
                Button { if !arena { m.sheet = .bar("botg") } } label: {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(arena ? "\(m.moment == .off ? "Tomorrow's" : "Tonight's") home game" : "\(m.moment == .off ? "Tomorrow's" : "Official") Bar of the Game")
                                .font(.v6t13b).foregroundColor(V6.on2)
                            HStack(spacing: 6) {
                                Text(b.name).font(.v6t22)
                                if !arena { Image(systemName: "chevron.right").font(.system(size: 15, weight: .bold)).foregroundColor(V6.on2) }
                            }
                            Text(arena ? "\(m.moment == .off ? "Gates 5:30 PM · tip-off 7:00 PM" : "Gates 6:00 PM · tip-off 7:30 PM") · \(b.mi) mi" : "\(b.mi) mi")
                                .font(.v6t13).foregroundColor(V6.on2)
                            // the only thing from the bar's list row worth bringing up: your Starting Five spot there
                            if !arena && m.isStarter("botg") { V6StarterChip(text: "You're in the Starting Five", onDark: true).padding(.top, 2) }
                        }
                        Spacer(minLength: 0)
                        if arena { V6Pill(text: "+\(b.pts)") } else { V6TwoX() }
                    }
                    .foregroundColor(.white)
                }
                .buttonStyle(V6Press())
                .disabled(arena)
                if m.moment == .gameday {
                    Button { directions(to: arena ? "arena" : "botg") } label: {
                        Label("Directions", systemImage: "location.north.line").v6Button(fill: .white, text: V6.brand)
                    }
                    .buttonStyle(V6Press()).padding(.top, 4)
                    if !arena {
                        Button { m.sheet = .bar("close") } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin")
                                Text("Closest: ") + Text(close.name).bold().foregroundColor(.white)
                                Spacer()
                                Text("\(close.mi) mi")
                                Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold))
                            }
                            .font(.v6t13).foregroundColor(V6.on2)
                            .padding(.top, 10)
                            .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1) }
                        }
                    }
                }
            }
            .foregroundColor(.white).padding(18).v6Card()
        }
    }
    func directions(to key: String) {
        let c = key == "arena" ? CLLocationCoordinate2D(latitude: 39.9012, longitude: -75.1720)
            : V6Data.bars.first { $0.id == key }?.coordinate ?? .init(latitude: 39.95, longitude: -75.16)
        m.directions(key == "arena" ? "Xfinity Mobile Arena" : V6Data.bars.first { $0.id == key }?.name ?? key, to: c, open: openURL)
    }
}

// MARK: - New: Bar Duel — two bars, most check-ins tonight wins (Will, 11-15)
// built like the Bar of the Game card, but a scoreboard: dark board, a red side and a blue side, big numbers that move

private struct V6Duel: View {
    // on spec (Will, 11-15): only the team's primary (blue) and secondary (red) plus white — no gold, no custom navy board
    @EnvironmentObject var m: V6Model
    private let tick = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()
    static let red = Color(red: 237 / 255, green: 23 / 255, blue: 76 / 255)   // 76ers secondary
    var body: some View {
        let sc = m.duelScore, keys = V6Data.duel, names = keys.map { V6Data.venues[$0]!.name }
        let total = max(1, sc[0] + sc[1])
        VStack(spacing: 12) {
        // a section header like Tonight's Prizes (Will, 11-15); the card starts straight with the two bars
        Text("Bar Duel").font(.v6t24).foregroundColor(V6.ink)
        // one line above the board (Will, 11-15), styled like "You're entered in 1 of 2 prizes"; the prizes stay underneath
        Text(subtitle).font(.v6t13).foregroundColor(V6.ink2).padding(.top, -6)
        VStack(alignment: .leading, spacing: 14) {
            // no LIVE / FINAL row (Will, 11-15: it took a full line); WINS on the winning side marks the final
            HStack(spacing: 8) {
                side(0, name: names[0], score: sc[0])
                Text("VS").font(.system(size: 14, weight: .black)).foregroundColor(V6.on2)
                side(1, name: names[1], score: sc[1])
            }
            // tug of war: each bar's share of tonight's check-ins, in the same red and white as the two sides
            GeometryReader { g in
                HStack(spacing: 3) {
                    Capsule().fill(Self.red).frame(width: max(6, (g.size.width - 3) * CGFloat(sc[0]) / CGFloat(total)))
                    Capsule().fill(Color.white)
                }
            }
            .frame(height: 8)
            .opacity(m.moment == .off ? 0.3 : 1)
            // two lines (Will): what the fans get, and what the bar itself wins
            VStack(alignment: .leading, spacing: 4) {
                fansLine(names: names)
                barLine(names: names)
            }
            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .v6Card()
        }
        .onReceive(tick) { _ in m.tickDuel() }
    }

    @ViewBuilder private var status: some View {
        switch m.moment {
        case .live:
            HStack(spacing: 5) { Circle().fill(Self.red).frame(width: 7, height: 7); Text("LIVE") }
                .font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                .padding(.horizontal, 9).padding(.vertical, 4).background(Capsule().fill(Color.white.opacity(0.18)))
        case .after:
            Text("FINAL").font(.system(size: 12, weight: .heavy)).tracking(1).foregroundColor(V6.brand)
                .padding(.horizontal, 9).padding(.vertical, 4).background(Capsule().fill(Color.white))
        case .off:
            Text("TOMORROW").font(.system(size: 12, weight: .heavy)).tracking(1).foregroundColor(V6.on2)
        default:
            EmptyView()
        }
    }

    // one side red (secondary) with white type, the other white with blue (primary) type
    private func side(_ i: Int, name: String, score: Int) -> some View {
        let fill = i == 0 ? Self.red : Color.white, ink = i == 0 ? Color.white : V6.brand
        let mine = m.duelSide == i, won = m.duelWinner == i, lost = m.duelWinner != nil && !won
        return Button { m.sheet = .bar(V6Data.duel[i]) } label: {
            VStack(spacing: 4) {
                Text(name.uppercased()).font(.system(size: 13, weight: .heavy)).tracking(0.3)
                    .lineLimit(1).minimumScaleFactor(0.7)
                // same type as the big number on the season points card (not the rounded face)
                Text("\(score)").font(.system(size: 48, weight: .bold)).monospacedDigit()
                    .contentTransition(.numericText()).animation(.spring(response: 0.45, dampingFraction: 0.7), value: score)
                Text(won ? "WINS" : "check-ins").font(.system(size: 11, weight: won ? .heavy : .semibold)).tracking(won ? 1 : 0)
                    .opacity(won ? 1 : 0.8)
            }
            .foregroundColor(ink)
            .frame(maxWidth: .infinity).padding(.vertical, 12).padding(.horizontal, 6)
            .background(RoundedRectangle(cornerRadius: 12).fill(fill))
            .overlay(alignment: .bottom) {
                // marks your side: you're there, and your check-in counts for it (the chip takes the other side's colours)
                if mine {
                    Text(m.settled ? "YOUR BAR" : "YOU'RE HERE").font(.system(size: 10, weight: .heavy)).tracking(0.5).foregroundColor(fill)
                        .padding(.horizontal, 8).padding(.vertical, 3).background(Capsule().fill(ink))
                        .overlay(Capsule().stroke(fill, lineWidth: 1.5))
                        .offset(y: 9)
                }
            }
            .overlay(alignment: .top) {
                if m.duelPlus == i {
                    // a chip in the side's colours like YOUR BAR (plain white +1 vanished on the white side, Will 11-15)
                    Text("+1").font(.system(size: 15, weight: .heavy)).foregroundColor(fill)
                        .padding(.horizontal, 10).padding(.vertical, 3).background(Capsule().fill(ink))
                        .overlay(Capsule().stroke(fill, lineWidth: 1.5))
                        .offset(y: -12).transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .opacity(lost ? 0.45 : 1)
        }
        .buttonStyle(V6Press())
        .padding(.bottom, mine ? 6 : 0)
    }

    // where the duel stands for you, in one short line (LIVE / FINAL live here now instead of a tag row)
    private var subtitle: String {
        let names = V6Data.duel.map { V6Data.venues[$0]!.name }
        switch m.moment {
        case .off: return "Tomorrow · most check-ins wins"
        case .after: return m.duelSide.map { $0 == m.duelWinner ? "Final · your bar won" : "Final · \(names[$0]) came up short" } ?? "Final"
        case .live: return "Live · check-ins count until the final buzzer"
        case .at: return m.duelSide.map { "Check in to add 1 for \(names[$0])" } ?? "Most check-ins tonight wins"
        case .checkedIn: return m.duelSide.map { "Your check-in counts for \(names[$0])" } ?? "Most check-ins tonight wins"
        case .gameday: return "Most check-ins tonight wins"
        }
    }

    private func fansLine(names: [String]) -> Text {
        let who = m.duelWinner.map { "Fans at \(names[$0]) get " } ?? "Fans at the winning bar get "
        return Text(who) + Text("+\(V6Data.duelBonus) points").fontWeight(.heavy) + Text(".")
    }
    private func barLine(names: [String]) -> Text {
        let who = m.duelWinner.map { "\(names[$0]) gets " } ?? "The winning bar gets "
        return Text(who) + Text(V6Data.duelBarPrize).fontWeight(.heavy) + Text(".")
    }
}

// Bar of the Game's badge: a big "2x POINTS" in the same gold as the 2x tags elsewhere
private struct V6TwoX: View {
    var small = false
    var body: some View {
        VStack(spacing: 0) {
            Text("2x").font(.system(size: small ? 22 : 34, weight: .heavy))
            Text("POINTS").font(.system(size: small ? 9 : 11, weight: .bold))
        }
        .foregroundColor(V6.ink)
        .frame(width: small ? 58 : 76, height: small ? 50 : 70)
        .background(RoundedRectangle(cornerRadius: 14).fill(V6.gold))
    }
}

// MARK: - Same as today: Watch Party Locations map, bar list with upvotes

private struct V6MapSection: View {
    @EnvironmentObject var m: V6Model
    @State private var region = MKCoordinateRegion(center: .init(latitude: 39.9545, longitude: -75.1505),
                                                   span: .init(latitudeDelta: 0.055, longitudeDelta: 0.055))
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Text("Watch Party Locations").font(.v6t24).foregroundColor(V6.ink)
                HStack {
                    Spacer()
                    Button { m.toast("Opens the full map") } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right").font(.system(size: 13, weight: .semibold)).foregroundColor(V6.ink)
                            .frame(width: 32, height: 32).background(Circle().fill(Color.black.opacity(0.07)))
                    }
                }
            }
            Map(coordinateRegion: $region, annotationItems: V6Data.bars) { bar in
                MapAnnotation(coordinate: bar.coordinate) {
                    Button { m.sheet = .bar(bar.id) } label: {
                        Image(systemName: bar.id == "botg" ? "star.fill" : "mappin").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            .frame(width: bar.id == "botg" ? 34 : 28, height: bar.id == "botg" ? 34 : 28)
                            .background(Circle().fill(bar.id == "botg" ? V6.brand : V6.pin))
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }
            .frame(height: 210)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
        }
    }
}

private struct V6BarList: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(spacing: 0) {
            // Bar of the Game isn't repeated here while its own card is up
            // ... and neither duel bar while the duel card is up
            let bars = V6Data.bars.filter { !(m.botgCardUp && $0.id == "botg") && !(m.duelUp && V6Data.duel.contains($0.id)) }
            ForEach(bars) { bar in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Button { m.sheet = .bar(bar.id) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bar.name).font(.v6t17).foregroundColor(V6.ink)
                                if m.duelNight && V6Data.duel.contains(bar.id) {
                                    Label("Bar Duel tonight · 2x points", systemImage: "star.fill").font(.v6t13b).foregroundColor(V6.brand)
                                } else if bar.id == "botg" && !m.duelNight {
                                    Label("Bar of the Game · 2x points", systemImage: "star.fill").font(.v6t13b).foregroundColor(V6.brand)
                                }
                                if bar.id == m.favorite {
                                    Label("#1 Fan Favorite", systemImage: "trophy.fill").font(.v6t13b).foregroundColor(V6.ink)
                                }
                                // your Starting Five spot here, or how close you are to one
                                if m.isStarter(bar.id) {
                                    V6StarterChip(text: "Starting Five").padding(.vertical, 2)
                                } else if m.visitsToFive(bar.id) == 1 {
                                    Label("1 visit from the Starting Five", systemImage: "person.3.fill").font(.v6t13b).foregroundColor(V6.ink)
                                }
                                Text(bar.address).font(.v6t13).foregroundColor(V6.ink2).multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        V6Upvote(key: bar.id, big: false)
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(white: 0.78))
                    }
                    V6DealPill(bar: bar)
                    if m.settled && m.venue == bar.id {
                        Label("You're checked in here", systemImage: "checkmark").font(.v6t13b).foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 10).fill(V6.strip))
                    }
                }
                .padding(16)
                .overlay(alignment: .bottom) { if bar.id != bars.last?.id { Rectangle().fill(V6.hair).frame(height: 1) } }
            }
        }
        .padding(.horizontal, -16).padding(.vertical, -16)
    }
}

private struct V6Upvote: View {
    @EnvironmentObject var m: V6Model
    let key: String
    let big: Bool
    var body: some View {
        let mine = m.myVotes.contains(key), n = m.voteCount(key)
        Button { m.vote(key) } label: {
            Label(big ? "\(mine ? "Upvoted" : "Upvote") · \(n)" : (n >= 10 ? "\(n)" : (mine ? "Upvoted" : "Upvote")),
                  systemImage: mine ? "hand.thumbsup.fill" : "hand.thumbsup")
                .font(.v6t13b)
                .foregroundColor(big ? (mine ? V6.brand : .white) : (mine ? .white : V6.brand))
                .padding(.horizontal, 12).frame(height: 32)
                .background(Capsule().fill(big ? (mine ? Color.white : Color.white.opacity(0.18)) : (mine ? V6.brand : V6.brand10)))
        }
        .buttonStyle(.plain)
    }
}

private struct V6DealPill: View {
    @EnvironmentObject var m: V6Model
    let bar: V6Bar
    var inCard = false
    var five = false        // the bar's Starting Five deal, which starters get on top of the regular one
    var body: some View {
        let here = m.settled && m.venue == bar.id
        let used = five ? m.usedFive.contains(bar.id) : (m.moment == .live || m.moment == .after) && m.venue == bar.id
        let starter = five && !used
        Button {
            if !used && (five ? here : m.moment == .checkedIn && m.venue == bar.id) {
                m.sheet = nil; DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { m.showDeal(five: five) }
            }
            else if inCard { m.toast("Check in at this bar to unlock its deal") }
            else if !used { m.sheet = .bar(bar.id) }
        } label: {
            ZStack {
                VStack(spacing: 2) {
                    if starter { Text("STARTING FIVE DEAL").font(.system(size: 11, weight: .bold)).foregroundColor(V6.on2) }
                    Text(used ? "Redeemed!" : "Redeem \(five ? m.starterDeal(bar.id) : bar.deal)").font(.v6t17).multilineTextAlignment(.center)
                }
                .padding(.horizontal, 64).padding(.vertical, starter ? 8 : 0)
                HStack {
                    Image("v6_tile").resizable().scaledToFit().frame(width: 48, height: 48).background(Color.white)
                    Spacer()
                    if !used {
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .bold))
                            .frame(width: 28, height: 28).background(Circle().fill(Color.white.opacity(0.25)))
                    }
                }
                .padding(.horizontal, 8)
            }
            .foregroundColor(used ? V6.ink2 : .white)
            .frame(maxWidth: .infinity, minHeight: 64)
            .background(RoundedRectangle(cornerRadius: 14).fill(used ? Color(white: 0.894) : starter ? V6.strip : V6.brand))
            .shadow(color: .black.opacity(used ? 0 : 0.08), radius: 2, y: 1)
        }
        .buttonStyle(V6Press())
    }
}

// MARK: - Same as today: tonight's prizes (several rows, each opening "You're entered"); updated: YOU WON

private struct V6Prizes: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        let entered = m.settled ? (m.venue == "home" ? 2 : 1) : 0
        VStack(spacing: 12) {
            Text("Tonight's Prizes").font(.v6t24).foregroundColor(V6.ink)
            if m.moment == .after {
                V6PrizeRow(id: "fotg", drawn: true)
                V6PrizeRow(id: "shop", drawn: true)
            } else {
                Text(entered > 0 ? "You're entered in \(entered) of 2 prizes" : "Check in to enter").font(.v6t13).foregroundColor(V6.ink2).padding(.top, -6)
                Button { m.sheet = .prize("fotg") } label: {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fan of the Game").font(.v6t13b).foregroundColor(V6.on2)
                                Text(V6Data.prize).font(.v6t17).multilineTextAlignment(.leading)
                                V6Pill(text: "UPCOMING", dot: true)
                            }
                            Spacer()
                        }
                        HStack(alignment: .lastTextBaseline) {
                            Text(m.settled ? "You're entered" : "Check in to enter").font(.v6t13).foregroundColor(V6.on2)
                            Spacer()
                            Text("DRAWS IN ").font(.v6t13b).foregroundColor(V6.on2)
                            V6Countdown(prefix: "", to: m.drawAt, symbol: nil).font(.system(size: 24, weight: .bold))
                        }
                        .padding(.top, 10)
                        .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1) }
                    }
                    .foregroundColor(.white).padding(18).v6Card()
                }
                .buttonStyle(V6Press())
                V6PrizeRow(id: "shop", drawn: false)
            }
        }
    }
}

private struct V6PrizeRow: View {
    @EnvironmentObject var m: V6Model
    let id: String
    let drawn: Bool
    var inCard = false
    var body: some View {
        let fotg = id == "fotg"
        let entered = m.settled && (fotg || m.venue == "home")
        Button { m.sheet = .prize(id) } label: {
            HStack(spacing: 12) {
                Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(V6.brand10)
                VStack(alignment: .leading, spacing: 4) {
                    Text(fotg ? V6Data.prize : "20% off at the Sixers Shop").font(.v6t17).foregroundColor(V6.ink).multilineTextAlignment(.leading)
                    Text(drawn ? (fotg ? (m.won ? "You won" : "Jess T. won") : "Kara's Crew won") : entered ? "You're entered" : fotg ? "Check in to enter" : "Start a Home Watch Party to enter")
                        .font(.v6t13).foregroundColor(V6.ink2)
                    V6Pill(text: drawn ? "DRAW COMPLETE" : "UPCOMING", dot: !drawn, fill: drawn ? Color(white: 0.77) : V6.brand)
                }
                Spacer()
                Image(systemName: "arrow.right").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                    .frame(width: 28, height: 28).background(Circle().fill(V6.brand))
            }
            .padding(.horizontal, inCard ? 12 : 16).padding(.vertical, 12)
            .background(inCard ? RoundedRectangle(cornerRadius: 12).fill(Color.white) : nil)
            .overlay(alignment: .top) { if !inCard { Rectangle().fill(V6.hair).frame(height: 1) } }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, inCard ? 0 : -16)
    }
}

private struct V6YouWon: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                Text("Fan of the Game · tonight").font(.v6t13b).foregroundColor(V6.on2)
            }
            Text("YOU WON").font(.system(size: 48, weight: .bold)).padding(.top, 6)
            Text(V6Data.prize).font(.v6t22)
            Text("Claim it by Sunday. We'll ship it to you.").font(.v6t13).foregroundColor(V6.on2)
            Button { m.claim() } label: { Text("Claim your prize").v6Button(fill: .white, text: V6.brand) }
                .buttonStyle(V6Press()).padding(.top, 6)
        }
        .foregroundColor(.white).padding(18).v6Card()
    }
}

// MARK: - Same as today: Home Watch Party

private struct V6HomeParty: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(spacing: 12) {
            Text("Home Watch Party").font(.v6t24).foregroundColor(V6.ink)
            if m.settled && m.venue == "home" {
                Text("My Crew · Verified").font(.v6t13).foregroundColor(V6.ink2).padding(.top, -6)
                VStack(spacing: 0) {
                    ForEach([("A", "Andy", "You · host"), ("M", "Maya", ""), ("D", "Dre", "")], id: \.1) { row in
                        HStack(spacing: 10) {
                            Text(row.0).font(.v6t17).foregroundColor(.white).frame(width: 32, height: 32).background(Circle().fill(V6.brand))
                            Text(row.1).font(.v6t17).foregroundColor(V6.ink)
                            Spacer()
                            Text(row.2).font(.v6t13).foregroundColor(V6.ink2)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .overlay(alignment: .bottom) { Rectangle().fill(V6.hair).frame(height: 1) }
                    }
                }
                .overlay(alignment: .top) { Rectangle().fill(V6.hair).frame(height: 1) }
                .padding(.horizontal, -16)
                Button { m.toast("Opens your share sheet") } label: {
                    Label("Invite by link or QR", systemImage: "square.and.arrow.up").v6Button(fill: V6.brand10, text: V6.brand)
                }
                .buttonStyle(V6Press())
                Button("End party") { m.toast("Ends the party") }.font(.v6t13b).foregroundColor(.red)
            } else {
                ZStack {
                    Circle().stroke(style: StrokeStyle(lineWidth: 2, dash: [5, 4])).foregroundColor(V6.hair).frame(width: 108, height: 108)
                    Text("A").font(.system(size: 22, weight: .bold)).foregroundColor(.white).frame(width: 52, height: 52).background(Circle().fill(V6.brand))
                    ForEach([CGPoint(x: 0, y: -50), CGPoint(x: -44, y: 34), CGPoint(x: 44, y: 34)], id: \.x) { pt in
                        Circle().strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3, 3])).foregroundColor(Color(white: 0.78))
                            .background(Circle().fill(V6.gray)).frame(width: 30, height: 30).offset(x: pt.x, y: pt.y)
                    }
                }
                .frame(height: 124)
                Text("Add friends to build your Group").font(.v6t17).foregroundColor(V6.ink)
                Text("Each friend you add is +1 entry. Check in together for a bonus entry — then one group wins tonight's party prize.")
                    .font(.v6t13).foregroundColor(V6.ink2).multilineTextAlignment(.center).padding(.top, -6)
                HStack(spacing: 8) {
                    Image(systemName: "pencil").foregroundColor(V6.ink2)
                    Text("My Crew").font(.v6t17).foregroundColor(V6.ink)
                    Spacer()
                }
                .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(V6.gray))
                Button { m.startParty() } label: {
                    HStack(spacing: 8) {
                        if m.lookingForFriends { ProgressView().tint(.white); Text("Looking for friends…") } else { Text("Start a Watch Party") }
                    }
                    .v6Primary()
                }
                .buttonStyle(V6Press())
                Text("Bluetooth only · No location data collected").font(.v6t13).foregroundColor(V6.ink2).padding(.top, -6)
                Text("Who can join").font(.v6t13b).foregroundColor(V6.ink2).frame(maxWidth: .infinity, alignment: .leading)
                V6Radio(on: true, title: "Anyone nearby can join", sub: "Bluetooth range is the gate — no request needed")
                V6Radio(on: false, title: "Approve each request", sub: "Fans ask first, you decide who's in")
                Button { m.toast("Opens your share sheet") } label: {
                    Label("Invite by link or QR", systemImage: "square.and.arrow.up").v6Button(fill: V6.brand10, text: V6.brand)
                }
                .buttonStyle(V6Press())
            }
        }
    }
}

private struct V6Radio: View {
    let on: Bool, title: String, sub: String
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().stroke(on ? V6.brand : V6.hair, lineWidth: 2)
                if on { Circle().fill(V6.brand).padding(5) }
            }
            .frame(width: 20, height: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.v6t17).foregroundColor(V6.ink)
                Text(sub).font(.v6t13).foregroundColor(V6.ink2)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).stroke(on ? V6.brand : V6.hair, lineWidth: 1.5))
    }
}

// MARK: - Version A: the store on the Season Rewards page

private struct V6StoreCards: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        HStack(spacing: 10) {
            ForEach(V6Data.store) { item in
                let got = m.redeemed.contains(item.name), av = m.available
                let progress = got ? 1 : min(1, Double(av) / Double(item.price))
                VStack(spacing: 6) {
                    ZStack {
                        Circle().stroke(V6.hair, lineWidth: 4)
                        Circle().trim(from: 0, to: progress).stroke(V6.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round)).rotationEffect(.degrees(-90))
                        Image(systemName: item.symbol).font(.system(size: 20)).foregroundColor(V6.brand)
                    }
                    .frame(width: 52, height: 52)
                    Text(item.name).font(.v6t13b).foregroundColor(V6.ink).multilineTextAlignment(.center).frame(minHeight: 34)
                    Text("\(item.price.formatted()) pts").font(.v6t13).foregroundColor(V6.ink2)
                    if got {
                        Label("Got it", systemImage: "checkmark").font(.v6t13b).foregroundColor(V6.ok).frame(height: 32)
                    } else if av >= item.price {
                        let confirm = m.confirmItem == item.name
                        Button { m.redeem(item) } label: {
                            Text(confirm ? "Confirm" : "Redeem").font(.v6t13b).foregroundColor(confirm ? .white : V6.brand)
                                .padding(.horizontal, 14).frame(height: 32).background(Capsule().fill(confirm ? V6.brand : V6.brand10))
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("\((item.price - av).formatted()) to go").font(.v6t13).foregroundColor(V6.ink2).frame(height: 32)
                    }
                }
                .padding(.vertical, 14).padding(.horizontal, 6)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            }
        }
    }
}

// MARK: - Same as today: the screens that open on top

private struct V6SheetClose: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        HStack {
            Spacer()
            Button { m.sheet = nil } label: {
                Image(systemName: "xmark").font(.system(size: 15, weight: .semibold)).foregroundColor(V6.ink)
                    .frame(width: 36, height: 36).background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
            }
        }
    }
}

private struct V6BarCard: View {
    @EnvironmentObject var m: V6Model
    let key: String
    var body: some View {
        let bar = V6Data.bars.first { $0.id == key }!
        let here = m.settled && m.venue == key, detected = m.moment == .at && m.venue == key
        ScrollViewReader { proxy in
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Spacer()
                        Button { m.sheet = nil } label: {
                            Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                                .frame(width: 32, height: 32).background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    Text(bar.name).font(.v6t22)
                    Text(bar.address).font(.v6t13).foregroundColor(V6.on2)
                    if m.duelNight, let i = V6Data.duel.firstIndex(of: key) {
                        let other = V6Data.venues[V6Data.duel[1 - i]]!.name
                        Label("Bar Duel vs \(other) · 2x points tonight", systemImage: "star.fill").font(.v6t13b).padding(.top, 4)
                    } else if key == "botg" {
                        Label("Bar of the Game · 2x points tonight", systemImage: "star.fill").font(.v6t13b).padding(.top, 4)
                    }
                    HStack(spacing: 8) {
                        V6Upvote(key: key, big: true)
                        if m.isStarter(key) { V6StarterChip(text: "You're in the Starting Five", onDark: true) }
                    }
                    .padding(.top, 8)
                }
                .foregroundColor(.white).padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(V6.brand)
                VStack(alignment: .leading, spacing: 12) {
                    if here {
                        Label("You're Checked In", systemImage: "checkmark").v6Button(fill: Color(white: 0.894), text: V6.ink2)
                    } else {
                        Button {
                            if detected { m.sheet = nil; m.checkIn() } else { m.sheet = nil; DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { m.sheet = .notAtSpot } }
                        } label: { Label(detected ? "Check In  +\(V6Data.venues[key] == nil ? 350 : m.venueInfo(key).pts)" : "Check In", systemImage: "mappin").v6Primary() }
                        .buttonStyle(V6Press())
                    }
                    HStack(spacing: 10) {
                        Button { m.directions(bar.name, to: bar.coordinate, open: openURL) } label: { Label("Directions", systemImage: "location.north.line").v6Button(fill: V6.brand10, text: V6.brand) }
                        Button { m.toast("Opens the bar's website") } label: { Label("Website", systemImage: "globe").v6Button(fill: V6.brand10, text: V6.brand) }
                    }
                    .buttonStyle(V6Press())
                    // one deal per bar, starters included (Will, 11-15); the Starting Five second deal is gone
                    Text(here ? "You're checked in — deal unlocked" : "Check in to unlock this deal")
                        .font(.v6t13).foregroundColor(V6.ink2)
                    V6DealPill(bar: bar, inCard: true)
                    V6StartingFive(key: key).id("s5").padding(.top, 12)
                    Text("GAMEDAY PRIZES").font(.v6t13b).foregroundColor(V6.ink2).padding(.top, 12)
                    V6PrizeRow(id: "fotg", drawn: m.moment == .after, inCard: true)
                }
                .padding(16)
            }
            .v6ScreenWidth()
        }
        .v6VerticalOnly()
        .onAppear {
            // opened from "You made it" or the lost-spot alert: go straight to the five
            guard m.focusFive else { return }
            m.focusFive = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { withAnimation(.easeInOut(duration: 0.5)) { proxy.scrollTo("s5", anchor: .top) } }
        }
        }
        .background(V6.gray)
        .overlay(alignment: .top) { if let t = m.toastText { Text(t).font(.v6t13b).foregroundColor(.white).padding(.horizontal, 16).padding(.vertical, 10).background(Capsule().fill(V6.ink)).padding(.top, 70) } }
    }
    @Environment(\.openURL) private var openURL
}

@available(iOS 16.0, *)
private struct V6PrizeDetail: View {
    @EnvironmentObject var m: V6Model
    let id: String
    var body: some View {
        let fotg = id == "fotg", entered = m.settled && (fotg || m.venue == "home"), wonIt = m.moment == .after && m.won && fotg
        VStack(alignment: .leading, spacing: 12) {
            V6SheetClose()
            Text("PRIZE").font(.v6t13b).foregroundColor(V6.ink2)
            Text(fotg ? V6Data.prize : "20% off at the Sixers Shop").font(.v6t22).foregroundColor(V6.brand)
            Divider()
            Label(wonIt ? "You won" : entered ? "You've Entered" : "Not entered yet", systemImage: wonIt ? "star.fill" : entered ? "checkmark.circle" : "circle")
                .font(.v6t13b).foregroundColor(wonIt || entered ? V6.ok : V6.ink2)
            Text(fotg ? "Every game, one checked-in fan wins exclusive 76ers fan gear. Check in at Xfinity Mobile Arena, any 76ers Meet Up Bar or a Home Watch Party during the game and you are entered."
                 : "Every fan in tonight's biggest Home Watch Party gets 20% off at the Sixers Shop.")
                .font(.v6t13).foregroundColor(V6.ink2)
            if wonIt {
                Button { m.sheet = nil; m.claim() } label: { Text("Claim your prize").v6Primary() }
            } else if entered {
                VStack(spacing: 6) {
                    Text("You're Entered!").font(.v6t22)
                    Text("You're in the draw for today's game").font(.v6t13)
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 22)
                .background(RoundedRectangle(cornerRadius: 16).fill(V6.green))
            } else if fotg && m.moment == .at {
                Button { m.sheet = nil; m.checkIn() } label: { Label("Check in at \(m.v.name)  +\(m.v.pts)", systemImage: "mappin").v6Primary() }
            } else if fotg && m.shownMode != .home {
                Button { m.sheet = nil; m.find() } label: { Label("I'm here now — find my spot", systemImage: "location.fill").v6Primary() }
            } else {
                Button { m.sheet = nil; m.scrollTarget = "hwp" } label: { Text("Go to Home Watch Party").v6Button(fill: V6.brand10, text: V6.brand) }
            }
            Spacer()
        }
        .padding(16)
        .background(V6.gray)
        .presentationDetents([.medium, .large])
    }
}

@available(iOS 16.0, *)
private struct V6DealSheet: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        let five = m.dealFive, deal = five ? m.starterDeal(m.venue) : m.v.deal
        VStack(spacing: 10) {
            V6SheetClose()
            Text(five ? "ANDY · STARTING FIVE" : "ANDY").font(.v6t13b).foregroundColor(five ? V6.brand : V6.ink2).padding(.top, 20)
            Text(deal).font(.v6t22).foregroundColor(V6.ink).multilineTextAlignment(.center)
            Text(m.venue == "arena" ? "Show this screen at any concession stand" : "Show this screen to the server").font(.v6t13).foregroundColor(V6.ink)
            Divider().padding(.vertical, 10)
            Text("STAFF").font(.v6t13b).foregroundColor(V6.ink2)
            Button {
                m.track(five ? "Staff confirmed the Starting Five deal" : "Staff confirmed the deal")
                m.sheet = nil
                if five {
                    // the second deal doesn't move the night along; the regular one is still there to use
                    m.usedFive.insert(m.venue)
                } else {
                    m.dealUsed = true
                    m.setMoment(.live)
                    m.scrollTarget = "top"
                }
                m.toast("Redeemed!")
            } label: {
                Label("Confirm: \(deal)", systemImage: "checkmark").font(.v6t17).foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 64).background(RoundedRectangle(cornerRadius: 16).fill(V6.green))
            }
            .buttonStyle(V6Press())
            Text("Tap above to mark this deal as used").font(.v6t13).foregroundColor(V6.ink2)
            Spacer()
        }
        .padding(16)
        .background(V6.gray)
        .presentationDetents([.medium])
    }
}

@available(iOS 16.0, *)
private struct V6NotAtSpot: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        VStack(spacing: 12) {
            V6SheetClose()
            Image(systemName: "mappin.slash").font(.system(size: 36)).foregroundColor(V6.ink)
            Text("Get to a 76ers Meet Up Bar").font(.v6t22).foregroundColor(V6.ink)
            Text("Check in during the game to unlock deals, enter gameday prize drops, and earn points toward our biggest prize of the season.")
                .font(.v6t13).foregroundColor(V6.ink2).multilineTextAlignment(.center)
            Button { m.sheet = nil; m.scrollTarget = "bars" } label: {
                Label("Find a 76ers Meet Up Bar", systemImage: "mappin").v6Button(fill: V6.brand10, text: V6.brand)
            }
            .buttonStyle(V6Press())
            Button { m.sheet = nil; m.mode = .bar; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { m.find() } } label: {
                Label("I'm at a bar — check me in", systemImage: "location.fill").v6Primary()
            }
            .buttonStyle(V6Press())
            Spacer()
        }
        .padding(16)
        .background(V6.gray)
        .presentationDetents([.medium])
    }
}

// one page, mostly pictures: the prize header, the same points card as home (its line opens the leaderboard), the road of rewards, then how to earn
private struct V6SeasonPage: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    @State private var picked: Int?
    @State private var showCheckIns = false
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Season Rewards").font(.v6t17)
                HStack {
                    Button { m.track("Closed Season Rewards"); m.showSeason = false } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                            Text("Back").font(.system(size: 17))
                        }
                    }
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12).frame(height: 44)
            .background(V6.navGradient.ignoresSafeArea(edges: .top))
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                    // points first (fans arrive by tapping their points card), then the grand prize as a prize card like
                    // Fan of the Game (Will, 11-15: the banner art read as decoration and people skipped it). v7_prize_banner stays in the assets.
                    VStack(spacing: 16) {
                        V6SeasonSlider(toRewards: { withAnimation(.easeInOut(duration: 0.4)) { proxy.scrollTo("status", anchor: .top) } })
                        // section headers like "How to earn points" (Will, 11-15): Grand Prize, then More rewards
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Grand Prize").font(.v6t17).foregroundColor(V6.ink)
                            grandPrizeCard
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("More rewards").font(.v6t17).foregroundColor(V6.ink)
                            road
                        }
                        .id("status")
                        if m.rewardsMode == .spend {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Points store · \(m.available.formatted()) to use").font(.v6t17).foregroundColor(V6.ink)
                                V6StoreCards()
                            }
                            .id("rewards")
                        }
                        earn
                    }
                    .padding(16).padding(.bottom, 24)
                    }
                    .v6ScreenWidth()
                }
                .v6VerticalOnly()
                .onAppear {
                    guard let a = m.seasonAnchor else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        withAnimation(.easeInOut(duration: 0.4)) { proxy.scrollTo(a, anchor: .top) }
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if m.testMode, let i = t.doing { V6TaskBanner(i: i) }
            }
        }
        .background(V6.gray.ignoresSafeArea())
    }

    // MARK: the grand prize, in the same layout as the Fan of the Game card on Tonight's Prizes
    private var grandPrizeCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                VStack(alignment: .leading, spacing: 6) {
                    Text(V6Data.grandPrize).font(.v6t17).multilineTextAlignment(.leading)
                    V6Pill(text: "TOP FAN WINS")
                }
                Spacer(minLength: 0)
            }
            HStack(alignment: .lastTextBaseline) {
                Text(m.isRanked(m.points) ? "You're #\(m.rank) of \(V6Data.fanCount.formatted())" : "Check in to get ranked").font(.v6t13).foregroundColor(V6.on2)
                Spacer()
                // small, like the line beside it (Will, 11-15)
                Text("Season ends \(V6Data.seasonEnds)").font(.v6t13).foregroundColor(V6.on2)
            }
            .padding(.top, 10)
            .overlay(alignment: .top) { Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1) }
        }
        .foregroundColor(.white).padding(18).v6Card()
        .accessibilityElement(children: .combine)
    }

    private var tiers: [(name: String, min: Int)] { V6Data.tiers }
    private var ti: Int { m.tierIndex(m.points) }
    // how far through the current status, 0...1
    private var through: Double {
        guard ti + 1 < tiers.count else { return 1 }
        return Double(m.points - tiers[ti].min) / Double(tiers[ti + 1].min - tiers[ti].min)
    }
    private func reward(_ i: Int) -> V6TitleReward? { m.rewardsMode == .unlock ? V6Data.titleRewards.first { $0.tier == i } : nil }
    // the reward waiting to be claimed, or else the next status
    private var defaultPick: Int {
        if m.rewardsMode == .unlock, let r = m.rewardToClaim { return r.tier }
        return min(ti + 1, tiers.count - 1)
    }

    // MARK: the road: one stop per status, each showing its reward; tap a stop to see it
    private var road: some View {
        let n = tiers.count, sel = picked ?? defaultPick
        let fill = (Double(ti) + (ti + 1 < n ? through : 0)) / Double(n - 1)
        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(tiers[ti].name).font(.v6t13b).foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 4).background(Capsule().fill(V6.brand))
                    Text([ti > 0 ? V6Data.tierShare[ti] : nil,
                          ti + 1 < n ? "\((tiers[ti + 1].min - m.points).formatted()) to \(tiers[ti + 1].name)" : nil]
                        .compactMap { $0 }.joined(separator: " · "))
                        .font(.v6t13).foregroundColor(V6.ink2)
                }
            }
            ZStack(alignment: .topLeading) {
                // the track runs from the first stop's centre to the last's
                GeometryReader { g in
                    let inset = g.size.width / CGFloat(n) / 2, w = g.size.width - inset * 2
                    Capsule().fill(V6.hair).frame(width: w, height: 4).offset(x: inset, y: 17)
                    Capsule().fill(V6.brand).frame(width: max(4, w * fill), height: 4).offset(x: inset, y: 17)
                }
                .frame(height: 38)
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0..<n, id: \.self) { i in
                        Button { m.track("Tapped status · \(tiers[i].name)"); withAnimation(.easeInOut(duration: 0.2)) { picked = i } } label: {
                            VStack(spacing: 4) {
                                stop(i, selected: sel == i)
                                Text(tiers[i].name).font(.system(size: 11, weight: .semibold)).foregroundColor(i <= ti ? V6.ink : V6.ink2)
                                    .lineLimit(1).minimumScaleFactor(0.7)
                                Text(tiers[i].min == 0 ? "Start" : tiers[i].min >= 10000 ? "\(tiers[i].min / 1000)K" : tiers[i].min.formatted())
                                    .font(.system(size: 11)).foregroundColor(V6.ink2)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            pickedRow(sel)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
    }

    // a plain stepper, no pictures: gold = reached with a reward waiting, blue = reached, outlined = next, gray = later
    private func stop(_ i: Int, selected: Bool) -> some View {
        let r = reward(i), reached = i <= ti, next = i == ti + 1
        let claimed = r.map { m.claimedRewards.contains($0.tier) } ?? false, ready = reached && r != nil && !claimed
        let fill: Color = ready ? V6.gold : reached ? V6.brand : next ? .white : V6.gray
        return ZStack {
            Circle().fill(fill)
            if next { Circle().stroke(V6.brand, lineWidth: 2) }
            if reached { Image(systemName: "checkmark").font(.system(size: 13, weight: .heavy)).foregroundColor(ready ? V6.ink : .white) }
        }
        .frame(width: 32, height: 32)
        .padding(3)
        .overlay(Circle().stroke(selected ? V6.brand.opacity(0.3) : Color.clear, lineWidth: 3))
    }

    // the one stop you tapped (or the one that matters now), in a single line
    @ViewBuilder private func pickedRow(_ i: Int) -> some View {
        let t = tiers[i], r = reward(i)
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(r?.name ?? t.name).font(.v6t17).foregroundColor(V6.ink)
                Text(r.map { "\(t.name) · \($0.left) of \($0.total) left" } ?? V6Data.tierShare[i]).font(.v6t13).foregroundColor(V6.ink2)
            }
            Spacer(minLength: 6)
            if let r, m.claimedRewards.contains(r.tier) {
                Label("Claimed", systemImage: "checkmark").font(.v6t13b).foregroundColor(V6.ok)
            } else if let r, i <= ti {
                Button { m.track("Tapped Claim · \(r.name)"); picked = r.tier; m.claimTitleReward(r) } label: {
                    Text("Claim").font(.v6t13b).foregroundColor(.white)
                        .padding(.horizontal, 20).frame(height: 36).background(Capsule().fill(V6.brand))
                }
                .buttonStyle(V6Press())
            } else if i <= ti {
                Image(systemName: "checkmark").font(.system(size: 14, weight: .heavy)).foregroundColor(V6.ok)
            } else {
                Text("\((t.min - m.points).formatted()) to go").font(.v6t13b).foregroundColor(V6.ink2)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 12).fill(V6.gray))
    }

    // MARK: ways to earn as a plain list (points lead each row, like How to earn points on home), then your check-ins folded away
    private var earn: some View {
        // Bar Duel nights add a way to earn: be checked in at the bar that wins
        let rows = [(m.duelNight ? "Bar of the Game or Bar Duel" : "Bar of the Game", 700, true), ("76ers Meet Up bar", 350, false)]
            + (m.duelNight ? [("Your bar wins a Bar Duel", V6Data.duelBonus, false)] : [])
            + [("Xfinity Mobile Arena", 500, false), ("Home Watch Party", 250, false), ("Create your free account", 150, false)]
        return VStack(alignment: .leading, spacing: 10) {
            Text("How to earn points").font(.v6t17).foregroundColor(V6.ink)
            VStack(spacing: 0) {
                ForEach(rows, id: \.0) { row in
                    HStack(spacing: 12) {
                        Text("+\(row.1)").font(.system(size: 16, weight: .bold)).monospacedDigit().foregroundColor(V6.brand)
                            .frame(width: 70, height: 34).background(Capsule().fill(V6.brand10))
                        Text(row.0).font(.v6t17).foregroundColor(V6.ink)
                        if row.2 {
                            Text("2x").font(.v6t13b).foregroundColor(V6.ink).padding(.horizontal, 8).padding(.vertical, 3).background(Capsule().fill(V6.gold))
                        }
                        Spacer()
                    }
                    .padding(12)
                    .overlay(alignment: .bottom) { if row.0 != rows.last?.0 { Rectangle().fill(V6.hair).frame(height: 1).padding(.leading, 94) } }
                }
            }
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            Button {
                m.track(showCheckIns ? "Closed My check-ins" : "Opened My check-ins")
                withAnimation(.easeInOut(duration: 0.25)) { showCheckIns.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Text("My check-ins")
                    Image(systemName: "chevron.down").rotationEffect(.degrees(showCheckIns ? 0 : -90))
                }
                .font(.v6t13b).foregroundColor(V6.brand).padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            if showCheckIns { history }
        }
    }

    private var history: some View {
        let rows = [("Nov 6", "My Crew · Home Watch Party", "+250"), ("Nov 4", "Moriarty's", "+350"), ("Oct 30", "Garage Fishtown · Bar of the Game", "+700"),
                    ("Oct 22", "Garage Rittenhouse", "+350"), ("Oct 18", "Signed up", "+150")]
        return VStack(spacing: 0) {
            ForEach(rows, id: \.1) { r in
                HStack(spacing: 8) {
                    Text(r.0).font(.v6t13).foregroundColor(V6.ink2).frame(width: 48, alignment: .leading)
                    Text(r.1).font(.v6t13).foregroundColor(V6.ink)
                    Spacer()
                    Text(r.2).font(.v6t13b).foregroundColor(V6.ink)
                }
                .padding(12)
                .overlay(alignment: .bottom) { if r.1 != rows.last?.1 { Rectangle().fill(V6.hair).frame(height: 1) } }
            }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
    }
}

private struct V6Profile: View {
    @EnvironmentObject var m: V6Model
    private var profileRewards: [(String, String)] {
        var rows = [("Exclusive 76ers Fan Gear", "Won Nov 2 · Claim")]
        if m.rewardsMode == .spend { rows.append(("Rally towel", "Redeemed · Nov 6")) }
        else { rows += V6Data.titleRewards.filter { m.claimedRewards.contains($0.tier) }.map { ($0.name, "Claimed tonight") } }
        return rows
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                V6SheetClose()
                Text("A").font(.system(size: 26, weight: .bold)).foregroundColor(.white).frame(width: 64, height: 64).background(Circle().fill(V6.brand))
                Text("Andy").font(.v6t22).foregroundColor(V6.ink)
                let ti = m.tierIndex(m.points)
                Text("\(V6Data.tiers[ti].name) · \(m.points.formatted()) pts").font(.v6t13b)
                .foregroundColor(V6.brand)
                .padding(.horizontal, 12).padding(.vertical, 6).background(Capsule().fill(V6.brand10))
                ForEach(m.starterBars, id: \.self) { k in
                    V6StarterChip(text: "Starting Five · \(m.barName(k))")
                }
                Text("(215) 555-0147").font(.v6t13).foregroundColor(V6.ink2)
                Text("MY REWARDS").font(.v6t13b).foregroundColor(V6.ink2).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                V6List(rows: profileRewards)
                V6List(rows: [("Manage Permissions", ""), ("Terms of Use", ""), ("Privacy Policy", ""), ("Log out", "")])
                Text("Delete account").font(.v6t17).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                Text("Version 4.3.0").font(.v6t13).foregroundColor(V6.ink2)
            }
            .padding(16)
        }
        .background(V6.gray)
    }
}

private struct V6List: View {
    let rows: [(String, String)]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.0) { r in
                HStack { Text(r.0).font(.v6t17).foregroundColor(V6.ink); Spacer(); Text(r.1).font(.v6t13).foregroundColor(V6.ink2) }
                    .padding(14)
                    .overlay(alignment: .bottom) { Rectangle().fill(V6.hair).frame(height: 1) }
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
    }
}

private struct V6FanMessage: View {
    @EnvironmentObject var m: V6Model
    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea().onTapGesture { m.showFanMessage = false }
            VStack(spacing: 10) {
                HStack { Spacer(); Button { m.showFanMessage = false } label: { Image(systemName: "xmark").foregroundColor(V6.ink).font(.system(size: 14, weight: .semibold)) } }
                Image(systemName: "gift").font(.system(size: 26)).foregroundColor(V6.brand).frame(width: 56, height: 56).background(Circle().fill(V6.brand10))
                Text("You have a prize to claim").font(.v6t22).foregroundColor(V6.ink)
                Text("Your Exclusive 76ers Fan Gear from Nov 2 is waiting. Claim it before it expires.").font(.v6t13).foregroundColor(V6.ink2).multilineTextAlignment(.center)
                Button { m.showFanMessage = false; m.claim() } label: { Text("Claim").v6Primary() }.buttonStyle(V6Press())
                Button("Later") { m.showFanMessage = false }.font(.v6t17).foregroundColor(V6.brand).padding(6)
            }
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .padding(24)
        }
    }
}

// MARK: - New (second release): the new fan status screen and the share card

// a fan status is drawn as the reward it unlocks; Rookie, with none, as a player
private struct V6StatusIcon: View {
    let tier: Int
    var size: CGFloat
    var body: some View {
        Image(systemName: V6Data.titleRewards.first { $0.tier == tier }?.symbol ?? "figure.basketball")
            .font(.system(size: size, weight: .semibold))
    }
}

private struct V6LevelUp: View {
    @EnvironmentObject var m: V6Model
    let tier: Int
    var body: some View {
        let t = V6Data.tiers[tier], next = tier + 1 < V6Data.tiers.count ? V6Data.tiers[tier + 1] : nil
        ZStack {
            RadialGradient(colors: [Color(red: 21 / 255, green: 89 / 255, blue: 220 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)],
                           center: .init(x: 0.5, y: 0.58), startRadius: 10, endRadius: 520)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Image("v6_header").resizable().scaledToFit()
                Spacer()
                V6StatusIcon(tier: tier, size: 38).foregroundColor(.white)
                    .frame(width: 96, height: 96).background(Circle().fill(Color.white.opacity(0.18)))
                    .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 10).padding(-10))
                    .padding(.bottom, 14)
                Text("New fan status").font(.v6t13b).foregroundColor(V6.on2)
                Text(t.name).font(.system(size: 48, weight: .bold))
                Text("Nice one, Andy.").font(.v6t17)
                Text("Tonight at \(m.venue == "home" ? "your Home Watch Party" : m.v.name) took you to \(m.points.formatted()) points. You're in the \(V6Data.tierShare[tier].lowercased()).\(next.map { " \(($0.min - m.points).formatted()) more to \($0.name)." } ?? "")")
                    .font(.v6t13).foregroundColor(V6.on2).multilineTextAlignment(.center).padding(.horizontal, 30)
                if m.rewardsMode == .unlock, let r = V6Data.titleRewards.first(where: { $0.tier == tier }) {
                    Label("Unlocked: \(r.name) · \(r.left) left", systemImage: "gift.fill").font(.v6t13b).foregroundColor(V6.brand)
                        .padding(.horizontal, 14).padding(.vertical, 8).background(Capsule().fill(Color.white)).padding(.top, 6)
                }
                VStack(spacing: 12) {
                    Button { m.track("Tapped Share my status"); m.showShare = true } label: { Label("Share my status", systemImage: "square.and.arrow.up").v6Button(fill: .white, text: V6.brand) }
                    Button { m.track("Tapped Keep going"); m.levelUpTier = nil } label: { Text("Keep going").v6Button(fill: Color.white.opacity(0.18), text: .white) }
                }
                .buttonStyle(V6Press())
                .padding(.horizontal, 40).padding(.top, 14)
                Spacer()
            }
            .foregroundColor(.white)
        }
    }
}

private struct V6ShareCardFace: View {
    let tier: Int
    let points: Int
    let rank: Int
    let place: String
    var body: some View {
        VStack(spacing: 0) {
            Image("v6_header").resizable().scaledToFill().frame(width: 270, height: 150).clipped()
            V6StatusIcon(tier: tier, size: 22).foregroundColor(.white).frame(width: 54, height: 54).background(Circle().fill(Color.white.opacity(0.18)))
            Text("Andy").font(.system(size: 44, weight: .bold)).padding(.top, 10)
            Text("just became a").font(.v6t13).foregroundColor(V6.on2).padding(.top, 2)
            V6Pill(text: V6Data.tiers[tier].name).padding(.top, 6)
            HStack(spacing: 6) {
                V6RecapNum(big: points.formatted(), label: "Season points")
                V6RecapNum(big: "#\(rank)", label: "Standing")
            }
            .padding(.horizontal, 14).padding(.top, 12)
            Text("Earned tonight at \(place) · Nov 9").font(.v6t13).foregroundColor(V6.on2).multilineTextAlignment(.center).padding(.horizontal, 14).padding(.top, 10)
            Spacer(minLength: 10)
            HStack(spacing: 8) {
                Image("v6_tile").resizable().scaledToFit().frame(width: 22, height: 22)
                Text("Check in with me at 76ers Meet Up").font(.v6t13b)
            }
            .frame(maxWidth: .infinity).padding(10).background(Color.black.opacity(0.2))
        }
        .foregroundColor(.white)
        .frame(width: 270, height: 480)
        .background(LinearGradient(colors: [Color(red: 4 / 255, green: 34 / 255, blue: 215 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

@available(iOS 16.0, *)
private struct V6ShareCard: View {
    @EnvironmentObject var m: V6Model
    let tier: Int
    @State private var rendered: Image?
    var body: some View {
        let face = V6ShareCardFace(tier: tier, points: m.points, rank: m.rank, place: m.venue == "home" ? "Andy's Home Watch Party" : m.v.name)
        ZStack {
            Color(red: 6 / 255, green: 10 / 255, blue: 22 / 255).opacity(0.94).ignoresSafeArea()
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button { m.showShare = false } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            .frame(width: 32, height: 32).background(Circle().fill(Color.white.opacity(0.18)))
                    }
                }
                Text("Your card").font(.v6t13b).foregroundColor(V6.on2)
                face.shadow(color: .black.opacity(0.45), radius: 22, y: 12)
                if let rendered {
                    ShareLink(item: rendered, preview: SharePreview("Andy is a \(V6Data.tiers[tier].name)", image: rendered)) {
                        Label("Share", systemImage: "square.and.arrow.up").v6Button(fill: .white, text: V6.brand)
                    }
                    .padding(.horizontal, 50)
                }
            }
            .padding(20)
        }
        .onAppear {
            let r = ImageRenderer(content: face)
            r.scale = 3
            if let ui = r.uiImage { rendered = Image(uiImage: ui) }
        }
    }
}

// MARK: - New: Starting Five — each bar's top five fans by visits, the Starter badge, "You made it" and the lost-spot alert

private func v6Initials(_ f: V6Model.FiveRow) -> String {
    if f.you { return "A" }
    if f.name == "Mystery Fan" { return "?" }
    return f.name.split(separator: " ").compactMap { $0.first.map(String.init) }.joined()
}

// the badge: just says you're part of that bar's Starting Five; it shows wherever your name does (leaderboard, profile, the bar's row and page)
private struct V6StarterChip: View {
    let text: String
    var onDark = false
    var body: some View {
        Text(text).font(.system(size: 12, weight: .bold)).lineLimit(1)
        .foregroundColor(.white)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Capsule().fill(onDark ? Color.white.opacity(0.18) : V6.strip))
        .fixedSize()
    }
}

// on the bar's page: the same score card and rows as the Fan Leaderboard, counting visits instead of points
private struct V6StartingFive: View {
    @EnvironmentObject var m: V6Model
    let key: String
    var body: some View {
        let ranked = m.ranked(key), five = Array(ranked.prefix(5)), me = m.lineup(key).first { $0.you }!
        let rank = m.fiveRank(key), starter = m.isStarter(key)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text("Starting Five").font(.v6t22).foregroundColor(V6.ink)
                Spacer()
                Text("Most visits this season").font(.v6t13).foregroundColor(V6.ink2)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("YOUR VISITS").font(.system(size: 11, weight: .bold)).foregroundColor(V6.on2)
                        Text("\(me.visits)").font(.system(size: 40, weight: .bold)).monospacedDigit()
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("RANK").font(.system(size: 11, weight: .bold)).foregroundColor(V6.on2)
                        Text(rank.map { "#\($0)" } ?? "—").font(.system(size: 40, weight: .bold)).monospacedDigit()
                        Text("of \(V6Data.barFanCount[key] ?? 0) fans here").font(.v6t13).foregroundColor(V6.on2)
                    }
                }
                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1)
                HStack(spacing: 8) {
                    Image(systemName: starter ? "person.3.fill" : "figure.walk").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    line(ranked, me.visits).font(.v6t13b)
                }
            }
            .foregroundColor(.white).padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(V6.brand))
            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { i in
                    if i < five.count { row(i + 1, five[i]) } else { openRow(i + 1) }
                }
                if !starter {
                    V6.gray.frame(height: 8)
                    row(rank, me)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            Text("One visit counts per game. Ties go to whoever got there first. Fans show as first name and last initial, or Mystery Fan.")
                .font(.v6t13).foregroundColor(V6.ink2)
        }
    }

    private func line(_ ranked: [V6Model.FiveRow], _ mine: Int) -> Text {
        if let r = m.fiveRank(key), r <= 5 {
            guard r > 1 else { return Text("You're #1 here. Hold your spot!") }
            let above = ranked[r - 2], n = above.visits - mine + 1
            return Text("You're in the Starting Five") + Text(" · \(n) \(n == 1 ? "visit" : "visits") to pass \(above.name)").foregroundColor(V6.on2)
        }
        let n = m.visitsToFive(key), open = ranked.filter { !$0.you }.count < 5
        let v = mine == 0 ? "\(n) visits" : n == 1 ? "One more visit" : "\(n) more visits"
        return Text(open ? "\(v) \(n == 1 ? "gets" : "get") you a spot" : "\(v) \(n == 1 ? "takes" : "take") the #5 spot")
    }

    private func row(_ rank: Int?, _ f: V6Model.FiveRow) -> some View {
        HStack(spacing: 12) {
            Text(rank.map(String.init) ?? "—").font(.v6t13b).foregroundColor(f.you ? .white : V6.ink2).frame(width: 22, alignment: .leading)
            Text(v6Initials(f)).font(.system(size: 12, weight: .bold)).foregroundColor(V6.brand)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 8).fill(f.you ? Color.white : V6.brand10))
            Text(f.you ? "You" : f.name).font(f.you ? .v6t17 : .system(size: 17)).foregroundColor(f.you ? .white : V6.ink)
            Spacer()
            Text("\(f.visits) \(f.visits == 1 ? "visit" : "visits")").font(f.you ? .v6t13b : .v6t13).foregroundColor(f.you ? .white : V6.ink2)
        }
        .padding(.horizontal, 14).frame(height: 52)
        .background(f.you ? V6.brand : Color.white)
        .overlay(alignment: .bottom) { Rectangle().fill(V6.hair).frame(height: 1) }
    }

    private func openRow(_ rank: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)").font(.v6t13b).foregroundColor(V6.ink2).frame(width: 22, alignment: .leading)
            Image(systemName: "plus").font(.system(size: 13, weight: .bold)).foregroundColor(V6.ink2)
                .frame(width: 34, height: 34)
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(V6.ink2.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])))
            Text("Open spot").font(.system(size: 17)).foregroundColor(V6.ink2)
            Spacer()
            Text("2 visits gets you in").font(.v6t13).foregroundColor(V6.ink2)
        }
        .padding(.horizontal, 14).frame(height: 52)
        .background(Color.white)
        .overlay(alignment: .bottom) { Rectangle().fill(V6.hair).frame(height: 1) }
    }
}

// the five as faces in a row, yours ringed in gold
private struct V6FiveFaces: View {
    let five: [V6Model.FiveRow]
    var pop = true
    var size: CGFloat = 50
    var body: some View {
        HStack(alignment: .top, spacing: size * 0.2) {
            ForEach(0..<5, id: \.self) { i in
                VStack(spacing: size < 44 ? 10 : 13) {
                    if i < five.count {
                        let f = five[i]
                        Text(v6Initials(f)).font(.system(size: size * 0.32, weight: .bold))
                            .foregroundColor(f.you ? V6.brand : .white)
                            .frame(width: size, height: size)
                            .background(Circle().fill(f.you ? Color.white : Color.white.opacity(0.18)))
                            .overlay(Circle().stroke(V6.gold, lineWidth: f.you ? 3 : 0).padding(-4))
                            .scaleEffect(f.you && pop ? 1.12 : 1)
                        Text(f.you ? "You" : f.name.components(separatedBy: " ").first ?? f.name)
                            .font(.system(size: size < 44 ? 10 : 11, weight: .bold)).foregroundColor(f.you ? .white : V6.on2).lineLimit(1)
                    } else {
                        Circle().strokeBorder(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])).frame(width: size, height: size)
                        Text("Open").font(.system(size: size < 44 ? 10 : 11, weight: .bold)).foregroundColor(V6.on2)
                    }
                }
                .frame(width: size + 8)
            }
        }
    }
}

// the moment a visit takes a spot: the same full screen as a new fan status
private struct V6StarterUp: View {
    @EnvironmentObject var m: V6Model
    let key: String
    @State private var pop = false
    var body: some View {
        let five = Array(m.ranked(key).prefix(5)), rank = m.fiveRank(key) ?? 5, name = m.barName(key)
        ZStack {
            RadialGradient(colors: [Color(red: 21 / 255, green: 89 / 255, blue: 220 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)],
                           center: .init(x: 0.5, y: 0.58), startRadius: 10, endRadius: 520)
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Image("v6_header").resizable().scaledToFit()
                Spacer()
                V6FiveFaces(five: five, pop: pop).padding(.bottom, 14)
                Text("\(name) · Starting Five").font(.v6t13b).foregroundColor(V6.on2)
                Text("You made it").font(.system(size: 48, weight: .bold))
                Text("Nice one, Andy. You're #\(rank).").font(.v6t17)
                Text("\(m.myVisits(key)) visits this season. Your name is on \(name)'s page now. Keep coming back to hold your spot.")
                    .font(.v6t13).foregroundColor(V6.on2).multilineTextAlignment(.center).padding(.horizontal, 30)
                VStack(spacing: 12) {
                    Button { m.track("Tapped Share my spot"); m.showStarterShare = true } label: {
                        Label("Share it", systemImage: "square.and.arrow.up").v6Button(fill: .white, text: V6.brand)
                    }
                    Button { m.track("Tapped See the Starting Five"); m.starterUp = nil; m.focusFive = true; m.sheet = .bar(key) } label: {
                        Text("See the Starting Five").v6Button(fill: Color.white.opacity(0.18), text: .white)
                    }
                }
                .buttonStyle(V6Press())
                .padding(.horizontal, 40).padding(.top, 14)
                Button { m.track("Tapped Keep going"); m.starterUp = nil } label: { Text("Keep going").font(.v6t17).foregroundColor(.white).padding(8) }
                Spacer()
            }
            .foregroundColor(.white)
        }
        .onAppear { withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.3)) { pop = true } }
    }
}

private struct V6StarterShareFace: View {
    let bar: String
    let rank: Int
    let visits: Int
    let five: [V6Model.FiveRow]
    var body: some View {
        VStack(spacing: 0) {
            Image("v6_header").resizable().scaledToFill().frame(width: 270, height: 150).clipped()
            V6FiveFaces(five: five, size: 36).padding(.top, 14)
            Text("Andy").font(.system(size: 44, weight: .bold)).padding(.top, 6)
            Text("made the Starting Five at").font(.v6t13).foregroundColor(V6.on2).padding(.top, 2)
            V6Pill(text: bar).padding(.top, 6)
            HStack(spacing: 6) {
                V6RecapNum(big: "#\(rank)", label: "Spot")
                V6RecapNum(big: "\(visits)", label: "Visits")
            }
            .padding(.horizontal, 14).padding(.top, 12)
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                Image("v6_tile").resizable().scaledToFit().frame(width: 22, height: 22)
                Text("Check in with me at 76ers Meet Up").font(.v6t13b)
            }
            .frame(maxWidth: .infinity).padding(10).background(Color.black.opacity(0.2))
        }
        .foregroundColor(.white)
        .frame(width: 270, height: 480)
        .background(LinearGradient(colors: [Color(red: 4 / 255, green: 34 / 255, blue: 215 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

@available(iOS 16.0, *)
private struct V6StarterShare: View {
    @EnvironmentObject var m: V6Model
    let key: String
    @State private var rendered: Image?
    var body: some View {
        let face = V6StarterShareFace(bar: m.barName(key), rank: m.fiveRank(key) ?? 5, visits: m.myVisits(key), five: Array(m.ranked(key).prefix(5)))
        ZStack {
            Color(red: 6 / 255, green: 10 / 255, blue: 22 / 255).opacity(0.94).ignoresSafeArea()
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button { m.showStarterShare = false } label: {
                        Image(systemName: "xmark").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            .frame(width: 32, height: 32).background(Circle().fill(Color.white.opacity(0.18)))
                    }
                }
                Text("Your card").font(.v6t13b).foregroundColor(V6.on2)
                face.shadow(color: .black.opacity(0.45), radius: 22, y: 12)
                if let rendered {
                    ShareLink(item: rendered, preview: SharePreview("Andy made the \(m.barName(key)) Starting Five", image: rendered)) {
                        Label("Share", systemImage: "square.and.arrow.up").v6Button(fill: .white, text: V6.brand)
                    }
                    .padding(.horizontal, 50)
                }
            }
            .padding(20)
        }
        .onAppear {
            let r = ImageRenderer(content: face)
            r.scale = 3
            if let ui = r.uiImage { rendered = Image(uiImage: ui) }
        }
    }
}

// MARK: - Small pieces

private struct V6Pill: View {
    let text: String
    var dot = false
    var fill: Color = Color.white.opacity(0.18)
    @State private var pulse = false
    var body: some View {
        HStack(spacing: 6) {
            if dot {
                Circle().fill(Color.white).frame(width: 6, height: 6).opacity(pulse ? 0.3 : 1)
                    .onAppear { withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulse = true } }
            }
            Text(text).font(.v6t13b)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(Capsule().fill(fill))
    }
}

private struct V6Countdown: View {
    let prefix: String
    let to: Date
    let symbol: String?
    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { ctx in
            let s = max(0, Int(to.timeIntervalSince(ctx.date)))
            let h = s / 3600, mnt = (s % 3600) / 60, sec = s % 60
            let txt = h > 0 ? String(format: "%d:%02d:%02d", h, mnt, sec) : String(format: "%d:%02d", mnt, sec)
            HStack(spacing: 4) {
                if let symbol { Image(systemName: symbol) }
                Text(prefix + txt).monospacedDigit()
            }
        }
    }
}

// motion for the next step's button: a light sweep about every 2.6 s (half of it off-screen, so it pauses) and a slow 2% breath; off with Reduce Motion
private struct V6Alive: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var sweep = false
    @State private var breathe = false
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { g in
                    LinearGradient(colors: [.clear, Color.white.opacity(0.38), .clear], startPoint: .leading, endPoint: .trailing)
                        .frame(width: g.size.width * 0.3, height: g.size.height * 2)
                        .rotationEffect(.degrees(18))
                        .offset(x: sweep ? g.size.width * 2.2 : -g.size.width * 0.6, y: -g.size.height * 0.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .allowsHitTesting(false)
            )
            .scaleEffect(breathe ? 1.02 : 1)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 2.6).delay(0.5).repeatForever(autoreverses: false)) { sweep = true }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { breathe = true }
            }
    }
}

private struct V6Press: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

private extension View {
    // a vertical scroll page's content is exactly the screen's width, so nothing on it can make the page pan sideways
    // (on a Pro Max the home and Season Rewards pages could be dragged left and right)
    func v6ScreenWidth() -> some View { frame(width: UIScreen.main.bounds.width) }
    @ViewBuilder func v6VerticalOnly() -> some View {
        if #available(iOS 16.4, *) { self.scrollBounceBehavior(.basedOnSize, axes: [.horizontal]) } else { self }
    }
    func v6Primary() -> some View {
        self.font(.v6t17).foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(RoundedRectangle(cornerRadius: 14).fill(V6.brand))
            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
    }
    func v6Button(fill: Color, text: Color) -> some View {
        self.font(.v6t17).foregroundColor(text)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(RoundedRectangle(cornerRadius: 14).fill(fill))
    }
    func v6Card() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(V6.brand))
            .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }
}

// MARK: - User test: a task list, one task at a time, two questions after each; answers stay on this phone

private enum V6TaskID: String, CaseIterable, Codable {
    case welcome, bar, botg, arena, home, season, after, off, compare, compareTypical
    var isCompare: Bool { self == .compare || self == .compareTypical }

    var title: String {
        switch self {
        case .welcome: return "Getting started"
        case .bar: return "Check in at a bar"
        case .botg: return "Pick a bar for tonight"
        case .arena: return "At the arena"
        case .home: return "Watching at home"
        case .season: return "Your season"
        case .after: return "After the game"
        case .off: return "No game today"
        case .compare: return "Pick a card"
        case .compareTypical: return "Pick a card again"
        }
    }

    // written as situations, not instructions, so the wording doesn't point at the button
    var prompt: String {
        switch self {
        case .welcome: return "It's game night. You're at Garage Fishtown, a 76ers Meet Up bar, and just downloaded the 76ers Meet Up app. Get set up and get your points for being here."
        case .bar: return "It's game night and you just walked into O'Neals Pub, a 76ers Meet Up bar. Get your points for being there, then get the drink deal."
        case .botg: return "You haven't left the house yet. Find tonight's official Bar of the Game and get directions there."
        case .arena: return "You just sat down at Xfinity Mobile Arena for tonight's game. Get your points for being there."
        case .home: return "Two friends came over to watch the game at your place. Get points for watching together."
        case .season: return "Find out what the top fan wins this season and where you rank. Then get a reward."
        case .after: return "The game just ended. Did you win anything tonight? If you did, claim it."
        case .off: return "There's no game today. Look around. What would you do in the app before tomorrow's game?"
        case .compare: return "We'll show you two versions of the blue card at the top of the home screen. Pick the one that would make you more likely to go to the next game."
        case .compareTypical: return "Now imagine you've only been to two games this season. We'll show you the two cards again. Pick the one that would make you more likely to go to the next game."
        }
    }
}

private struct V6Result: Codable {
    let task: V6TaskID
    let finished: Bool
    let goalMet: Bool?
    let seconds: Int
    let ease: Int
    let note: String
    let trail: [String]
    let at: Date
    var version: V6RewardsMode?
    var card: V6CardMode?
    var pick: V6CardMode?
}

private struct V6TestStore: Codable {
    var tester = ""
    var results: [V6Result] = []
    var version: V6RewardsMode?
    var card: V6CardMode?
}

@MainActor
private final class V6Test: ObservableObject {
    enum Phase: Equatable { case list, intro(Int), doing(Int), questions(Int), allDone, results }
    static let key = "v6UserTest"
    static let faces = ["😣", "🙁", "😐", "🙂", "😄"]
    static let easeNames = ["Very hard", "Hard", "OK", "Easy", "Very easy"]

    let tasks = V6TaskID.allCases
    @Published var phase: Phase = .list
    @Published var tester: String { didSet { save() } }
    @Published var results: [V6Result] { didSet { save() } }
    @Published var version: V6RewardsMode { didSet { save() } }
    @Published var card: V6CardMode { didSet { save() } }
    private(set) var pending: (finished: Bool, goalMet: Bool?, seconds: Int, trail: [String])?
    private var picked: V6CardMode?
    private var startedAt = Date()

    init() {
        let store = UserDefaults.standard.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(V6TestStore.self, from: $0) } ?? V6TestStore()
        tester = store.tester
        results = store.results
        version = store.version ?? .unlock
        card = store.card ?? .auto
    }

    private func save() {
        if let data = try? JSONEncoder().encode(V6TestStore(tester: tester, results: results, version: version, card: card)) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    var doing: Int? { if case .doing(let i) = phase { return i }; return nil }
    var nextIndex: Int { tasks.firstIndex { result($0) == nil } ?? 0 }
    // answers saved before versions existed were all the points store, with today's status-first card
    func result(_ task: V6TaskID, _ v: V6RewardsMode? = nil, _ c: V6CardMode? = nil) -> V6Result? {
        results.first { $0.task == task && ($0.version ?? .spend) == (v ?? version) && ($0.card ?? .status) == (c ?? card) }
    }
    // every version a task was run with, for the answers screen and the report
    func runs(_ task: V6TaskID) -> [V6Result] {
        [V6RewardsMode.unlock, .spend].flatMap { v in [V6CardMode.auto, .status, .rank].compactMap { result(task, v, $0) } }
    }
    static func label(_ r: V6Result) -> String {
        (r.version == .unlock ? "Milestones" : "Points store") + " · " + (r.card == .rank ? "rank card" : r.card == .auto ? "auto card" : "status card")
    }

    func open(_ i: Int, _ m: V6Model) { m.rewardsMode = version; m.cardMode = card; m.startTest(tasks[i]); phase = .intro(i) }
    func start(_ i: Int, _ m: V6Model) {
        m.trail = []; startedAt = Date(); phase = .doing(i)
        if tasks[i] == .welcome { m.showWelcome = true }
    }

    func finish(_ i: Int, finished: Bool, _ m: V6Model) {
        pending = (finished, m.goalMet(tasks[i]), Int(Date().timeIntervalSince(startedAt)), m.trail)
        m.closeOverlays()
        phase = .questions(i)
    }

    // the side-by-side task ends with a pick instead of "I did it"
    func pick(_ i: Int, _ c: V6CardMode) {
        pending = (true, nil, Int(Date().timeIntervalSince(startedAt)), ["Picked the \(c == .rank ? "rank" : "status") card"])
        picked = c
        phase = .questions(i)
    }

    func answer(_ i: Int, ease: Int, note: String, _ m: V6Model) {
        if let p = pending {
            results.removeAll { $0.task == tasks[i] && ($0.version ?? .spend) == version && ($0.card ?? .status) == card }
            results.append(V6Result(task: tasks[i], finished: p.finished, goalMet: p.goalMet, seconds: p.seconds, ease: ease,
                                    note: note.trimmingCharacters(in: .whitespacesAndNewlines), trail: p.trail, at: Date(),
                                    version: version, card: card, pick: picked))
        }
        pending = nil; picked = nil
        if i + 1 < tasks.count { open(i + 1, m) } else { phase = .allDone }
    }

    func backToList(_ m: V6Model) { m.closeOverlays(); pending = nil; phase = .list }
    func clear() { results = []; tester = "" }

    static func time(_ s: Int) -> String { s < 60 ? "\(s)s" : "\(s / 60)m \(s % 60)s" }

    var report: String {
        var lines = ["76ers Meet Up · user test" + (tester.isEmpty ? "" : " · \(tester)"), ""]
        for (i, task) in tasks.enumerated() {
            let runs = runs(task)
            if runs.isEmpty { lines.append("\(i + 1). \(task.title): not done"); continue }
            lines.append("\(i + 1). \(task.title)")
            for r in runs {
                let goal = r.goalMet.map { $0 ? "reached the goal" : "didn't reach the goal" } ?? "no set goal"
                if let c = r.pick {
                    lines.append("   \(Self.label(r)) · picked the \(c == .rank ? "RANK" : "STATUS") card · \(Self.time(r.seconds))")
                } else {
                    lines.append("   \(Self.label(r)) · \(r.finished ? "Said done" : "Got stuck") · \(goal) · \(Self.time(r.seconds)) · \(Self.easeNames[r.ease - 1])")
                }
                if !r.note.isEmpty { lines.append("   \"\(r.note)\"") }
                if !r.trail.isEmpty { lines.append("   Taps: " + r.trail.joined(separator: " → ")) }
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
}

@available(iOS 16.0, *)
private struct V6TestOverlay: View {
    @EnvironmentObject var t: V6Test
    var onClose: () -> Void
    var body: some View {
        switch t.phase {
        case .list: V6TestList(onClose: onClose)
        case .intro(let i): V6TaskIntro(i: i)
        case .doing(let i):
            if t.tasks[i].isCompare { V6CompareCards(i: i, persona: t.tasks[i] == .compareTypical ? V6Data.typicalFan : nil) } else { EmptyView() }
        case .questions(let i): V6TaskQuestions(i: i)
        case .allDone: V6TestAllDone()
        case .results: V6TestResults()
        }
    }
}

@available(iOS 16.0, *)
private struct V6TestList: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    var onClose: () -> Void
    var body: some View {
        let allDone = t.tasks.allSatisfy { t.result($0) != nil }
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image("v6_tile").resizable().scaledToFit().frame(width: 44, height: 44).clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                    Button("Close") { onClose() }.font(.v6t17).foregroundColor(V6.brand)
                }
                Text("Help us test the 76ers Meet Up app").font(.v6t24).foregroundColor(V6.ink)
                Text("You'll try \(t.tasks.count) short tasks. There are no wrong answers. We're testing the app, not you, so say what you're thinking as you go.")
                    .font(.system(size: 17)).foregroundColor(V6.ink2)
                TextField("Your first name", text: $t.tester)
                    .font(.system(size: 17)).textInputAutocapitalization(.words).disableAutocorrection(true)
                    .padding(14).background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                VStack(spacing: 0) {
                    ForEach(Array(t.tasks.enumerated()), id: \.offset) { i, task in
                        let r = t.result(task)
                        Button { t.open(i, m) } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(r == nil ? V6.brand10 : V6.ok)
                                    if r == nil {
                                        Text("\(i + 1)").font(.v6t13b).foregroundColor(V6.brand)
                                    } else {
                                        Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy)).foregroundColor(.white)
                                    }
                                }
                                .frame(width: 28, height: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title).font(.v6t17).foregroundColor(V6.ink)
                                    if let r {
                                        Text(r.pick.map { "Picked the \($0 == .rank ? "rank" : "status") card" }
                                             ?? "\(V6Test.faces[r.ease - 1]) \(V6Test.easeNames[r.ease - 1]) · \(r.finished ? "did it" : "got stuck")")
                                            .font(.v6t13).foregroundColor(V6.ink2)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(white: 0.78))
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                            .overlay(alignment: .bottom) {
                                if i < t.tasks.count - 1 { Rectangle().fill(V6.hair).frame(height: 1).padding(.leading, 54) }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                Button { t.open(allDone ? 0 : t.nextIndex, m) } label: {
                    Text(t.results.isEmpty ? "Start" : allDone ? "Start again" : "Next task").v6Primary()
                }
                .buttonStyle(V6Press())
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rewards version").font(.v6t13b).foregroundColor(V6.ink2)
                    Picker("", selection: $t.version) {
                        Text("Milestones").tag(V6RewardsMode.unlock)
                        Text("Points store").tag(V6RewardsMode.spend)
                    }
                    .pickerStyle(.segmented)
                    Text("Points card").font(.v6t13b).foregroundColor(V6.ink2).padding(.top, 6)
                    Picker("", selection: $t.card) {
                        Text("Auto").tag(V6CardMode.auto)
                        Text("Status first").tag(V6CardMode.status)
                        Text("Rank first").tag(V6CardMode.rank)
                    }
                    .pickerStyle(.segmented)
                }
                Button { t.phase = .results } label: {
                    Text("See answers (\(t.results.count))").font(.v6t13b).foregroundColor(V6.brand).frame(maxWidth: .infinity)
                }
            }
            .padding(16)
        }
        .background(V6.gray.ignoresSafeArea())
    }
}

@available(iOS 16.0, *)
private struct V6TaskIntro: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    let i: Int
    var body: some View {
        let task = t.tasks[i]
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("TASK \(i + 1) OF \(t.tasks.count)").font(.v6t13b).foregroundColor(V6.ink2)
                Text(task.title).font(.v6t24).foregroundColor(V6.ink)
                Text(task.prompt).font(.system(size: 17)).foregroundColor(V6.ink).fixedSize(horizontal: false, vertical: true)
                if !task.isCompare {
                    Text("Tap \"I did it\" when you think you're done, or \"I'm stuck\" any time.").font(.v6t13).foregroundColor(V6.ink2)
                }
                Button { t.start(i, m) } label: { Text("Start").v6Primary() }
                    .buttonStyle(V6Press()).padding(.top, 4)
                Button { t.backToList(m) } label: {
                    Text("Back to tasks").font(.v6t13b).foregroundColor(V6.brand).frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .padding(12)
        }
    }
}

@available(iOS 16.0, *)
private struct V6TaskBanner: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    let i: Int
    @State private var open = true
    var body: some View {
        let task = t.tasks[i]
        VStack(alignment: .leading, spacing: 10) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { open.toggle() } } label: {
                HStack {
                    Text("TASK \(i + 1) OF \(t.tasks.count) · \(task.title.uppercased())").font(.v6t13b).lineLimit(1)
                    Spacer()
                    Image(systemName: open ? "chevron.down" : "chevron.up").font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.75))
            }
            if open {
                Text(task.prompt).font(.system(size: 14)).foregroundColor(.white).fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 10) {
                Button { t.finish(i, finished: false, m) } label: {
                    Text("I'm stuck").font(.v6t17).foregroundColor(.white).frame(maxWidth: .infinity, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.16)))
                }
                Button { t.finish(i, finished: true, m) } label: {
                    Text("I did it").font(.v6t17).foregroundColor(V6.ink).frame(maxWidth: .infinity, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
            }
            .buttonStyle(V6Press())
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(V6.ink).shadow(color: .black.opacity(0.25), radius: 12, y: 4))
        .padding(.horizontal, 10).padding(.bottom, 2)
    }
}

@available(iOS 16.0, *)
private struct V6TaskQuestions: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    let i: Int
    @State private var ease = 0
    @State private var note = ""
    var body: some View {
        let last = i + 1 == t.tasks.count, compare = t.tasks[i].isCompare
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                Text(t.pending?.finished == false ? "Thanks, that really helps." : "Thanks!").font(.v6t13b).foregroundColor(V6.ink2)
                if !compare {
                Text("How easy was that?").font(.v6t22).foregroundColor(V6.ink)
                HStack(spacing: 6) {
                    ForEach(1...5, id: \.self) { n in
                        Button { ease = n } label: {
                            VStack(spacing: 4) {
                                Text(V6Test.faces[n - 1]).font(.system(size: 26))
                                Text(V6Test.easeNames[n - 1]).font(.system(size: 11, weight: .semibold)).foregroundColor(V6.ink)
                                    .lineLimit(1).minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(ease == n ? V6.brand10 : V6.gray))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ease == n ? V6.brand : Color.clear, lineWidth: 2))
                        }
                        .buttonStyle(.plain)
                    }
                }
                }
                Text(compare ? "What made you pick that one?" : "Anything confusing or surprising?").font(compare ? .v6t22 : .v6t17).foregroundColor(V6.ink)
                TextField("Optional", text: $note, axis: .vertical)
                    .lineLimit(3...6).font(.system(size: 17))
                    .padding(12).background(RoundedRectangle(cornerRadius: 12).fill(V6.gray))
                Button { t.answer(i, ease: ease, note: note, m) } label: { Text(last ? "Finish" : "Next task").v6Primary() }
                    .buttonStyle(V6Press()).disabled(ease == 0 && !compare).opacity(ease == 0 && !compare ? 0.4 : 1)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .padding(16)
        }
    }
}

// both versions of the points card, in random order so the first one isn't favoured
@available(iOS 16.0, *)
private struct V6CompareCards: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    let i: Int
    var persona: V6Persona? = nil
    @State private var rankOnTop = Bool.random()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("TASK \(i + 1) OF \(t.tasks.count)").font(.v6t13b).foregroundColor(V6.ink2)
                Text(persona == nil ? "Which card would make you more likely to go to the next game?"
                                    : "You've been to two games this season. Which card would make you more likely to go to the next one?")
                    .font(.v6t22).foregroundColor(V6.ink)
                ForEach(rankOnTop ? [V6CardMode.rank, .status] : [.status, .rank], id: \.self) { c in
                    VStack(spacing: 10) {
                        V6SeasonCard(mode: c, persona: persona).allowsHitTesting(false)
                        Button { m.track("Picked the \(c == .rank ? "rank" : "status") card"); t.pick(i, c) } label: { Text("Pick this one").v6Primary() }
                            .buttonStyle(V6Press())
                    }
                    .padding(.top, 6)
                }
            }
            .padding(16)
        }
        .background(V6.gray.ignoresSafeArea())
    }
}

@available(iOS 16.0, *)
private struct V6TestAllDone: View {
    @EnvironmentObject var m: V6Model
    @EnvironmentObject var t: V6Test
    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("🙌").font(.system(size: 48))
                Text(t.tester.isEmpty ? "That's everything. Thank you!" : "That's everything. Thank you, \(t.tester)!")
                    .font(.v6t22).foregroundColor(V6.ink).multilineTextAlignment(.center)
                Text("Your answers are saved on this phone.").font(.v6t13).foregroundColor(V6.ink2)
                Button { t.backToList(m) } label: { Text("Back to tasks").v6Primary() }.buttonStyle(V6Press())
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .padding(16)
        }
    }
}

@available(iOS 16.0, *)
private struct V6TestResults: View {
    @EnvironmentObject var t: V6Test
    @State private var confirmClear = false
    @State private var copied = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Button { t.phase = .list } label: {
                        Label("Tasks", systemImage: "chevron.left").font(.v6t17).foregroundColor(V6.brand)
                    }
                    Spacer()
                    ShareLink(item: t.report) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 17, weight: .semibold)).foregroundColor(V6.brand)
                    }
                }
                Text("Answers" + (t.tester.isEmpty ? "" : " · \(t.tester)")).font(.v6t24).foregroundColor(V6.ink)
                ForEach(Array(t.tasks.enumerated()), id: \.offset) { i, task in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(i + 1). \(task.title)").font(.v6t17).foregroundColor(V6.ink)
                        let runs = t.runs(task)
                        if runs.isEmpty { Text("Not done yet").font(.v6t13).foregroundColor(V6.ink2) }
                        ForEach(Array(runs.enumerated()), id: \.offset) { _, r in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(r.pick.map { "\(V6Test.label(r)) · picked the \($0 == .rank ? "rank" : "status") card · \(V6Test.time(r.seconds))" }
                                     ?? "\(V6Test.label(r)) · \(V6Test.faces[r.ease - 1]) \(V6Test.easeNames[r.ease - 1]) · \(r.finished ? "Said done" : "Got stuck") · \(V6Test.time(r.seconds))")
                                    .font(.v6t13b).foregroundColor(V6.ink)
                                if let g = r.goalMet {
                                    Label(g ? "Reached the goal in the app" : "Didn't reach the goal in the app", systemImage: g ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .font(.v6t13).foregroundColor(g ? V6.ok : .red)
                                }
                                if !r.note.isEmpty { Text("“\(r.note)”").font(.v6t13).foregroundColor(V6.ink) }
                                if !r.trail.isEmpty { Text(r.trail.joined(separator: " → ")).font(.system(size: 12)).foregroundColor(V6.ink2) }
                            }
                        }
                    }
                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                }
                Button { UIPasteboard.general.string = t.report; copied = true } label: {
                    Label(copied ? "Copied" : "Copy all answers", systemImage: copied ? "checkmark" : "doc.on.doc").v6Button(fill: V6.brand10, text: V6.brand)
                }
                .buttonStyle(V6Press())
                Button { confirmClear = true } label: {
                    Text("Clear answers for a new tester").font(.v6t13b).foregroundColor(.red).frame(maxWidth: .infinity)
                }
                .confirmationDialog("Clear all answers on this phone?", isPresented: $confirmClear, titleVisibility: .visible) {
                    Button("Clear answers", role: .destructive) { t.clear() }
                }
            }
            .padding(16)
        }
        .background(V6.gray.ignoresSafeArea())
    }
}

// MARK: - New: the welcome popup — create an account, then deals, prizes and season rewards in one line each

private struct V6Welcome: View {
    @EnvironmentObject var m: V6Model
    @State private var page = 0
    private let pages: [(symbol: String, title: String, body: String)] = [
        ("person.crop.circle.badge.plus", "Create your free account", "Start with 150 points. Your account keeps your points, deals and prizes in one place."),
        ("tag.fill", "Deals", "Check in at a 76ers Meet Up bar to unlock that bar's deal."),
        ("gift.fill", "Prizes", "Every check-in enters you in that game's prize draws."),
        ("trophy.fill", "Season Rewards", "Every check-in earns points. The top fan wins \(V6Data.grandPrize).")
    ]
    var body: some View {
        let p = pages[page], last = page == pages.count - 1
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    Button("Skip") { m.track("Skipped the welcome on page \(page + 1)"); m.showWelcome = false }
                        .font(.v6t13b).foregroundColor(V6.ink2)
                }
                Image(systemName: p.symbol).font(.system(size: 34, weight: .semibold)).foregroundColor(V6.brand)
                    .frame(width: 84, height: 84).background(Circle().fill(V6.brand10))
                Text(p.title).font(.v6t24).foregroundColor(V6.ink).multilineTextAlignment(.center)
                Text(last && m.rewardsMode == .unlock ? "Every check-in earns points. Each new fan status unlocks a reward, while supplies last." : p.body).font(.system(size: 17)).foregroundColor(V6.ink2).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                if last {
                    Label("Bar of the Game = 2x points", systemImage: "star.fill").font(.v6t13b).foregroundColor(V6.brand)
                        .padding(.horizontal, 12).padding(.vertical, 8).background(Capsule().fill(V6.brand10))
                }
                HStack(spacing: 6) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule().fill(i == page ? V6.brand : V6.hair).frame(width: i == page ? 18 : 6, height: 6)
                    }
                }
                .padding(.top, 4)
                Button {
                    if last {
                        m.track("Created account from the welcome")
                        m.finishSignUp()
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) { page += 1 }
                        m.track("Welcome · \(pages[page].title)")
                    }
                } label: { Text(last ? "Create my free account" : "Next").v6Primary() }
                .buttonStyle(V6Press())
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
            .padding(20)
        }
    }
}

