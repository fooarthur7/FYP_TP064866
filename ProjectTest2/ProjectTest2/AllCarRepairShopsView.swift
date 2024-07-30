//
//  AllCarRepairShopsView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 24/07/2024.
//

import SwiftUI
import MapKit

struct CarRepairShopRow: View {
    let shop: CarRepairShop
    let userLocation: CLLocationCoordinate2D
    let openInMaps: (CarRepairShop) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(shop.name)
                    .font(.headline)
                Text(shop.address)
                    .font(.subheadline)
                if let distance = shop.distance(to: userLocation) {
                    Text(String(format: "%.2f km away", distance))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: {
                openInMaps(shop)
            }) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
    }
}

struct AllCarRepairShopsView: View {
    @ObservedObject var networkManager: NetworkManager
    let userLocation: CLLocationCoordinate2D
    let openInMaps: (CarRepairShop) -> Void

    var body: some View {
        ScrollView {
            VStack {
                ForEach(sortedShops()) { shop in
                    CarRepairShopRow(shop: shop, userLocation: userLocation, openInMaps: openInMaps)
                }
            }
        }
        .navigationBarTitle("All Car Repair Shops", displayMode: .inline)
    }
    
    private func sortedShops() -> [CarRepairShop] {
        return networkManager.carRepairShops.sorted {
            $0.distance(to: userLocation) ?? Double.infinity < $1.distance(to: userLocation) ?? Double.infinity
        }
    }
}
