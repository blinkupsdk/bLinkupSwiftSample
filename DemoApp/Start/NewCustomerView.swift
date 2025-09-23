//
//  NewCustomer.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13/11/2024.
//

import bLinkupSDK
import SwiftUI

struct NewCustomerView: View {
    let id: String?
    @State var cid: String
    @State var name: String
    @State var primary: String
    @State var secondary: String

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(id: String?, cid: String, name: String, primary: String, secondary: String) {
        self.id = id
        self.cid = cid
        self.name = name
        self.primary = primary
        self.secondary = secondary
    }
    
    init(_ c: AppCustomer?) {
        self.id = c?.id ?? ""
        self.cid = c?.cid ?? ""
        self.name = c?.name ?? ""
        self.primary = c?.primary ?? ""
        self.secondary = c?.secondary ?? ""
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Text("add details of a customer")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                TextField("CID", text: $cid)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.blBlue)
                
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.blBlue)

                TextField("Primary", text: $primary)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.blBlue)
                
                TextField("Secondary", text: $secondary)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.blBlue)
                
                Button("Save") {
                    addCustomer()
                }
                .padding(.top)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    func addCustomer() {
        guard let cid = self.cid.nonEmpty else { return }
        
        let c = AppCustomer(cid: cid,
                            name: name.nonEmpty,
                            primary: primary.nonEmpty,
                            secondary: secondary.nonEmpty)
        DB.shared.addCustomer(c)
        
        presentationMode.wrappedValue.dismiss()
    }
}
