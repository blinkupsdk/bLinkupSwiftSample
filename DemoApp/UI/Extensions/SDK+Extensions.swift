//
//  SDK+Extensions.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 28.11.2023.
//

import bLinkup
import Foundation

extension Connection {
    func opponent(of id: String?) -> User? {
        target.id == id ? source : target
    }
}

extension ConnectionRequest {
    func opponent(of id: String?) -> User? {
        target.id == id ? source : target
    }
}
