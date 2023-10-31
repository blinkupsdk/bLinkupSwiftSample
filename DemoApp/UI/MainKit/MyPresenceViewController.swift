//
//  MyPresenceViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//

import UIKit
import bLinkup

class MyPresenceViewController: UIViewController,
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?

    var models = [Presence]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView?.refreshControl?.beginRefreshing()
        
        loadData()
    }
    
    @IBAction func loadData(_ sender: Any? = nil) {
        bLinkup.getMyPresences(completion: { [weak self] in
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
    
    @IBAction func sendEnter(_ sender: Any? = nil) {
        sendPresence(true)
    }
    
    @IBAction func sendQuit(_ sender: Any? = nil) {
        sendPresence(false)
    }
    
    @IBAction func didTapMenu(_ sender: Any? = nil) {
        showMenu()
    }
    
    // MARK: - Sending presence manually
    
    func sendPresence(_ presence: Bool) {
        bLinkup.getEvents(completion: { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.showError(error)
            case .success(let places):
                self?.choosePlace(places, presence: presence)
            }
        })
    }
    
    func choosePlace(_ places: [Place], presence: Bool) {
        let menu = UIAlertController()

        for p in places {
            menu.addAction(.init(title: p.name, style: .default, handler: { _ in
                bLinkup.setUserAtEvent(presence, at: p, completion: { [weak self] in
                    switch $0 {
                    case .failure(let error):
                        self?.showError(error)
                    case .success(let place):
                        self?.models.insert(place, at: 0)
                        self?.tableView?.reloadData()
                    }
                })
            }))
        }

        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
    
    //

    func showMenu() {
        let menu = UIAlertController()

//        if let c = currentLocation {
//            menu.addAction(.init(title: "track current r=15", style: .default, handler: { _ in
//                let oneDeg = 111134.0 //(1 deg = 111km 134m)
//                let dif = 20.0 / oneDeg
//                let point = GeoPoint(name: "current_r15", x: c.x + dif, y: c.y, r: 15)
//                let token = bLinkupSDK.addPointObserver(point, handler: { [weak self] point, token, presence in
//                    self?.showOkMessage(presence.description, title: point.name)
//                })
//            }))
//        }
//        
//        menu.addAction(.init(title: "track 0,0,15", style: .default, handler: { _ in
//            let point = GeoPoint(name: "0_0_15", x: 0, y: 0, r: 15)
//            let token = bLinkupSDK.addPointObserver(point, handler: { [weak self] point, token, presence in
//                self?.showOkMessage(presence.description, title: point.name)
//            })
//        }))
        
        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
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
        cell.selectionStyle = .none
        cell.textLabel?.text = obj.place?.name ?? obj.place?.id
        cell.detailTextLabel?.text = "\(obj.insertedAt ?? ""): \(obj.isPresent ? "+" : "-")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = models[indexPath.row]
        
        let menu = UIAlertController()

//        menu.addAction(.init(title: "copy ID", style: .default, handler: { _ in
//            UIPasteboard.general.string = obj.id
//        }))

        menu.addAction(.init(title: "cancel", style: .cancel))
                       
        present(menu, animated: true)
    }
}
