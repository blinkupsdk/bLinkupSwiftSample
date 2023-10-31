//
//  BlinkupHeaderView.swift
//  bLinkupSDKTestShellApp
//
//  Created by Oleksandr Chernov on 27.10.2023.
//

import SwiftUI

struct BlinkupHeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Rectangle()
                .fill(.clear)
                .frame(minHeight: 20, maxHeight: 50)
            
            Image("bLinkupLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 125)
            
            Text("Connecting Attendees More Easily Than Ever")
                .font(.footnote)
                .foregroundColor(.black)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    BlinkupHeaderView()
}
