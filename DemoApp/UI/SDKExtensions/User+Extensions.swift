//
//  User+Extensions.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 24/7/25.
//

import Foundation
import bLinkupSDK

extension User {
    static func intInit(
        id: String = UUID().uuidString,
        name: String = "name1",
        phone: String = "num1",
        email: String = "email@gmail.com",
        type: UserType = .normal,
        presence: Place? = nil
    ) -> User {
        User.init(
            id: id,
            name: name,
            phoneNumber: phone,
            emailAddress: email,
            type: type,
            presence: presence
        )
    }
    
    func contains(_ s: String) -> Bool {
        if s.isEmpty {
            return true
        }
        let low = s.lowercased()
        return name.lowercased().contains(low)
        || phoneNumber.contains(low)
        || id.lowercased().contains(low)
    }
}
