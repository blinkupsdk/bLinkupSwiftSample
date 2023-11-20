//
//  VenueMapShareView2.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 17.11.2023.
//

import bLinkup
import SwiftUI

struct VenueMapShareView2: View {
    @Binding var point: BlinkPoint?
    @State var image: UIImage? = nil
    @State private var isSharePresented: Bool = false
    
    var body: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()

            VStack(spacing: 20) {
                if let image {
                    Image(uiImage: image)
                }
                
                Text(inviteMessage())
                    .font(.title3)
                    .lineLimit(7)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Spacer()
                    Button("Cancel") {
                        point = nil
                    }
                    Spacer()
                    Spacer()
                    Button("Invite") {
                        isSharePresented = true
                    }
                    .fullScreenCover(isPresented: $isSharePresented, content: {
                        ActivityViewController(activityItems: [inviteMessage()])
                    })
                    Spacer()
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .padding()
        }
        .onAppear(perform: load)
    }
    
    func load() {
        guard let promoLink = point?.promoURL,
              let url = URL(string: promoLink)
        else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data)
            {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
    
    func inviteMessage() -> String {
        "Hey, I see you're here too! Want to get together at the \(point?.name ?? "?") meetup spot?"
    }
}

#Preview {
    VenueMapShareView2(point: .constant(.init(id: "1", name: "point", x: 0, y: 0)))
}

