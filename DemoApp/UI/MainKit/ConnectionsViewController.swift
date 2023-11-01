//
//  ConnectionsViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//

import bLinkup
import SwiftUI
import UIKit

struct ConnectionsView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> ConnectionsViewController {
        let vc = ConnectionsViewController.instantiate()
        return vc
    }

    func updateUIViewController(_ vc: ConnectionsViewController, context: Context) {}
}

class ConnectionsViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?
    
    var models = [Connection]()
    
    static func instantiate() -> ConnectionsViewController {
        let storyboarad = UIStoryboard(name: "Main", bundle: Bundle(for: ConnectionsViewController.self))
        let vc = storyboarad.instantiateViewController(identifier: "ConnectionsViewController")
        
        return vc as! ConnectionsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.refreshControl?.beginRefreshing()
        
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        bLinkup.getFriendList(completion: { [weak self] in
            self?.tableView?.refreshControl?.endRefreshing()
            switch $0 {
            case .failure(let error):
                self?.showError(error)
            case .success(let list):
                self?.models = list
                self?.tableView?.reloadData()
            }
        })
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let obj = models[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        if bLinkup.user?.id == obj.source.id {
            cell.textLabel?.text = obj.target.name ?? "?"
        } else {
            cell.textLabel?.text = obj.source.name ?? "?"
        }
        cell.detailTextLabel?.text =
        (obj.source.phone_number ?? "?")
        + " -> "
        + (obj.target.phone_number ?? "?")
        + " = "
        + obj.status.rawValue

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = obj.id
        }))
        
        menu.addAction(.init(title: "block", style: .default, handler: { _ in
            bLinkup.updateConnection(obj, status: .blocked, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success(let c):
                    self?.models[indexPath.row] = c
                    self?.tableView?.reloadData()
                }
            })
        }))
        
        menu.addAction(.init(title: "unblock", style: .default, handler: { _ in
            bLinkup.updateConnection(obj, status: .connected, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success(let c):
                    self?.models[indexPath.row] = c
                    self?.tableView?.reloadData()
                }
            })
        }))
        
        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}
