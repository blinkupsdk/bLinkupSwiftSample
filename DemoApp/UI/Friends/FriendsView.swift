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
    @State var connections: [Record] = []
    @State var filtered: [Record] = []
    @State var segment = 0
    
    @State private var isLoading = false
    @State private var isFirstTime = true
    
    @Environment(\.isSearching) private var isSearching
    
    let myId = bLinkup.user?.id
    
    struct Record: Equatable{
        let connection: Connection
        let presence: [Place]
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.connection.id == rhs.connection.id
        }
    }
    
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
                        if !filtered.isEmpty {
                            Section {
                                ForEach(filtered, id: \.connection.id) {
                                    let opponent = $0.connection.opponent(of: bLinkup.user?.id)
                                    ConnectionCell(user: opponent, presence: $0.presence)
                                }
                            }
                        } else if !isFirstTime {
                            Text("No records")
                        }
                        if search.isEmpty && !isFirstTime && !isSearching {
                            Section {
                                NavigationLink("Match Phone Contacts", destination: {
                                    MatchingPhoneBookView()
                                        .navigationTitle("Your Contacts")
                                        .toolbar(.hidden, for: .tabBar)
                                })
                                
                                NavigationLink("Pending requests", destination: {
                                    RequestsView()
                                        .navigationTitle("Requests")
                                        .toolbar(.hidden, for: .tabBar)
                                })
                                
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
        .onChange(of: segment) { _ in updateFiltered() }
    }
    
    func loadFirstTime() {
        guard isFirstTime else { return }
        isFirstTime = false
        loadData()
    }
    
    func loadData() {
        Task {
            do {
                isLoading = true
                let connections = try await bLinkup.getFriendList()
                let places = try await bLinkup.getEvents()
                var presence = [Presence]()
                for p in places {
                    let pr = try await bLinkup.getFriendsAtPlace(p)
                    presence += pr
                }
                let result = connections
                    .map({ con in
                        let oppId = con.opponent(of: myId)?.id ?? ""
                        let places = presence
                            .filter({ $0.user.id == oppId && $0.isPresent })
                            .compactMap({ $0.place })
                        return Record(connection: con, presence: places)
                    })
                self.connections = result
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
    
    func updateFiltered() {
        guard let myId else {
            filtered = connections
            return
        }
        
        let search = search.lowercased()
        
        filtered = connections
            .filter({ segment == 0 ? true : !$0.presence.isEmpty })
            .filter({
                if search.isEmpty { return true }
                let opp = $0.connection.opponent(of: myId)
                return opp?.name?.lowercased().contains(search) == true
                || opp?.phone_number?.contains(search) == true
                || opp?.id.contains(search) == true
            })
    }
}

#Preview {
    NavigationStack {
        FriendsView()
            .navigationTitle("Friends")
    }
}
