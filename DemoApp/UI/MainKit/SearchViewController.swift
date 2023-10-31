//
//  SearchViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//

import UIKit
import bLinkup
import SwiftUI

struct SearchView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> SearchViewController {
        let vc = SearchViewController.instantiate()
        return vc
    }

    func updateUIViewController(_ vc: SearchViewController, context: Context) {}
}

@MainActor
class SearchViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet var tableView: UITableView?
    @IBOutlet var searchBar: UISearchBar?

    var models = [User]()
    
    static func instantiate() -> SearchViewController {
        let storyboarad = UIStoryboard(name: "Main", bundle: Bundle(for: SearchViewController.self))
        let vc = storyboarad.instantiateViewController(identifier: "SearchViewController")
        
        return vc as! SearchViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.refreshControl?.beginRefreshing()
        
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        let query = searchBar?.text
        bLinkup.findUsers(query: query, completion: { [weak self] in
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
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView?.refreshControl?.beginRefreshing()
        loadData()
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
        cell.textLabel?.text = obj.name ?? "?"
        cell.detailTextLabel?.text =
        [obj.phone_number, obj.email_address]
            .compactMap({ $0 })
            .joined(separator: ", ")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = obj.id
        }))
        
        menu.addAction(.init(title: "send connection request", style: .default, handler: { _ in
            bLinkup.sendConnectionRequest(user: obj, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success:
                    self?.showOkMessage("sent")
                }
            })
        }))
        
        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}
