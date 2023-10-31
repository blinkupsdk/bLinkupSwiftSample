//
//  TrackViewController.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 23.09.2023.
//


import bLinkup
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
    UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet var tableView: UITableView?
    @IBOutlet var xLabel: UILabel?
    @IBOutlet var yLabel: UILabel?
    @IBOutlet var radiusLabel: UILabel?
    @IBOutlet var log: UITextView?

    var models = [GeoPoint]()
    var dir = [String: Bool]()
    var start: GeoPoint?
    var current: GeoPoint?
    
    deinit {
        bLinkup.stopTracking()
    }
    
    static func instantiate() -> TrackViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: TrackViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "TrackViewController") as! TrackViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startTracking()
    }
    
    @IBAction func didTapStart(_ sender: Any? = nil) {
        startTracking()
    }
    
    @IBAction func didTapStop(_ sender: Any? = nil) {
        bLinkup.stopTracking()
    }
    
    func startTracking() {
        bLinkup.startTracking(handler: { [weak self] p, dir in
            if p.name.starts(with: "start_") { self?.start = p }
            if p.name == "current" {
                self?.current = p
            } else {
                self?.dir[p.name] = dir
                self?.addPresence(p)
                self?.log?.text = "\(p.name) -> \(dir ? "in" : "out")\n"
                + (self?.log?.text ?? "")
            }
            self?.updateCurrentLocationLabels()
        })
    }
    
    // MARK: -
    
    func addPresence(_ p: GeoPoint) {
        if let index = models.firstIndex(where: { $0.name == p.name }) {
            models[index] = p
        } else {
            models.append(p)
        }
        tableView?.reloadData()
    }
    
    //
    func updateCurrentLocationLabels() {
        let oneDeg = 111134.0 //(1 deg = 111km 134m)
        if let p = current {
            xLabel?.text = p.x.description
            yLabel?.text = p.y.description
            radiusLabel?.text = p.r.description
            if let start {
                xLabel?.text = (xLabel?.text ?? "") + ": \(Int((start.x-p.x)*oneDeg))"
                yLabel?.text = (yLabel?.text ?? "") + ": \(Int((start.y-p.y)*oneDeg))"
            }
        } else {
            xLabel?.text = nil
            yLabel?.text = nil
            radiusLabel?.text = nil
        }
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
        cell.textLabel?.text = obj.name
        cell.detailTextLabel?.text = "x\(obj.x) y\(obj.y) r\(Int(obj.r))"
        cell.accessoryType = dir[obj.name] == true ? .checkmark : .none
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
