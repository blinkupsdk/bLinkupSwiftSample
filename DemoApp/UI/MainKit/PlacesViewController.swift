//
//  PlacesViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//

import UIKit
import bLinkup

class PlacesViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?
    
    var models = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.refreshControl?.beginRefreshing()
        
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        bLinkup.getEvents(completion: { [weak self] in
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
        cell.textLabel?.text = obj.name
        let strings: [String] = [(obj.latitude?.description ?? "?"),
                                 (obj.longitude?.description ?? "?"),
                                 (obj.radius?.description ?? "?"),
                                 "points - \(obj.blinkpoints?.count ?? 0)"]
        let string = strings.joined(separator: ", ")
        cell.detailTextLabel?.text = string

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
            UIPasteboard.general.string = obj.id
        }))
        
        menu.addAction(.init(title: "send 'Enter'", style: .default, handler: { _ in
            bLinkup.setUserAtEvent(true, at: obj, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success: ()
                }
            })
        }))
        
        menu.addAction(.init(title: "send 'Quit'", style: .default, handler: { _ in
            bLinkup.setUserAtEvent(false, at: obj, completion: { [weak self] in
                switch $0 {
                case .failure(let error):
                    self?.showError(error)
                case .success: ()
                }
            })
        }))
        
        menu.addAction(.init(title: "show friends at place", style: .default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FriendsPresenceViewController")
            if let fpvc = vc as? FriendsPresenceViewController {
                fpvc.place = obj
                self.navigationController?.pushViewController(fpvc, animated: true)
            }
        }))
        
        menu.addAction(.init(title: "show map", style: .default, handler: { _ in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "VenueMapVC")
            if let fpvc = vc as? VenueMapVC {
                fpvc.place = obj
                self.navigationController?.pushViewController(fpvc, animated: true)
            }
        }))

        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}
