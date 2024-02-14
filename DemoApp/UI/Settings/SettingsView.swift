//
//  SettingsView.swift
//  DemoApp
//
//  Created by Surielis Rodriguez on 11/20/23.
//

import bLinkup
import SwiftUI

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    
    @State var isLoading: Bool = false
    @State private var name = ""
    @State private var phone = ""
    @State private var showSaveButton = false

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("My Account")) {
                    Text(phone.isEmpty ? "Phone number" : phone)
                    
                    TextField("Name", text: $name)
                        .onReceive(name.publisher) { _ in
                            updateSaveButton()
                        }
                    
                    if showSaveButton {
                        HStack {
                            Spacer()
                            Button(action: updateUser, label: {
                                Text("Save")
                            })
                        }
                    }
                }
                
                Section(header: Text("More Information")) {
                    Link("Privacy Policy", destination: URL(string: "https://www.blinkupapp.com/")!)
                    Link("Terms of Service", destination: URL(string: "https://www.blinkupapp.com/")!)
                    Link("App settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                }
                
                Section(header: Text("Account Actions")) {
                    Button(action: deleteUser) {
                        Text("Delete account").foregroundStyle(.red)
                    }
                    Button("Log Out", action: logout)
                }
            }
            .refreshable(action: {
                await loadCurrentUser()
            })
            .accentColor(.blBlue)
            
            LoadingView(isShowing: $isLoading) { Rectangle().fill(.clear) }
        }
        .navigationTitle("Settings")
        .onAppear {
            Task { await loadCurrentUser() }
        }
    }
    
    func deleteUser() {
        bLinkup.deleteCurrentUser(completion: { _ in
            isLoggedIn = false
        })
    }
    
    func logout() {
        bLinkup.logout(completion: { _ in
            isLoggedIn = false
        })
    }
    
    func updateSaveButton() {
       showSaveButton = bLinkup.user?.name?.isEmpty != false || name != bLinkup.user?.name
    }
    
    func loadCurrentUser() async {
        guard let user = try? await bLinkup.getCurrentUser()
        else { return }
        
        self.name = user.name ?? ""
        self.phone = user.phoneNumber ?? ""
    }
    
    func updateUser() {
        Task {
            guard let update = try? await bLinkup.updateUser(name: name, email: "")
            else { return }
            
            self.name = update.name ?? ""
            showSaveButton = false
        }
    }
}

#Preview {
    SettingsView(isLoggedIn: .constant(true))
}
