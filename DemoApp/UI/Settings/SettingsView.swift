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
                    Text("Delete Account")
                        .foregroundColor(.red)
                    Button(action: logout) {
                        Text("Log Out")
                    }
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
        self.phone = user.phone_number ?? ""
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
    ProfileView(isLoggedIn: .constant(true))
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from:nil, for: nil)
//    }
//}
//#endif
