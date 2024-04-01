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
private let kCustomers = [
    Customer(id: "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=", name: "Demo"),
    Customer(id: "yi4BQHhnORxcuRMiusLnhCWVBEPuBlh5DFP_GkErhtM=", name: "milwaukee bucks"),
    Customer(id: "zpkC40NrPQoL4g2L49Ho0MLWE1hn8v_1tMKWtT49lk0=", name: "Atlanta Braves"),
    Customer(id: "Hj4eM_LRpGrqqn_WBnIMaP-dznK-Esbo1BxVT4aocJM=", name: "Clemson Tigers"),
    Customer(id: "coTYC0y8ueUfvPXQVUFs85YctB3Q4mS0sELhH7UbzDw=", name: "Green Bay Packers"),
    Customer(id: "8j7Kk1HZyjo96k48Hg51DR7n2HEBUPCM3JUvHGQEAPs=", name: "Charlotte Hornets"),
]

struct StartView: View {
    @Binding var isLoggedIn: Bool
    
    @State var isLoading = false
    @State var screenState: ScreenState = .login
    @State var customer: Customer? = {
        if let data = UserDefaults.standard.object(forKey: "Customer") as? Data {
            return try? JSONDecoder().decode(Customer.self, from: data)
        }
        return nil
    }()
    {
        didSet {
            if let data = try? JSONEncoder().encode(customer) {
                UserDefaults.standard.setValue(data, forKey: "Customer")
            }
        }
    }
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
            if customer == nil {
                chooseCustomer()
            } else {
                LoadingView(isShowing: $isLoading) {
                    NavigationStack {
                        loginView()
                            .padding(.horizontal)
                            .navigationDestination(isPresented: $showCodeValidator) {
                                codeView()
                                    .padding(.horizontal)
                                    .navigationTitle("")
                                    .navigationBarHidden(true)
                            }
                    }
                }
            }
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
    
    func chooseCustomer() -> some View {
        List {
            ForEach(kCustomers, id: \.id) { customer in
                Button(action: {
                    self.customer = customer
                }, label: {
                    HStack {
                        Image(systemName: "person")
                        Text(customer.name ?? customer.id)
                    }
                })
            }
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
    StartView(isLoggedIn: .constant(false))
}
