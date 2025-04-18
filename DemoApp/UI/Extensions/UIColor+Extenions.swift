//
//  UIColor+Extenions.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13/11/2024.
//

import SwiftUI

extension UIColor {
    convenience init?(hex: String?) {
        guard let hex = hex?.nonEmpty else { return nil }
        
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil;
        }

        self.init(red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  alpha: Double(a) / 255)
    }
}
