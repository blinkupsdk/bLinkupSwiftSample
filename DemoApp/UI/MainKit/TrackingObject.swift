//
//  TrackViewModel.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 10/03/2025.
//

import bLinkup
import CoreLocation

class TrackingObject: NSObject,  CLLocationManagerDelegate {
    var onLocationUpdate: ((CLLocation?, Place?) -> Void)?
    var onPresenceUpdate: ((Presence) -> Void)?
    var onError: ((Error) -> Void)?
    
    private var currentLocation: CLLocation?
    private var nearestPlace: Place?
    private var presence = [Presence]()
    
    private var track: String?
    private let manager = CLLocationManager()
        
    override init() {
        super.init()
        
        bLinkup.addGeofencingObserver({ [weak self] in
            self?.updatePresenceInfo($0)
        })
        manager.delegate = self
        manager.startUpdatingLocation()
        loadPlaces()
    }
    
    deinit {
        if let track { bLinkup.removeTrackingObserver(id: track) }
    }
    
    func loadPlaces() {
        Task { [weak self] in
            do {
                self?.presence = try await bLinkup.getMyPresences()
            } catch {
                self?.onError?(error)
            }
        }
    }
    
    // MARK: - Helpers
    
    func updateLocationInfo(_ new: CLLocation?) {
        guard let new else { return }
        if let currentLocation,
           new.distance(from: currentLocation) < 1,
           currentLocation.horizontalAccuracy == new.horizontalAccuracy
            && currentLocation.verticalAccuracy == new.verticalAccuracy
        { return }

        currentLocation = new
        onLocationUpdate?(new, nearestPlace(to: new))
    }
        
    func updatePresenceInfo(_ new: [Presence]) {
        guard presence != new else { return }
        new.forEach({ p in
            if presence.first(where: { $0 == p })?.isPresent == p.isPresent { return }
            onPresenceUpdate?(p)
        })
        presence = new
    }
    
    func nearestPlace(to loc: CLLocation?) -> Place? {
        guard let loc else { return nil }
        return presence
            .compactMap({ $0.place })
            .filter({ $0.latitude != nil && $0.longitude != nil })
            .min(by: {
                let l = CLLocation(latitude: $0.latitude!, longitude: $0.longitude!)
                let r = CLLocation(latitude: $1.latitude!, longitude: $1.longitude!)
                return loc.distance(from: l) < loc.distance(from: r)
            })
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationInfo(locations.first)
    }
}
