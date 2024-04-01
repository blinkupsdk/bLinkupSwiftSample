//
//  DB.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.04.2024.
//

import bLinkup
import Foundation

extension String {
    static let keyCustomer = "Customer"
    static let keyCustomCustomers = "CustomCustomers"
}

class DB {
    static let shared = DB()
    
    func set(_ v: Encodable, key: String) {
        let data = try? JSONEncoder().encode(v)
        UserDefaults.standard.setValue(data, forKey: key)
    }
    
    func get<E: Decodable>(key: String) -> E? {
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            return try? JSONDecoder().decode(E.self, from: data)
        }
        return nil
    }
    
    // custom Customers
    
    @discardableResult
    func addCustomer(_ c: Customer) -> [Customer] {
        var list: [Customer] = get(key: .keyCustomCustomers) ?? []
        list = list.filter({ $0.id != c.id })
        list.insert(c, at: 0)
        set(list, key: .keyCustomCustomers)
        return list
    }
    
    @discardableResult
    func removeCustomer(_ c: Customer) -> [Customer] {
        var list: [Customer] = get(key: .keyCustomCustomers) ?? []
        list = list.filter({ $0.id != c.id })
        set(list, key: .keyCustomCustomers)
        return list
    }
}
