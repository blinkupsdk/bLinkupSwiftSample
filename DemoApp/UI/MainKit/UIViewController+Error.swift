//
//  UIViewController+Error.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 22.09.2023.
//

import UIKit

extension UIViewController {
    func showError(_ error: Error?) {
        showOkMessage(error?.localizedDescription, title: "Error")
    }
    
    func showOkMessage(_ message: String?, title: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    func ask(_ message: String?, completion: ((_ ok: Bool, String?) -> Void)?) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "Your option"
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            let answer = alert.textFields?.first?.text
            completion?(true, answer)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { _ in
            completion?(false, nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}
