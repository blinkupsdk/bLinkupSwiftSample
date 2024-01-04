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
    @State var searchResult: [User] = []
    @State var connections: [Record] = []
    @State var filtered: [Record] = []
    @State var segment = 0
    
    @State private var isLoading = false
    @State private var isFirstTime = true
    @State private var searchTask: Task<(), Error>?

    let myId = bLinkup.user?.id
    
    struct Record: Equatable {
        let connection: Connection
        let presence: [Place]
        let withMe: Bool
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.connection.id == rhs.connection.id
            && lhs.presence == rhs.presence
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
                    Section {
                        if !filtered.isEmpty {
                            ForEach(filtered, id: \.connection.id) { c in
                                let opponent = c.connection.opponent(of: bLinkup.user?.id)
                                Menu {
                                    Button("Block") {
                                        block(c.connection)
                                    }
                                } label: {
                                    ConnectionCell(user: opponent, presence: c.presence, withMe: c.withMe)
                                }
                                .contentShape(Rectangle())
                            }
                        } else if !isFirstTime {
                            Text("No connections")
                        }
                    }
                    if search.isEmpty && !isFirstTime {
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
                            
                            NavigationLink("Blocked users", destination: {
                                BlocksView()
                                    .navigationTitle("Blocked users")
                                    .toolbar(.hidden, for: .tabBar)
                            })
                        }
                        .foregroundColor(Color.accentColor)
                    } else if !search.isEmpty && !isFirstTime {
                        Section {
                            if searchResult.isEmpty {
                                Text("Found no users")
                            } else {
                                ForEach(searchResult, id: \.id) { u in
                                    let isConnected = connections.contains(where: { $0.connection.id == u.id })
                                    Menu {
                                        if isConnected {
                                            EmptyView()
                                        } else {
                                            Button("Send friend request") {
                                                inviteUser(u)
                                            }
                                        }
                                        Button("Block") {
                                            block(u)
                                        }
                                    } label: {
                                        FoundUserView(user: u, highlightIcon: !isConnected)
                                    }
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                }
                .accentColor(.blBlue)
                .refreshable(action: { loadData() })
            }
            
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
        }
        .searchable(text: $search, prompt: "search for friends")
        .onAppear(perform: loadFirstTime)
        .onChange(of: search) { _ in updateFiltered(); searchUsers() }
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
                let myPresence = try await bLinkup.getMyPresences()
                let myPlaceId = myPresence.first(where: { $0.isPresent })?.place?.id
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
                        return Record(connection: con, 
                                      presence: places,
                                      withMe: myPlaceId != nil && places.contains(where: { $0.id == myPlaceId }))
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
    
    func searchUsers() {
        searchTask?.cancel()
        guard let s = search.nonEmpty else { return }
        searchTask = Task {
            try await Task.sleep(nanoseconds: 700_000_000)
            searchResult = try await bLinkup.findUsers(query:s)
        }
    }
    
    func inviteUser(_ user: User) {
        isLoading = true
        bLinkup.sendConnectionRequest(user: user, completion: { res in
            isLoading = false
        })
    }
    
    func block(_ c: Connection) {
        guard let op = c.opponent(of: bLinkup.user?.id) else { return }
        block(op)
    }
    
    func block(_ u: User) {
        isLoading = true
        bLinkup.blockUser(u, completion: { res in
            isLoading = false
            loadData()
        })
    }
}

#Preview {
    NavigationStack {
        FriendsView()
            .navigationTitle("Friends")
    }
}
