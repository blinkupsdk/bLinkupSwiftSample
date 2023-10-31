//
//  ConnectionRequestsViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//

import bLinkup
import SwiftUI
import UIKit

struct ConnectionRequestsView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> ConnectionRequestsViewController {
        let vc = ConnectionRequestsViewController.instantiate()
        return vc
    }

    func updateUIViewController(_ vc: ConnectionRequestsViewController, context: Context) {}
}

class ConnectionRequestsViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?
    
    var models = [ConnectionRequest]()
    
    static func instantiate() -> ConnectionRequestsViewController {
        let storyboarad = UIStoryboard(name: "Main", bundle: Bundle(for: ConnectionRequestsViewController.self))
        let vc = storyboarad.instantiateViewController(identifier: "ConnectionRequestsViewController")
        
        return vc as! ConnectionRequestsViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        refreshData()
    }
    
    func refreshData() {
        tableView?.refreshControl?.beginRefreshing()
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        bLinkup.getFriendRequests { [weak self] in
            self?.tableView?.refreshControl?.endRefreshing()
            switch $0 {
            case .failure(let error):
                self?.showError(error)
            case .success(let list):
                self?.models = list
                self?.tableView?.reloadData()
            }
        }
    }
    
    @IBAction func addCustomRequest(_ sender: Any?) {
        ask("UserID", completion: { ok, id in
            guard ok, let id = id, !id.isEmpty else { return }
            let obj = User(id: id)
            bLinkup.sendConnectionRequest(user: obj, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success:
                    self?.refreshData()
                }
            })
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
            cell.textLabel?.text = "-> " + (obj.target.name ?? "?")
            cell.detailTextLabel?.text = obj.target.phone_number ?? "?"
        } else {
            cell.textLabel?.text = "<- " + (obj.source.name ?? "?")
            cell.detailTextLabel?.text = obj.source.phone_number ?? "?"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = obj.id
        }))
        
        if bLinkup.user?.id == obj.source.id {
        } else {
            menu.addAction(.init(title: "accept", style: .default, handler: { _ in
                bLinkup.acceptFriendRequest(obj) { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.showError(error)
                    case .success:
                        self?.refreshData()
                    }
                }
            }))
            
            menu.addAction(.init(title: "deny", style: .default, handler: { _ in
                bLinkup.denyFriendRequest(obj, completion: { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.showError(error)
                    case .success:
                        self?.refreshData()
                    }
                })
            }))        }

        
        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}

