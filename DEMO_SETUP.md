# Running the BlinkUp demos from Xcode

The demo app builds from two repos that must sit side by side in the same folder.
The Xcode workspace looks for the SDK at `../bLinkupSwiftSDK`.

## What you need

- A Mac with **Xcode 26**.
- An iPhone on **iOS 26** (the SDK's minimum), with Developer Mode on
  (Settings → Privacy & Security → Developer Mode; it asks you to restart the phone).
- Read access to `blinkupsdk/bLinkupSwiftSample` and `blinkupsdk/bLinkupSwiftSDK` on GitHub.

## 1. Get the code

```bash
mkdir -p ~/BlinkUp && cd ~/BlinkUp
git clone -b feature/ravens-demo https://github.com/blinkupsdk/bLinkupSwiftSample.git
git clone -b feature/ravens-demo https://github.com/blinkupsdk/bLinkupSwiftSDK.git
```

Keep the folder names as they are. To get later changes, run `git pull` in both folders.

## 2. Open and sign

1. Open `bLinkupSwiftSample/DemoApp.xcworkspace` (the **workspace**, not `DemoApp.xcodeproj`).
   The first open downloads the Firebase package, which takes a few minutes.
2. Choose the **DemoAppWB** scheme at the top of the window.
3. Click the DemoApp project → **DemoAppWB** target → **Signing & Capabilities**:
   - If your Apple ID is on the BlinkTech developer team, pick that team and you're done.
   - If not, pick your own (personal) team and change **Bundle Identifier** to something
     unique, such as `com.yourname.blinkupdemo`. Apps signed with a free personal team
     stop opening after 7 days; press Run again to reinstall.

## 3. Run on your iPhone

Plug the iPhone in, pick it as the run destination next to the scheme, and press **Run** (⌘R).
The first time, the phone may ask you to trust the developer:
Settings → General → VPN & Device Management.

## Using the demos

- The list opens with **Commanders Connect Home v6** first, then the 76ers Home v6 demos
  and the team demos.
- In the v6 demos, the **⋯** button (top right) jumps between moments: a game day,
  arriving at a bar, the Bar Duel or Bar of the Game, the stadium, no game today, game on,
  and after the game. **Start over** resets it.
- The v6 demos' bars, points and fans are built into the app, so they work offline and
  nothing you tap reaches a real fan account.

## Where the code is

- `DemoApp/Start/CommandersHomeV6Demo.swift` is the Commanders demo. It is generated from
  the 76ers demo, `DemoApp/Start/SixersHomeV6Demo.swift`, by `tools/make_commanders_v6.py`.
  For a change that should apply to both, edit the 76ers file and run
  `python3 tools/make_commanders_v6.py`. If the script stops on a replacement that no
  longer matches, update that line of the script. A change only the Commanders demo
  needs belongs in the script too, or the next run will overwrite it.
- Demo art lives in `DemoApp/Resources/Assets.xcassets` (`c6_*` = Commanders, `v6_*` = 76ers).
- The demo list is `DemoApp/Support/staging/Target.swift`.
