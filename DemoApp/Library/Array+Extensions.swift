//
//  Array+Extensions.swift
//  bLinkupSDK
//
//  Created by Oleksandr Chernov on 8/8/25.
//

extension Array {
    func safeObject(at i: Int) -> Element? {
        (i>=0 && i<count) ? self[i] : nil
    }
    
    func nonEmpty() -> Self? {
        isEmpty ? nil : self
    }
}
