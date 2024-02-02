//
//  NetworkMonitor.swift
//  iClimate
//
//  Created by Sagar Modi on 28/01/2024.
//

import Foundation
import Network
import Observation

@Observable
class NetworkMonitor {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
}

