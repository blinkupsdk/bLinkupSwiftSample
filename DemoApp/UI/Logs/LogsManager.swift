//
//  LogsManager.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 10/03/2025.
//

import bLinkup
import CoreLocation

private let kLogsMax = 1000

class LogsManager {
    static let shared = LogsManager()
    
    private(set) var logs = [String]()
    private var logI = 0
    
    enum LogType: String {
        case Presence, Location, Nearest
    }
    
    // MARK: - General
    
    func addLog(_ t: LogType,_ log: String?) {
        guard let log else { return }
        logs.append("\(logI),\(t.rawValue),\(log)\n")
        logI += 1
        
        logs.removeFirst(max(logs.count - kLogsMax, 0))
    }

    func export() -> String {
        logs.joined()
    }
    
    // MARK: - Custom
    
    func addLogPresence(_ p: Presence) {
        let log = "\(p.place?.name ?? "?") -> \(p.isPresent ? "in" : "out")"
        addLog(.Presence, log)
    }
    
    func addLogLocation(_ location: CLLocation, nearest: Place?) {
        addLog(.Location, location.message)
        if let p = nearest {
            let l = CLLocation(latitude: p.latitude!, longitude: p.longitude!)
            let mes = l.message(radius: p.radius ?? -1)
            let dist = String(format: "%.0fm", location.distance(from: l))
            addLog(.Nearest, [p.name, mes, dist].joined(separator:" "))
        }
    }
}
