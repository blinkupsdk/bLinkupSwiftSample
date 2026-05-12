//
//  ShakeDetector.swift
//  DemoApp
//

import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("🫨 SHAKE DETECTED — posting deviceDidShake")
            NotificationCenter.default.post(name: Notification.Name("deviceDidShake"), object: nil)
        }
    }
}
