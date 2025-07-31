//
//  MyPresenceView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkupSDK
import SwiftUI

struct MyPresenceView: View {
    struct ARecord: Identifiable, Equatable, Hashable {
        var id: String { place.id }
        let place: Place
        let presence: Presence?
    }
    
    @State var records: [ARecord] = []
    @State var isLoading = false
    @State var isFirstLoading = true
    @Binding var error: Error?
    
    var body: some View {
        ZStack {
            List {
                Section(content: {
                    ForEach(records, id: \.id) { r in
                        MyPresenceCell(rec: r, updater: touchPresence)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 30)
                            .background(.gray.opacity(0.001))
                    }
                }, header: {
                    actionsSection()
                        .frame(maxWidth: .infinity)
                })
            }
            .refreshable(action: {
                loadData()
            })
            
            ActivityIndicator(isAnimating: $isLoading, style: .large)
        }
        .onAppear{
            guard isFirstLoading else { return }
            loadData()
            isFirstLoading = false
        }
    }
    
    func actionsSection() -> some View {
        VStack {
            Text("Manually set presence")
                .font(.title3)
            
            NavigationLink(destination: {
                TrackView()
                    .navigationTitle("Geofencing")
                    .navigationBarTitleDisplayMode(.inline)
            }, label: {
                HStack {
                    Text("</>")
                    Text("Dev Details").lineLimit(1)
                }
                .foregroundColor(.black)
                .frame(minWidth: 100, maxWidth: 130)
                .padding()
                .frame(width: 150)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .strokeBorder(.black, lineWidth: 1)
                )
            })
        }
        .font(.system(size: 14))
    }
    
    func loadData() {
        Task {
            isLoading = true
            do {
                let presence = try await bLinkup.getMyPresences()
                let places = try await bLinkup.getEvents()
                self.records = places.compactMap({ p in
                    ARecord(place: p, presence: presence.first(where: { $0.place?.id == p.id }))
                })
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    func touchPresence( _ r: ARecord) {
        let pres = r.presence?.isPresent == true
        
        isLoading = true
        bLinkup.setUserAtEvent(!pres, at: r.place) {
            isLoading = false
            switch $0 {
            case .failure(let error):
                print(error)
            case .success:
                loadData()
            }
        }
    }
}

#Preview {
    NavigationView {
        let u1 = User.intInit(id: "1", name: "User1")
        let u2 = User.intInit(id: "2", name: "User2")
        let pl1 = Place(id: "1", name: "Place1", latitude: 0, longitude: 0, radius: 10)
        let pl2 = Place(id: "2", name: "Place2", latitude: 0, longitude: 0, radius: 10)
        let pr1 = Presence(id: "1", user: u1, place: pl1, isPresent: true, insertedAt: nil)
        let pr2 = Presence(id: "2", user: u2, place: pl2, isPresent: true, insertedAt: nil)
        
        MyPresenceView(records: [
            .init(place: pl1, presence: pr1),
            .init(place: pl2, presence: pr2)
        ],
                       isFirstLoading: false, error: .constant(nil))
        .navigationTitle("Presence")
    }
}
