//
//  UserView.swift
//  bLinkupSDKTestShellApp
//
//  Created by Michael Rogers on 7/17/23.
//

import SwiftUI
import bLinkup

struct UserView: View {
    @Binding var isLoggedIn: Bool
    
    @State var isLoading: Bool = false
    @State var name: String = ""
    @State var email: String = ""
    @State var agreed: Bool = false
    @State var contactAgreed: Bool = false
    @State private var showingModal = false
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.blGreen, .blBlue]),
                                  startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        
        VStack {
            Image("bLinkupLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .padding(.bottom, 10)
            
            Text("Connecting Attendees More Easily Than Ever")
                .font(.footnote)
                .foregroundColor(.black)
                .padding(.bottom, 100)
            
            TextField("Full Name*", text: $name)
                .multilineTextAlignment(.center)
                .padding(.bottom, 7)
                .padding(.horizontal, 70)
                .textFieldStyle(.roundedBorder)
                .foregroundColor(.blBlue)
        
            TextField("Email", text: $email)
                .multilineTextAlignment(.center)
                .padding(.bottom, 60)
                .padding(.horizontal, 70)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
            
            Toggle("I agree to terms and conditions", isOn: $agreed)
                .foregroundColor(.black)
                .padding(.horizontal, 45)
                .padding(.bottom, 10)
            
            Button(action: {
                if agreed && !name.isEmpty {
                    updateUser()
                } else {
                    showingModal = true
                }
            }, label: {
                Text("Continue")
                    .frame(width: 150, height: 40)
                    .foregroundColor(.white)
                    .background(gradient)
                    .cornerRadius(100)
                    .padding(.bottom, 15)
                    .opacity(agreed && !name.isEmpty ? 1 : 0.5)
            })
        }
    }
    
    func updateUser() {
        bLinkup.updateUser(name: name, email: email, completion: { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let user):
                isLoggedIn = true
            }
        })
        // bLinkup.userData(firstName: firstName, lastName: lastName, username: username)
        isLoggedIn = true
    }
}


struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(isLoggedIn: .constant(false))
    }
}
