//
//  NetworkManager.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 24/07/2024.
//

import SwiftUI
import MapKit

class NetworkManager: NSObject, ObservableObject, URLSessionDelegate {
    @Published var carRepairShops: [CarRepairShop] = []

    func fetchCarRepairShops() {
        guard let url = URL(string: "http://172.20.10.2:8081/car_repair_shops_details") else { return }

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let shops = try JSONDecoder().decode([CarRepairShop].self, from: data)
                DispatchQueue.main.async {
                    self.carRepairShops = shops
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
