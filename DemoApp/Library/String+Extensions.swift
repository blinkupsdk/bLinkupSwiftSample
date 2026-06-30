//
//  String+Extensions.swift
//
//
//  Created by Oleksandr Chernov on 13.05.2024.
//

extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
