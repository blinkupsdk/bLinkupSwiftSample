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
    @State var contacts: [bLinkupContact] = []
    @State var images = [String: Image]()

    @State var showActions = false
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showActions = true
                        }
                        .confirmationDialog("", isPresented: $showActions, actions: {
                            Button("Send friend request", action: {
                                sendRequest(c)
                            })
                        })
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
    
    func sendRequest(_ contact: bLinkupContact) {
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
                let myContacts = try await getContacts()
                let contacts = try await bLinkup.findContacts(myContacts)
                self.contacts = contacts
            } catch {
            }
            isLoading = false
        }
    }
    
    func getContacts() async throws -> [PhoneBookContact] {
        try await withCheckedThrowingContinuation({ cont in
            let contactStore = CNContactStore()
            let key = [CNContactGivenNameKey,CNContactFamilyNameKey,
                       CNContactThumbnailImageDataKey,CNContactImageDataKey,
                       CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: key)
            var result = [PhoneBookContact]()
            var images = [String: Image]()
            do {
                try contactStore.enumerateContacts(with: request, usingBlock: { (contact, stoppingPointer) in
                    let filter = Set<Character>("()- ")
                    for phone in contact.phoneNumbers {
                        let num = String(phone.value.stringValue.filter({ !filter.contains($0) }))
                        let name = [contact.givenName, contact.familyName]
                            .compactMap({ $0 })
                            .joined(separator: " ")
                        let c = PhoneBookContact(phone: num, name: name)
                        result.append(c)
                        if let data = contact.thumbnailImageData ?? contact.imageData,
                           let image = UIImage(data: data)
                        {
                            images[num] = Image(uiImage: image)
                        }
                    }
                })
                self.images = images
                cont.resume(returning: result)
            } catch {
                cont.resume(throwing: error)
            }
        })
    }
}

#Preview {
    MatchingPhoneBookView(contacts: [])
}
