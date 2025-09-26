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
    @State var group: String
    
    @Environment(\.dismiss) var dismiss
    
    init(_ c: AppCustomer?) {
        self.id = c?.id ?? ""
        self._cid = State(initialValue: c?.cid ?? "")
        self._name = State(initialValue: c?.name ?? "")
        self._primary = State(initialValue: c?.primary ?? "")
        self._secondary = State(initialValue: c?.secondary ?? "")
        self._group = State(initialValue: c?.group ?? "")
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
                
                HStack {
                    Text("Config")
                        .foregroundColor(Color(uiColor: .lightGray))
                    Spacer()
                    Picker("Config", selection: $group) {
                        Text("regular").tag("")
                        Text("hocr").tag("hocr")
                    }
                    .foregroundColor(.blBlue)
                }

            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Customer")
        .navigationBarItems(trailing:
                                Button("Save") {
            addCustomer()
        }
            .padding(.top)
        )
    }
    
    func addCustomer() {
        guard let cid = self.cid.nonEmpty else { return }
        
        let c = AppCustomer(cid: cid,
                            name: name.nonEmpty,
                            primary: primary.nonEmpty,
                            secondary: secondary.nonEmpty,
                            group: group.nonEmpty)
        DB.shared.addCustomer(c)
        
        dismiss()
    }
}
