//
//  TrackViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//


import bLinkup
import CoreLocation
import SwiftUI
import UIKit

private let kLogsN = 1000
private var kLogI = 0

struct TrackView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> TrackViewController {
        return TrackViewController.instantiate()
    }

    func updateUIViewController(_ vc: TrackViewController, context: Context) {}
}


class TrackViewController: UIViewController,
                           UITableViewDataSource, UITableViewDelegate,
                           CLLocationManagerDelegate
{
    @IBOutlet var tableView: UITableView?
    @IBOutlet var currentLabel: UILabel?
    @IBOutlet var nearestNameLabel: UILabel?
    @IBOutlet var nearestPosLabel: UILabel?
    @IBOutlet var distanceLabel: UILabel?
    @IBOutlet var logView: UITextView?

    private let tracker = TrackingObject()
    private var presence = [Presence]()
    
    static func instantiate() -> TrackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: TrackViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "TrackViewController") as! TrackViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Geofencing"
        
        tracker.onLocationUpdate = { [weak self] loc, pl in
            DispatchQueue.main.async {
                self?.updateFormLocation(location: loc, nearest: pl)
            }
        }
        tracker.onPresenceUpdate = { [weak self] pr in
            DispatchQueue.main.async {
                self?.updateFormPresence(pr)
            }
        }
    }
    
    @IBAction func share() {
        let text = LogsManager.shared.export()
        let vc = UIActivityViewController(activityItems:[text],
                                          applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: -
    
    @MainActor
    func updateFormLocation(location: CLLocation?, nearest: Place?) {
        currentLabel?.text = location?.message ?? "?"
        if let location, let p = nearest {
            let l = CLLocation(latitude: p.latitude!, longitude: p.longitude!)
            nearestNameLabel?.text = p.name
            nearestPosLabel?.text = l.message(radius: p.radius ?? -1)
            distanceLabel?.text = String(format: "%.0fm", location.distance(from: l))
        } else {
            nearestNameLabel?.text = "-"
            nearestPosLabel?.text = "-"
            distanceLabel?.text = "-"
        }
        updateLogView()
    }
    
    @MainActor
    func updateFormPresence(_ p: Presence) {
        if let index = presence.firstIndex(of: p) {
            presence[index] = p
        } else {
            presence.append(p)
        }
        tableView?.reloadData()
        updateLogView()
    }
    
    func updateLogView() {
        logView?.text = LogsManager.shared.logs
            .reversed()
            .joined()
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presence.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let p = presence[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if let obj = p.place {
            cell.selectionStyle = .none
            cell.textLabel?.text = obj.name
            if let x = obj.longitude,
                let y = obj.latitude,
                let r = obj.radius 
            {
                cell.detailTextLabel?.text = "x\(x) y\(y) r\(Int(r))"
            } else {
                cell.detailTextLabel?.text = nil
            }
            cell.accessoryType = p.isPresent == true ? .checkmark : .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
}

extension CLLocation {
    var message: String {
        let x = String(format: "%.5f", coordinate.longitude)
        let y = String(format: "%.5f", coordinate.latitude)
        let acc = String(format: "%.0f", horizontalAccuracy)
        return "x\(x) y\(y) acc\(acc)"
    }
    
    func message(radius: Double) -> String {
        let x = String(format: "%.5f", coordinate.longitude)
        let y = String(format: "%.5f", coordinate.latitude)
        let r = String(format: "%.0f", radius)
        return "x\(x) y\(y) r\(r)"
    }
}
