//
//  ProfileView.swift
//  DemoApp
//
//  Created on 9/18/23.
//

import SwiftUI
import bLinkup

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    @State var isLoading: Bool = false
    @State private var name = ""
    @State private var phone = ""
    
    var body: some View {
        ZStack {
            Form {
                Section(header: Text("My Account")) {
                    Text(phone.isEmpty ? "Phone number" : phone)
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Relationships")) {
                    NavigationLink(destination: {
                        SearchView()
                            .navigationTitle("Search")
                    }, label: {
                        Text("Search friends")
                    })
                    
                    NavigationLink(destination: {
                        ConnectionRequestsView()
                            .navigationTitle("Friend requests")
                    }, label: {
                        Text("Friend requests")
                    })
                    
                    NavigationLink(destination: {
                        ConnectionsView()
                            .navigationTitle("Connections")
                    }, label: {
                        Text("Connections")
                    })
                }
                
                Section(header: Text("More Information")) {
                    Link("Privacy Policy", destination: URL(string: "https://www.blinkupapp.com/")!)
                    Link("Terms of Service", destination: URL(string: "https://www.blinkupapp.com/")!)
                }
                
                Section(header: Text("Account Actions")) {
                    Text("Delete Account")
                        .foregroundColor(.red)
                    Button(action: logout) {
                        Text("Log Out")
                    }
                }
            }
            .refreshable {
                loadCurrentUser()
            }
            .accentColor(.blBlue)
            
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
        }
        .navigationTitle("Profile")
        .onAppear {
            loadCurrentUser()
        }
    }
    
    func logout() {
        bLinkup.logout(completion: { _ in
            isLoggedIn = false
        })
    }
    
    func loadCurrentUser() {
        Task {
            do {
                let user = try await bLinkup.getCurrentUser()
                self.name = user.name ?? ""
                self.phone = user.phone_number ?? ""
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                        to: nil, from:nil, for: nil)
    }
}
#endif
