//
//  MatchingPhoneBookView.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.11.2023.
//

import bLinkup
import Contacts
import SwiftUI

struct MatchingPhoneBookView: View {
    @State var contacts: [Contact] = []
    @State var images = [String: Image]()

    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    var body: some View {
        if [CNAuthorizationStatus.denied, .restricted].contains(CNContactStore.authorizationStatus(for: .contacts)) {
                Link("Provide permission to use the feature", 
                     destination: URL(string: UIApplication.openSettingsURLString)!)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                )
        } else {
            VStack {
                List {
                    ForEach(contacts, id: \.phone) { c in
                        Menu {
                            Button("Send friend request", action: {
                                sendRequest(c)
                            })
                        } label: {
                            HStack {
                                (images[c.phone] ?? Image(systemName: "person"))
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text(c.name)
                                        .font(.body)
                                    
                                    Text(c.phone)
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .contentShape(Rectangle())
                    }
                }
                Spacer()
            }
            .onAppear(perform: matchPhonebook)
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func sendRequest(_ contact: Contact) {
        guard let user = contact.asUser() else { return }
        isLoading = true
        bLinkup.sendConnectionRequest(user: user, completion: {
            isLoading = false
            switch $0 {
            case .failure(let e):
                alertMessage = e.localizedDescription
            case .success:
                alertMessage = "Sent"
            }
            showAlert = true
        })
    }
    
    func matchPhonebook() {
        Task {
            isLoading = true
            do {
                self.contacts = try await bLinkup.findContacts()
            } catch {
            }
            isLoading = false
        }
    }
}

#Preview {
    MatchingPhoneBookView(contacts: [])
}
