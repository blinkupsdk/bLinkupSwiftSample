//
//  String+Extensions.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 22.12.2023.
//

import Foundation

extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
