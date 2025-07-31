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
        AppCustomer(id: "TkPnD3_yP3j6dUEAksgRjJ-auYijyUECLxVEnFqHJVE=",
                    name: "STG-Test",
                    primary: "#FFFF00",
                    secondary: "#F0FFFF",
                    logo: "logoDemo"),
        AppCustomer(id: "CzWgbh_Y0-Lod0VCjhwkiIDt5y3QxLLcoy0FcEDoc9E=",
                    name: "STG-Legacy",
                    logo: "logoMilwaukee",
                    font: "AmericanTypewriter"),
        AppCustomer(id: "j2LnaXXlqBhnGLNzHbKcVIJWt0NuZFVRiMmNJK19PWc=",
                    name: "Dev-Maxim",
                    logo: "logoMilwaukee",
                    font: "AmericanTypewriter"),
    ]
}
