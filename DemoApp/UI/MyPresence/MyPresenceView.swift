//
//  MyPresenceView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 20.11.2023.
//

import bLinkup
import SwiftUI

struct MyPresenceView: View {
    
    @State var presence: [Presence] = []
    @State var selection: Presence?
    @State var isLoading = false
    @State var isFirstLoading = true
    
    var body: some View {
        ZStack {
            List {
                Section(content: {
                    ForEach(presence, id: \.id) { p in
                        MyPresenceCell(presence: p, isSelected: selection == p)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.gray.opacity(0.001))
                            .onTapGesture {
                                withAnimation {
                                    selection = p
                                }
                            }
                    }
                }, footer: {
                    actionsHeader()
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
    
    func actionsHeader() -> some View {
        VStack {
            Text("Manually set presence")
                .font(.title3)
            
            HStack {
                Button(action: {
                    updatePresence(true)
                }, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("in")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 130)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius:5))
                })
                
                Button(action: {
                    updatePresence(false)
                }, label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Out")
                    }
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 130)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.black, lineWidth: 1)
                    )
                })
            }
            
            NavigationLink(destination: {
                TrackView()
                    .navigationTitle("Geofencing")
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
        .opacity(selection == nil ? 0.5 : 1)
        .allowsHitTesting(selection != nil)
    }
    
    func loadData() {
        isLoading = true
        bLinkup.getMyPresences {
            isLoading = false
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let list):
                self.presence = list
                let id = selection?.place?.id
                selection = id == nil ? list.first : (list.first(where: { $0.place?.id == id }) ?? list.first)
            }
        }
    }
    
    func updatePresence( _ p: Bool) {
        guard let place = selection?.place,
              selection?.isPresent != p
        else { return }
        
        isLoading = true
        bLinkup.setUserAtEvent(p, at: place) {
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
        MyPresenceView(presence: [.init(id: "1",
                                        user: .init(id: "1", name: "User"),
                                        place: .init(id: "1", name: "Place1"),
                                        isPresent: true, insertedAt: nil),
                                  .init(id: "2",
                                        user: .init(id: "2", name: "User"),
                                        place: .init(id: "2", name: "Place2"),
                                        isPresent: false, insertedAt: nil)],
                       isFirstLoading: false)
        .navigationTitle("Presence")
    }
}
