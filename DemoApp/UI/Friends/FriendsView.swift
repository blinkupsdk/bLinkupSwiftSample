//
//  FriendsView.swift
//  DemoApp
//
//  Created by Surielis Rodriguez on 11/20/23.
//

import SwiftUI

import bLinkup
import SwiftUI

struct FriendsView: View {
    @State var search: String = ""
    @State var connections: [Connection] = []
    @State var presence: [String: Bool] = [:]
    @State var filtered: [Connection] = []
    @State var segment = 0
    
    @State private var isLoading = false
    @State private var isFirstTime = true
    
    @Environment(\.isSearching) private var isSearching
    
    let mineId = bLinkup.user?.id
    
    var body: some View {
        ZStack {
            VStack {
                Picker("", selection: $segment) {
                    Text("All").tag(0)
                    Text("Present").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    Section {
                        ForEach(filtered, id: \.id) {
                            let opponent = $0.opponent(of: bLinkup.user?.id)
                            ConnectionCell(user: opponent, isPresent: presence[opponent?.id ?? ""] ?? false)
                        }
                    }
                    if search.isEmpty && !isFirstTime && !isSearching {
                        Section {
                            NavigationLink("Match Phone Contacts", destination: {
                                SearchView()
                                    .navigationBarTitleDisplayMode(.inline)
                                    .toolbar(.hidden, for: .tabBar)
                            })
                            
                            NavigationLink("Pending requests",
                                           destination: ConnectionRequestsView())
                            
                            HStack{
                                Text("Blocked users")
                                Spacer()
                                HStack {
                                    Image(systemName: "crown")
                                    Text("COMING SOON")
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(Color.accentColor)
                    }
                }
                .accentColor(.blBlue)
                .refreshable(action: { loadData() })
            }
            
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
        }
        .searchable(text: $search, prompt: "search for friends")
        .onAppear(perform: loadFirstTime)
        .onChange(of: search) { _ in updateFiltered() }
        .onChange(of: connections) { _ in updateFiltered() }
    }
    
    func loadFirstTime() {
        guard isFirstTime else { return }
        isFirstTime = false
        loadData()
    }
    
    func loadData() {
        isLoading = true
        bLinkup.getFriendList(completion: {
            isLoading = false
            switch $0 {
            case .failure(let e):
                print(e)
            case .success(let list):
                connections = list
            }
        })
    }
    
    func updateFiltered() {
        guard let me = bLinkup.user?.id, !search.isEmpty else {
            filtered = connections
            return
        }
        
        let search = search.lowercased()
        
        filtered = connections
            .filter({
                let opp = $0.source.id == me ? $0.target : $0.source
                return opp.name?.lowercased().contains(search) == true
                || opp.phone_number?.contains(search) == true
            })
    }
}

extension Connection {
    func opponent(of id: String?) -> User? {
        target.id == id ? source : target
    }
}

#Preview {
    NavigationStack {
        FriendsView()
            .navigationTitle("Friends")
    }
}
