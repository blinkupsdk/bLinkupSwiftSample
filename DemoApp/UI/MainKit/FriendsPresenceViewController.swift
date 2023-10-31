//
//  FriendsPresenceViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 01.10.2023.
//

import UIKit
import bLinkup

class FriendsPresenceViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?
    
    var place: Place?
    var models = [Presence]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = place?.name
        
        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.refreshControl?.beginRefreshing()
        
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        guard let place else { return }
        bLinkup.getFriendsAtPlace(place, completion: { [weak self] in
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
        cell.textLabel?.text = obj.place?.name ?? "?"
        cell.detailTextLabel?.text = "\(obj.user.phone_number ?? "?"), \(obj.user.name ?? "?"), \(obj.insertedAt ?? "?") -> \(obj.isPresent)"

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = obj.id
        }))

        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}
