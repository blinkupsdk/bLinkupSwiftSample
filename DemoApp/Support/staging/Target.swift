//
//  Target.swift
//  DemoAppSTG
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import Foundation

import bLinkup
import UIKit

enum Target {
    static let customers = [
        AppCustomer(id: "TkPnD3_yP3j6dUEAksgRjJ-auYijyUECLxVEnFqHJVE=",
                    name: "STG-Test",
                    primary: "004020",
                    secondary: "CC0D33",
                    logo: "logoDemo"),
        AppCustomer(id: "CzWgbh_Y0-Lod0VCjhwkiIDt5y3QxLLcoy0FcEDoc9E=",
                    name: "STG-Legacy",
                    primary: "004020",
                    secondary: "CC0D33",
                    logo: "logoMilwaukee",
                    font: "AmericanTypewriter"),
    ]
}
