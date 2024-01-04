//
//  BlocksView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 28.11.2023.
//

import bLinkup
import SwiftUI

struct BlocksView: View {
    
    @State var blocks: [Block] = []
    
    @State var isLoading = false
    @State var isFirstTime = true
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    ForEach(blocks, id: \.id) { block in
                        Menu {
                            Button("Unblock") {
                                unblock(block)
                            }
                        } label: {
                            Text(block.blockee.name ?? "?")
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                }
                .accentColor(.blBlue)
                .refreshable(action: { loadData() })
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
        bLinkup.getBlockedUsers {
            isLoading = false
            switch $0 {
            case .failure(let error):
                print(error)
            case .success(let list):
                self.blocks = list
            }
        }
    }
    
    func unblock(_ obj: Block) {
        isLoading = true
        bLinkup.deleteBlock(obj) {
            isLoading = false
            switch $0 {
            case .failure(let error):
                alertMessage = error.localizedDescription
            case .success:
                alertMessage = "Unblocked"
            }
            showAlert = true
            loadData()
        }
    }
}

#Preview {
    NavigationStack {
        RequestsView()
            .navigationTitle("Blocks")
            .navigationBarTitleDisplayMode(.inline)
    }
}
