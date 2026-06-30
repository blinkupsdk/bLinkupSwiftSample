//
//  NewCustomer.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 13/11/2024.
//

import bLinkupSDK
import SwiftUI

let kHostKey = "com.blinktech.sdk.host"
let kDevTokenKey = "com.blinktech.sdk.dev"

struct NewCustomerView: View {
    let id: String?
    @State var cid: String
    @State var name: String
    @State var primary: String
    @State var secondary: String
    @State var host: String?
    @State var helper: String
    
    @Environment(\.dismiss) var dismiss
    
    init(_ c: AppCustomer?) {
        self.id = c?.id
        self._cid = State(initialValue: c?.cid ?? "")
        self._name = State(initialValue: c?.name ?? "")
        self._primary = State(initialValue: c?.primary ?? "")
        self._secondary = State(initialValue: c?.secondary ?? "")
        self._host = State(initialValue: c?.host ?? Target.hosts.first)
        self._helper = State(initialValue: c?.helper ?? "")
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
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
                
                if Target.hosts.count > 1 {
                    HStack {
                        Text("Environment")
                            .foregroundColor(Color(uiColor: .lightGray))
                        Spacer()
                        Picker("Environment", selection: $host) {
                            ForEach(Target.hosts, id: \.self) { h in
                                Text(URL(string: h)!.host?.split(separator: ".").first ?? "?")
                                    .tag(h)
                            }
                        }
                        .foregroundColor(.blBlue)
                    }
                }
                
                SecureField("Helper", text: $helper)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.blBlue)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Customer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    addCustomer()
                }
            }
        })
    }
    
    func addCustomer() {
        guard let cid = self.cid.nonEmpty else { return }
        
        let c = AppCustomer(
            id: id ?? UUID().uuidString,
            cid: cid,
            name: name.nonEmpty,
            primary: primary.nonEmpty,
            secondary: secondary.nonEmpty,
            host: host,
            helper: helper.nonEmpty
        )
        DB.shared.addCustomer(c)
        
        dismiss()
    }
}

#Preview {
    NavigationView {
        NewCustomerView(nil)
    }
}
