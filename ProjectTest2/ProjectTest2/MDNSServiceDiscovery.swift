//
//  MDNSServiceDiscovery.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 30/07/2024.
//

import Foundation
import Network

class MDNSServiceDiscovery: NSObject, ObservableObject, NetServiceBrowserDelegate, NetServiceDelegate {
    @Published var serverIPAddress: String?

    private var serviceBrowser: NetServiceBrowser
    private var discoveredService: NetService?

    override init() {
        self.serviceBrowser = NetServiceBrowser()
        super.init()
        self.serviceBrowser.delegate = self
    }

    func startDiscovery() {
        self.serviceBrowser.searchForServices(ofType: "_http._tcp.", inDomain: "local.")
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        self.discoveredService = service
        service.delegate = self
        service.resolve(withTimeout: 5.0)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        if let addresses = sender.addresses, let firstAddress = addresses.first {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            firstAddress.withUnsafeBytes { pointer in
                let sockaddrPointer = pointer.bindMemory(to: sockaddr.self).baseAddress
                if let sockaddrPointer = sockaddrPointer {
                    getnameinfo(sockaddrPointer, socklen_t(firstAddress.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                }
            }
            if let address = String(validatingUTF8: hostname) {
                DispatchQueue.main.async {
                    self.serverIPAddress = address
                }
            }
        }
    }
}

