//
//  ShopDetailView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 07/07/2024.
//

import SwiftUI
import MapKit

struct ShopDetailView: View {
    let shop: CarRepairShop
    @Binding var isPresented: Bool
    @State private var showCallAlert = false

    var body: some View {
        VStack {
            HStack {
                Text("Repair Shop Details")
                    .font(.headline)
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                }
            }
            .padding()

            HStack(alignment: .top) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .padding(.trailing, 10)

                VStack(alignment: .leading) {
                    Text(shop.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(shop.primaryCategoryName) // Assuming category is available in shop model
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)

            // Details section
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(icon: "phone.fill", text: shop.phone, action: {
                    showCallAlert = true
                })
                .alert(isPresented: $showCallAlert) {
                    Alert(
                        title: Text("Call \(shop.phone)?"),
                        message: Text("Are you sure you want to call this number?"),
                        primaryButton: .default(Text("Call")) {
                            if let url = URL(string: "tel://\(shop.phone)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }

                DetailRow(icon: "envelope.fill", text: shop.email, action: {
                    if let url = URL(string: "mailto:\(shop.email)"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                })

                DetailRow(icon: "link", text: shop.url, action: {
                    if let url = URL(string: shop.url), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                })
            }
            .padding(.horizontal)

            Divider()
                .padding(.horizontal)
            
            HStack {
                Text("Ratings \(shop.starCount, specifier: "%.1f") / 5.0")
                    .foregroundColor(.gray)
                Spacer()
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(shop.starCount) ? "star.fill" : "star")
                            .foregroundColor(index < Int(shop.starCount) ? .yellow : .gray)
                    }
                }
            }
            .padding(.horizontal)

            Button(action: {
                openInMaps(shop: shop)
            }) {
                Text("Direction")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
        .presentationDetents([.fraction(0.5)])
    }

    private func openInMaps(shop: CarRepairShop) {
        let coordinate = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lng)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shop.name
        mapItem.phoneNumber = shop.phone
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(text)
                .foregroundColor(.blue)
                .onTapGesture {
                    action()
                }
            Spacer()
        }
    }
}
