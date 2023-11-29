//
//  RequestsView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 28.11.2023.
//

import bLinkup
import SwiftUI

struct RequestsView: View {
    
    @State var requests: [ConnectionRequest] = []
    
    @State var isLoading = false
    @State var isFirstTime = true
    @State var showActions = false
    @State var selectedItem: ConnectionRequest?
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(requests, id: \.id) { req in
                        let fromMe = req.source.id == bLinkup.user?.id
                        let opponent = req.opponent(of: bLinkup.user?.id)
                        
                        HStack {
                            Image(systemName: fromMe ? "arrow.right" : "arrow.left")
                            Text(opponent?.name ?? "?")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItem = req
                            showActions = true
                        }
                    }
                }
                .accentColor(.blBlue)
                .refreshable(action: { loadData() })
                .confirmationDialog("", isPresented: $showActions, actions: {
                    if let selectedItem {
                        menuForRequest(selectedItem)
                    }
                })
            }
            
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
        }
        .onAppear(perform: loadFirstTime)
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    func loadFirstTime() {
        guard isFirstTime else { return }
        isFirstTime = false
        loadData()
    }
    
    func loadData() {
        isLoading = true
        bLinkup.getFriendRequests {
            isLoading = false
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let list):
                self.requests = list
            }
        }
    }
    
    @ViewBuilder
    func menuForRequest(_ obj: ConnectionRequest) -> some View {
        if bLinkup.user?.id == obj.source.id {
            Button("Cancel request") {
                bLinkup.cancelFriendRequest(obj){
                    switch $0 {
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                    case .success:
                        alertMessage = "canceled"
                    }
                    showAlert = true
                    loadData()
                }
            }
        } else {
            Button("Accept request") {
                bLinkup.acceptFriendRequest(obj) {
                    switch $0 {
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                    case .success:
                        alertMessage = "accepted"
                    }
                    showAlert = true
                    loadData()
                }
            }
            
            Button("Deny request") {
                bLinkup.denyFriendRequest(obj, completion: {
                    switch $0 {
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                    case .success:
                        alertMessage = "denied"
                    }
                    showAlert = true
                    loadData()
                })
            }
            
        }
    }
}

#Preview {
    NavigationStack {
        RequestsView()
            .navigationTitle("Requests")
            .navigationBarTitleDisplayMode(.inline)
    }
}
