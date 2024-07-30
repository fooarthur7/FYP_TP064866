import SwiftUI
import MapKit

struct FullScreenMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var isRegionSet = false // Flag to check if the region has been set initially
    @StateObject private var networkManager = NetworkManager() // Instantiate NetworkManager

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: networkManager.carRepairShops) { shop in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lng)) {
                CarRepairShopAnnotationView(shop: shop)
            }
        }
        .onAppear {
            networkManager.fetchCarRepairShops()
        }
        .onChange(of: locationManager.userLocation) { newLocation in
            if let newLocation = newLocation, !isRegionSet {
                region = MKCoordinateRegion(
                    center: newLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                isRegionSet = true // Set the flag to true after the initial region update
            }
        }
    }
}
