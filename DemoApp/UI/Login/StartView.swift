//
//  StartView.swift
//  bLinkupSDKTestShellApp
//
//  Created by Oleksandr Chernov on 11.10.2023.
//

import Combine
import Foundation
import SwiftUI
import bLinkup

enum ScreenState {
    case login, user
}

private let gradient = LinearGradient(gradient: Gradient(colors: [.blGreen, .blBlue]),
                                      startPoint: .leading, endPoint: .trailing)

struct StartView: View {
    @Binding var isLoggedIn: Bool
    @Binding var customer: Customer?

    @State var isLoading = false
    @State var screenState: ScreenState = .login
    
    #if DEBUG
    @State var mobileNumber: String = "+380951299232"
    @State var accessToken: String = "123456"
    #else
    @State var mobileNumber: String = "" //123123"
    @State var accessToken: String = "" //123456"
    #endif
    @State var showCodeValidator = false
    @State var user: User?
    
    var body: some View {
        switch screenState {
        case .login:
            NavigationView {
                loginView()
                    .padding(.horizontal)
                
                NavigationLink(destination: codeView()
                    .padding(.horizontal)
                    .navigationTitle("")
                    .navigationBarHidden(true),
                               isActive: $showCodeValidator) {
                    EmptyView()
                }.hidden()
            }
            .addLoadingView(isLoading: $isLoading)
        case .user:
            UserUpdateView(isLoggedIn: $isLoggedIn,
                           name: user?.name ?? "", 
                           email: user?.emailAddress ?? "")
        }

    }
    
    func loginView() -> some View {
        VStack {
            BlinkupHeaderView()
            
            Spacer()

            Text("Your customer")
                .font(.title2)
                .foregroundColor(.black)
            
            Button(action: {
                self.customer = nil
            }, label: {
                Text(customer == nil ? "Choose" : (customer?.name ?? customer?.id ?? "-"))
            })
            .padding(.bottom)
            
            Text("Enter phone number")
                .font(.title2)
                .foregroundColor(.black)
            
            TextField("Phone Number", text: $mobileNumber)
                .multilineTextAlignment(.center)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)
                .onReceive(Just(mobileNumber), perform: { newValue in
                    var filtered = newValue.filter { "0123456789".contains($0) }
                    if newValue.first == "+" { filtered = "+" + filtered }
                    filtered = String(filtered.prefix(20))
                    if filtered != newValue {
                        mobileNumber = filtered
                    }
                })
                .padding(.bottom, 40)
                .foregroundColor(.black)
                        
            Button(action: requestCode) {
                Text("Submit")
                    .frame(width: 150, height: 50)
                    .foregroundColor(.white)
                    .background(gradient)
                    .cornerRadius(100)
                    .padding(.bottom, 15)
            }

            Spacer()
        }
    }
    
    func codeView() -> some View {
        VStack {
            BlinkupHeaderView()
            
            Spacer()
            
            Text("Enter verification code")
                .font(.title2)
                .padding(.top, 20)
                .foregroundColor(.black)
            
            TextField("Verification Code", text: $accessToken)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.bottom, 40)
                .foregroundColor(.black)
            
            Button(action: login) {
                Text("Verify")
                    .frame(width: 150, height: 50)
                    .foregroundColor(.white)
                    .background(gradient)
                    .cornerRadius(100)
                    .padding(.bottom, 15)
            }
            
            Spacer()
        }
        .overlay(alignment: .topLeading, content: {
            Button {
                showCodeValidator = false
            } label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 24))
                    .foregroundStyle(.black)
            }
        })
    }
    
    // MARK: - Data
    
    func requestCode() {
        guard let customer else { return }
        isLoading = true
        bLinkup.requestCode(customer: customer, phoneNumber: mobileNumber) { result in
            isLoading = false
            switch result{
            case .success(let message):
                print(message)
                showCodeValidator = true
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func login() {
        isLoading = true
        bLinkup.confirmCode(phoneNumber: mobileNumber, verificationCode: accessToken) { result in
            isLoading = false
            switch result{
            case .success(let user):
                if bLinkup.isUserDetailsRequired {
                    self.user = user
                    screenState = .user
                } else {
                    isLoggedIn = true
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

#Preview {
    StartView(isLoggedIn: .constant(false), customer: .constant(nil))
}
