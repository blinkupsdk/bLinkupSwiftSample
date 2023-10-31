//
//  PresenceView.swift
//  bLinkupSDKTestShellApp
//
//  Created by Oleksandr Chernov on 27.10.2023.
//

import SwiftUI
import bLinkup

struct PresenceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let place: Place
    
    @State var isLoading = true
    @State var presence: [Presence] = []

    var body: some View {
        LoadingView(isShowing: $isLoading) {
            List {
                ForEach(presence, id: \.id) { p in
                    PresenceCell(presence: p)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .refreshable {
                Task { try await loadPresence() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear(perform: {
            Task { try? await loadPresence() }
        })
        .transition(.opacity)
        .navigationTitle("Presence")
        .navigationBarBackButtonHidden()
    }
    
    func loadPresence() async throws {
        Task {
            do {
                self.isLoading = true
                self.presence = try await bLinkup.getFriendsAtPlace(place)
                self.isLoading = false
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PresenceView(place: Place(id: "1", name: "Stadium"),
                     isLoading: false)
    }
}
