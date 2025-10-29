//
//  View+Ext.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 29/10/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}
