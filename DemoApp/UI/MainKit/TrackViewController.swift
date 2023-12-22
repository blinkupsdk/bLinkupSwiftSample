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
    @IBOutlet var log: UITextView?

    var current: CLLocation?
    var models = [Presence]() { willSet { addLog(models, newValue) }}
    var track: String?
    let manager = CLLocationManager()
    
    static func instantiate() -> TrackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: TrackViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "TrackViewController") as! TrackViewController
        return vc
    }
    
    deinit {
        if let track { bLinkup.removeTrackingObserver(id: track) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Geofencing"
        
        bLinkup.addGeofencingObserver(handleTrack)
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func handleTrack(_ p: [Presence]) {
        self.models = p
        tableView?.reloadData()
        updateCurrentLocationLabels()
    }
    
    // MARK: -
    
    func updateCurrentLocationLabels() {
        let oneDeg = 111134.0 //(1 deg = 111km 134m)
        currentLabel?.text = current?.message ?? "?"
        if let current,
           let min = models
            .compactMap({ $0.place })
            .filter({ $0.latitude != nil && $0.longitude != nil })
            .min(by: {
                let l = CLLocation(latitude: $0.latitude!, longitude: $0.longitude!)
                let r = CLLocation(latitude: $1.latitude!, longitude: $1.longitude!)
                return current.distance(from: l) < current.distance(from: r)
            })
        {
            let l = CLLocation(latitude: min.latitude!, longitude: min.longitude!)
            nearestNameLabel?.text = min.name
            nearestPosLabel?.text = l.message(radius: min.radius ?? -1)
            distanceLabel?.text = String(format: "%.0fm", current.distance(from: l))
        } else {
            nearestNameLabel?.text = "-"
            nearestPosLabel?.text = "-"
            distanceLabel?.text = "-"
        }
    }
    
    func addLog(_ old: [Presence], _ new: [Presence]) {
        new.forEach({ p in
            if old.first(where: { $0 == p })?.isPresent == p.isPresent { return }
            self.log?.text = "\(p.place?.name ?? "?") -> \(p.isPresent ? "in" : "out")\n"
            + (self.log?.text ?? "")
        })
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        current = locations.first
        updateCurrentLocationLabels()
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let p = models[indexPath.row]
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
