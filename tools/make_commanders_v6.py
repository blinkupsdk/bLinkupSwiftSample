# Makes CommandersHomeV6Demo.swift from SixersHomeV6Demo.swift: same demo, Commanders Connect branding and numbers.
# Every replacement must match (count checked), so a change in the 76ers file fails loudly instead of half-applying.
import re, sys
import os
_START = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "DemoApp", "Start")
SRC = os.path.join(_START, "SixersHomeV6Demo.swift")
DST = os.path.join(_START, "CommandersHomeV6Demo.swift")
s = open(SRC).read()

def r(old, new, n=None):
    global s
    c = s.count(old)
    if c == 0 or (n is not None and c != n):
        sys.exit(f"replace failed ({c} found, wanted {n}): {old[:90]!r}")
    s = s.replace(old, new)

# --- file identity
r("//  SixersHomeV6Demo.swift", "//  CommandersHomeV6Demo.swift\n//  Commanders Connect rebrand of SixersHomeV6Demo.swift (Will, 2026-11-15: \"same exact demo but just rebranded\").\n//  Made by tools/make_commanders_v6.py (re-run it after changing the 76ers file); real Commanders Connect bars, Bud Light deals and points; statuses, counts, opponents are examples.", 1)
r("struct SixersHomeV6Demo: View", "struct CommandersHomeV6Demo: View", 1)
r('static let key = "v6UserTest"', 'static let key = "c6UserTest"', 1)

# --- colors: Commanders burgundy #5A1414, dark burgundy #2D0A0A, gold #FFB612
r("Color(red: 1 / 255, green: 60 / 255, blue: 167 / 255)", "Color(red: 90 / 255, green: 20 / 255, blue: 20 / 255)", 2)
r("static let strip = Color(red: 10 / 255, green: 31 / 255, blue: 102 / 255)", "static let strip = Color(red: 45 / 255, green: 10 / 255, blue: 10 / 255)", 1)
r("static let gold = Color(red: 246 / 255, green: 196 / 255, blue: 69 / 255)", "static let gold = Color(red: 255 / 255, green: 182 / 255, blue: 18 / 255)", 1)
r("static let on2 = Color.white.opacity(0.82)", "static let on2 = Color.white.opacity(0.82)\n    static let sponsor = Color(red: 0 / 255, green: 61 / 255, blue: 165 / 255)   // Bud Light blue: the live Commanders deal buttons use it", 1)
r("""LinearGradient(colors: [Color(red: 26 / 255, green: 85 / 255, blue: 201 / 255),
                                                     Color(red: 1 / 255, green: 7 / 255, blue: 203 / 255),
                                                     Color(red: 16 / 255, green: 0, blue: 163 / 255)],""",
  """LinearGradient(colors: [Color(red: 110 / 255, green: 26 / 255, blue: 26 / 255),
                                                     Color(red: 90 / 255, green: 20 / 255, blue: 20 / 255),
                                                     Color(red: 64 / 255, green: 13 / 255, blue: 13 / 255)],""", 1)
r("static let red = Color(red: 237 / 255, green: 23 / 255, blue: 76 / 255)   // 76ers secondary",
  "static let red = Color(red: 255 / 255, green: 182 / 255, blue: 18 / 255)   // Commanders secondary (gold)", 1)
r("let fill = i == 0 ? Self.red : Color.white, ink = i == 0 ? Color.white : V6.brand",
  "let fill = i == 0 ? Self.red : Color.white, ink = V6.brand   // burgundy type on both: white type on gold doesn't read", 1)
r("Circle().fill(Color(red: 237 / 255, green: 23 / 255, blue: 76 / 255)).frame(width: 10, height: 10)",
  "Circle().fill(V6.brand).frame(width: 10, height: 10)", 1)

# --- venues and bars (live Commanders Connect spots and their Bud Light deals, from /api/spots 2026-11-15)
r('"botg": V6Venue(kind: .bar, name: "O\'Neals Pub", mi: "2.6", deal: "$3.50 for One Mystery Beer", pts: 700, botg: true)',
  '"botg": V6Venue(kind: .bar, name: "Quincy Hall", mi: "4.6", deal: "$5 Bud Light", pts: 2000, botg: true)', 1)
r('"close": V6Venue(kind: .bar, name: "Garage Fishtown", mi: "0.3", deal: "$5 for One Corona & Koozie", pts: 350, botg: false)',
  '"close": V6Venue(kind: .bar, name: "Franklin Hall", mi: "0.3", deal: "$6 Bud Light", pts: 1000, botg: false)', 1)
r('"arena": V6Venue(kind: .arena, name: "Xfinity Mobile Arena", mi: "5.1", deal: "$2 Off Any Draft Beer", pts: 500, botg: false)',
  '"arena": V6Venue(kind: .arena, name: "Northwest Stadium", mi: "9.8", deal: "$2 Off Any Bud Light", pts: 1000, botg: false)', 1)
r('"home": V6Venue(kind: .home, name: "Home Watch Party", mi: "", deal: "", pts: 250, botg: false)',
  '"home": V6Venue(kind: .home, name: "Home Watch Party", mi: "", deal: "", pts: 500, botg: false)', 1)
r('''V6Bar(id: "close", name: "Garage Fishtown", address: "100 E Girard Ave, Philadelphia, PA 19125",
              deal: "$5 for One Corona & Koozie", coordinate: .init(latitude: 39.9690, longitude: -75.1340)),
        V6Bar(id: "mor", name: "Moriarty's", address: "1116 Walnut St, Philadelphia, PA 19107",
              deal: "$20 for 5 Wings & a Draft Beer", coordinate: .init(latitude: 39.9487, longitude: -75.1601)),
        V6Bar(id: "botg", name: "O'Neals Pub", address: "611 S 3rd St, Philadelphia, PA 19147",
              deal: "$3.50 for One Mystery Beer", coordinate: .init(latitude: 39.9412, longitude: -75.1478))''',
  '''V6Bar(id: "close", name: "Franklin Hall", address: "1348 Florida Ave NW, Washington, DC 20009",
              deal: "$6 Bud Light", coordinate: .init(latitude: 38.9200, longitude: -77.0313)),
        V6Bar(id: "mor", name: "The Dubliner", address: "520 North Capitol St NW, Washington, DC 20001",
              deal: "5 Bud Lights for $25", coordinate: .init(latitude: 38.8971, longitude: -77.0095)),
        V6Bar(id: "botg", name: "Quincy Hall", address: "4001 N Fairfax Drive, Arlington, VA 22203",
              deal: "$5 Bud Light", coordinate: .init(latitude: 38.8828, longitude: -77.1082))''', 1)
r("static let duelBonus = 200", "static let duelBonus = 500", 1)
r('static let duelBarPrize = "a framed 76ers jersey"', 'static let duelBarPrize = "a framed Commanders jersey"', 1)

# --- rewards, statuses, leaderboard (NFL scale: a bar is 1,000, so everything is ~2.5x the 76ers)
r('V6Item(name: "Rally towel", price: 1000, symbol: "flag")', 'V6Item(name: "Rally towel", price: 2500, symbol: "flag")', 1)
r('V6Item(name: "Sixers tee", price: 2000, symbol: "tshirt")', 'V6Item(name: "Commanders tee", price: 5000, symbol: "tshirt")', 1)
r('V6Item(name: "Signed mini ball", price: 4000, symbol: "basketball")', 'V6Item(name: "Signed mini helmet", price: 10000, symbol: "football")', 1)
r('[("Rookie", 0), ("Fan", 500), ("Super Fan", 2000), ("Die-Hard", 5000), ("Hall of Famer", 10000)]',
  '[("Rookie", 0), ("Fan", 2000), ("Super Fan", 5000), ("Die-Hard", 10000), ("Hall of Famer", 20000)]', 1)
r('V6TitleReward(tier: 2, name: "Sixers tee"', 'V6TitleReward(tier: 2, name: "Commanders tee"', 1)
r('V6TitleReward(tier: 3, name: "Signed mini ball", symbol: "basketball"', 'V6TitleReward(tier: 3, name: "Signed mini helmet", symbol: "football"', 1)
r('''[("Spencer K.", 8450), ("Keanu P.", 7900), ("Lisa M.", 7350), ("Tom B.", 6100), ("Ana R.", 5200),
                                                    ("Chris D.", 4400), ("Maria L.", 3700), ("Kev O.", 3050), ("Dre W.", 2640), ("Mike R.", 2360),
                                                    ("Jess T.", 1920), ("Sam K.", 1725), ("Lena P.", 1610)]''',
  '''[("Spencer K.", 21100), ("Keanu P.", 19750), ("Lisa M.", 18400), ("Tom B.", 15250), ("Ana R.", 13000),
                                                    ("Chris D.", 11000), ("Maria L.", 9250), ("Kev O.", 7600), ("Dre W.", 6600), ("Mike R.", 5900),
                                                    ("Jess T.", 4800), ("Sam K.", 4300), ("Lena P.", 4000)]''', 1)
r('static let prize = "Exclusive 76ers Fan Gear"', 'static let prize = "Signed Mini Helmet + Fan Pack"   // the real Bud Light Fan of the Game prize', 1)
r('static let grandPrize = "2 tickets + $100 F&B credit"', 'static let grandPrize = "2027 NFL Draft Experience"   // from the live Commanders Connect header', 1)
r('"Top fan wins \\(V6Data.grandPrize)"', '"Top fan wins a \\(V6Data.grandPrize)"', 2)
r('The top fan wins \\(V6Data.grandPrize).', 'The top fan wins a \\(V6Data.grandPrize).', 1)
r('static let seasonEnds = "Apr 12"', 'static let seasonEnds = "Jan 3"', 1)
r("static let base = 1800", "static let base = 4500", 1)
r("static let fanCount = 1152          // the 76ers' real sign-ups, Nov 11", "static let fanCount = 1205          // the Commanders' real sign-ups, Nov 11", 1)
r("static let signUpBonus = 150", "static let signUpBonus = 1000", 1)
r('V6Persona(points: 850, rank: 412, next: (name: "Nina K.", pts: 1000), floor: 700)', 'V6Persona(points: 3000, rank: 431, next: (name: "Nina K.", pts: 3250), floor: 2750)', 1)
r('static let starterDeals = ["botg": "One Free Mystery Beer", "close": "Free Corona & Koozie", "mor": "Free Wings with Any Draft"]',
  'static let starterDeals = ["botg": "One Free Bud Light", "close": "Free Bud Light Draft", "mor": "Free Bud Light Bucket"]', 1)

# --- model math tied to the 76ers numbers
r("Double(V6Data.tiers[tier].min - points) / 350)", "Double(V6Data.tiers[tier].min - points) / 1000)", 1)
r("return V6Venue(kind: x.kind, name: x.name, mi: x.mi, deal: x.deal, pts: 700, botg: true)", "return V6Venue(kind: x.kind, name: x.name, mi: x.mi, deal: x.deal, pts: 2000, botg: true)", 1)
r("if p >= 500 { return 472 - Int(Double(p - 500) / Double(low - 500) * Double(472 - named)) }",
  "if p >= 2000 { return 494 - Int(Double(p - 2000) / Double(low - 2000) * Double(494 - named)) }", 1)
r("Double(500 - b) * Double(V6Data.fanCount - 472))", "Double(2000 - b) * Double(V6Data.fanCount - 494))", 1)

# --- game, times (NFL: Sunday Night Football tonight, 1 PM kickoffs otherwise; opponent is an example)
r('homeGame ? "76ers vs. Knicks" : "76ers at Knicks"', 'homeGame ? "Commanders vs. Cowboys" : "Commanders at Cowboys"', 1)
r('moment == .off ? "Tomorrow · 7:00 PM" : "Tonight · 7:30 PM"', 'moment == .off ? "Tomorrow · 1:00 PM" : "Tonight · 8:20 PM"', 1)
r('let nextGame = "Next game Sun 6:00 PM"', 'let nextGame = "Next game Sun 1:00 PM"', 1)
r('Text("Next game · Sun 6:00 PM")', 'Text("Next game · Sun 1:00 PM")', 1)
r('"Gates 5:30 PM · tip-off 7:00 PM" : "Gates 6:00 PM · tip-off 7:30 PM"', '"Gates 11:00 AM · kickoff 1:00 PM" : "Gates 6:20 PM · kickoff 8:20 PM"', 1)
r('V6Countdown(prefix: "Tip-off in "', 'V6Countdown(prefix: "Kickoff in "', 2)

# --- demo menu
r('Text("Fan: Andy · 1,800 pts")', 'Text("Fan: Andy · 4,500 pts")', 1)
r('Text("Fan: one check-in · 500 pts").tag(500)', 'Text("Fan: one check-in · 2,000 pts").tag(2000)', 1)
r('Text("Fan: just joined · 150 pts")', 'Text("Fan: just joined · 1,000 pts")', 1)

# --- program name and copy
r('Allow “76ers Meet Up” to use your location?', 'Allow “Commanders Connect” to use your location?', 1)
r("Finds the Meet Up bar you're at so you can check in.", "Finds the Commanders Connect Bar you're at so you can check in.", 1)
r('Image("v6_header_home")', 'Image("c6_header_home")', 1)
r('.accessibilityLabel("76ers Meet Up. Check in. Score big.")', '.accessibilityLabel("Commanders Connect. Check in. Win big. Presented by Bud Light.")', 1)
r('Text("76ers Meet Up · tonight")', 'Text("Commanders Connect · tonight")', 1)
r('reward: "+700", double: true,', 'reward: "+2,000", double: true,', 1)
r('title: "Any other 76ers Meet Up bar", note: "Like Moriarty\'s", reward: "+350"', 'title: "Any other Commanders Connect Bar", note: "Like The Dubliner", reward: "+1,000"', 1)
r('title: "Any 76ers Meet Up bar", note: "Closest: \\(c.name) · \\(c.mi) mi", reward: "+350"', 'title: "Any Commanders Connect Bar", note: "Closest: \\(c.name) · \\(c.mi) mi", reward: "+1,000"', 1)
r('title: "Check in at the arena", note: "\\(a.name) · \\(a.mi) mi · from your seat", reward: "+500"', 'title: "Check in at the stadium", note: "\\(a.name) · \\(a.mi) mi · from your seat", reward: "+1,000"', 1)
r('reward: "+500",\n                           cta: mo == .at ? ("Check in  +500",', 'reward: "+1,000",\n                           cta: mo == .at ? ("Check in  +1,000",', 1)
r('reward: "+250"', 'reward: "+500"', 2)
r("You're in tonight's Fan Gear draw", "You're in tonight's Fan of the Game draw", None)
# point numbers in strings get thousands separators (2000 → 2,000)
for old in ['"+\\(m.v.pts)"', '"+\\(b.pts)"', '"+\\(v.pts)"', 'Check in  +\\(v.pts)"', '+\\(m.v.pts)"']:
    s = s.replace(old, old.replace(".pts)", ".pts.formatted())"))
r('m == .arena ? "sportscourt" : "house"', 'm == .arena ? "football" : "house"', 1)
r('m == .arena ? "At the arena" : "At home"', 'm == .arena ? "At the stadium" : "At home"', None)
r('Button("Detected at the arena")', 'Button("Detected at the stadium")', 1)
r('case .arena: return "At the arena"', 'case .arena: return "At the stadium"', 1)
r('CLLocationCoordinate2D(latitude: 39.9012, longitude: -75.1720)', 'CLLocationCoordinate2D(latitude: 38.9077, longitude: -76.8645)', 1)
r('.init(latitude: 39.95, longitude: -75.16)', '.init(latitude: 38.90, longitude: -77.03)', 1)
r('''MKCoordinateRegion(center: .init(latitude: 39.9545, longitude: -75.1505),
                                                   span: .init(latitudeDelta: 0.055, longitudeDelta: 0.055))''',
  '''MKCoordinateRegion(center: .init(latitude: 38.9000, longitude: -77.0620),
                                                   span: .init(latitudeDelta: 0.065, longitudeDelta: 0.15))''', 1)
r('Text("Watch Party Locations")', 'Text("Commanders Connect Locations")', 1)

# --- deal buttons: Bud Light blue with the Bud Light tile, like the live Commanders app
r('Image("v6_tile").resizable().scaledToFit().frame(width: 48, height: 48).background(Color.white)',
  'Image("c6_budlight").resizable().scaledToFit().frame(width: 48, height: 48).background(Color.white)', 1)
r('.fill(used ? Color(white: 0.894) : starter ? V6.strip : V6.brand))', '.fill(used ? Color(white: 0.894) : starter ? V6.strip : V6.sponsor))', 1)

# --- prizes: Bud Light Fan of the Game (real), team store party prize (example)
r('''Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fan of the Game")''',
  '''Image("c6_budlight").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bud Light Fan of the Game")''', 1)
r('Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(V6.brand10)',
  'Image(fotg ? "c6_budlight" : "c6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)', 1)
r('"20% off at the Sixers Shop"', '"20% off at the Commanders Team Store"', 2)
r('''Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                Text("Fan of the Game · tonight")''',
  '''Image("c6_budlight").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)
                Text("Bud Light Fan of the Game · tonight")''', 1)
r('"Every game, one checked-in fan wins exclusive 76ers fan gear. Check in at Xfinity Mobile Arena, any 76ers Meet Up Bar or a Home Watch Party during the game and you are entered."',
  '"Every game, one checked-in fan wins a signed mini helmet and a Commanders fan pack. Check in at Northwest Stadium, any Commanders Connect Bar or a Home Watch Party during the game and you are entered."', 1)
r("gets 20% off at the Sixers Shop.", "gets 20% off at the Commanders Team Store.", 1)
r('Text("Get to a 76ers Meet Up Bar")', 'Text("Get to Northwest Stadium or a Commanders Connect Bar")', 1)
r('Label("Find a 76ers Meet Up Bar"', 'Label("Find a Commanders Connect Bar"', 1)
r('"Saw \\"Get to a 76ers Meet Up Bar\\""', '"Saw \\"Get to a Commanders Connect Bar\\""', 1)
r('Claimed! Pick it up at any Meet Up bar on game night', 'Claimed! Pick it up at any Commanders Connect Bar on game day', 1)
r('"Opened Fan Gear prize" : "Opened Sixers Shop prize"', '"Opened Fan of the Game prize" : "Opened Team Store prize"', 1)

# --- Season Rewards earn list, history, profile
r('[(m.duelNight ? "Bar of the Game or Bar Duel" : "Bar of the Game", 700, true), ("76ers Meet Up bar", 350, false)]',
  '[(m.duelNight ? "Bar of the Game or Bar Duel" : "Bar of the Game", 2000, true), ("Commanders Connect Bar", 1000, false)]', 1)
r('[("Xfinity Mobile Arena", 500, false), ("Home Watch Party", 250, false), ("Create your free account", 150, false)]',
  '[("Northwest Stadium", 1000, false), ("Home Watch Party", 500, false), ("Create your free account", 1000, false)]', 1)
r('''[("Nov 6", "My Crew · Home Watch Party", "+250"), ("Nov 4", "Moriarty's", "+350"), ("Oct 30", "Garage Fishtown · Bar of the Game", "+700"),
                    ("Oct 22", "Garage Rittenhouse", "+350"), ("Oct 18", "Signed up", "+150")]''',
  '''[("Nov 12", "Quincy Hall · Bar of the Game", "+2,000"), ("Nov 1", "Franklin Hall", "+1,000"),
                    ("Oct 19", "My Crew · Home Watch Party", "+500"), ("Sep 21", "Signed up", "+1,000")]''', 1)
r('[("Exclusive 76ers Fan Gear", "Won Nov 2 · Claim")]', '[("Signed Mini Helmet + Fan Pack", "Won Nov 1 · Claim")]', 1)
r('"Your Exclusive 76ers Fan Gear from Nov 2 is waiting. Claim it before it expires."', '"Your Signed Mini Helmet + Fan Pack from Nov 1 is waiting. Claim it before it expires."', 1)
r('Image("v6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)', 'Image("c6_tile").resizable().scaledToFit().frame(width: 64, height: 64).background(Color.white)', 1)

# --- new status, share and Starting Five screens
r('Image("v6_header")', 'Image("c6_header")', 4)
r('Image("v6_tile").resizable().scaledToFit().frame(width: 22, height: 22)', 'Image("c6_tile").resizable().scaledToFit().frame(width: 22, height: 22)', 2)
r('Text("Check in with me at 76ers Meet Up")', 'Text("Check in with me at Commanders Connect").lineLimit(1).minimumScaleFactor(0.7)', 2)
r('"Earned tonight at \\(place) · Nov 9"', '"Earned tonight at \\(place) · Nov 15"', 1)
r('?.symbol ?? "figure.basketball")', '?.symbol ?? "figure.american.football")', 1)

# --- user test and welcome copy
r("You're at Garage Fishtown, a 76ers Meet Up bar, and just downloaded the 76ers Meet Up app.", "You're at Franklin Hall, a Commanders Connect Bar, and just opened Commanders Connect in the Commanders app.", 1)
r("you just walked into O'Neals Pub, a 76ers Meet Up bar.", "you just walked into Quincy Hall, a Commanders Connect Bar.", 1)
r("You just sat down at Xfinity Mobile Arena for tonight's game.", "You just sat down at Northwest Stadium for tonight's game.", 1)
r('"76ers Meet Up · user test"', '"Commanders Connect · user test"', 1)
r('Image("v6_tile").resizable().scaledToFit().frame(width: 44, height: 44)', 'Image("c6_tile").resizable().scaledToFit().frame(width: 44, height: 44)', 1)
r('Text("Help us test the 76ers Meet Up app")', 'Text("Help us test Commanders Connect")', 1)
r('"Start with 150 points. Your account keeps', '"Start with 1,000 points. Your account keeps', 1)
r("Check in at a 76ers Meet Up bar to unlock that bar's deal.", "Check in at a Commanders Connect Bar to unlock that bar's deal.", 1)


# --- full-screen moments (new fan status, Starting Five, share cards) had their own 76ers blues
r("RadialGradient(colors: [Color(red: 21 / 255, green: 89 / 255, blue: 220 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)],",
  "RadialGradient(colors: [Color(red: 120 / 255, green: 30 / 255, blue: 30 / 255), Color(red: 45 / 255, green: 10 / 255, blue: 10 / 255)],", 2)
r("LinearGradient(colors: [Color(red: 4 / 255, green: 34 / 255, blue: 215 / 255), Color(red: 0, green: 43 / 255, blue: 92 / 255)], startPoint: .top, endPoint: .bottom)",
  "LinearGradient(colors: [Color(red: 110 / 255, green: 26 / 255, blue: 26 / 255), Color(red: 45 / 255, green: 10 / 255, blue: 10 / 255)], startPoint: .top, endPoint: .bottom)", 2)
r("Color(red: 6 / 255, green: 10 / 255, blue: 22 / 255).opacity(0.94)", "Color(red: 22 / 255, green: 6 / 255, blue: 6 / 255).opacity(0.94)", 2)
# the longer section title can't run into the map's expand button
r('Text("Commanders Connect Locations").font(.v6t24).foregroundColor(V6.ink)', 'Text("Commanders Connect Locations").font(.v6t24).foregroundColor(V6.ink).lineLimit(1).minimumScaleFactor(0.7).padding(.horizontal, 40)', 1)

# --- remaining bar names in demo copy (menu, toasts, comments)
for old, new in [("Garage Fishtown", "Franklin Hall"), ("O'Neals Pub", "Quincy Hall"), ("(O'Neals)", "(Quincy Hall)"), ("O'Neals", "Quincy Hall"),
                 ("Moriarty's", "The Dubliner"), ("Garage Rittenhouse", "Public Bar Live"), ("Xfinity Mobile Arena", "Northwest Stadium")]:
    s = s.replace(old, new)

open(DST, "w").write(s)
left = [l for l in s.splitlines() if re.search(r"76ers|Sixers|Knicks|Philadelphia|Fishtown|Meet Up|Corona|Mystery|v6_tile|v6_header|basketball|tip-off|Tip-off", l)]
print("written", DST, "| leftovers:", len(left))
for l in left: print("  ", l.strip()[:150])
