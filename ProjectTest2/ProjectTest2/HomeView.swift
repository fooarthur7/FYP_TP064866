import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @StateObject private var audioManager = AudioManager()
    @StateObject private var vibrationManager = VibrationManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var networkManager = NetworkManager()

    @State private var isMonitoringSound = false
    @State private var isMonitoringVibration = false
    @State private var soundDetected = false
    @State private var vibrationDetected = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var showBanner = false
    @State private var showActionSheet = false
    @State private var mapAppChoice: MapAppChoice? = nil
    @State private var lastDetection: DetectionType? = nil

    private let maxVisibleShops = 5

    var body: some View {
        NavigationView {
            VStack {
                // Large Button to Start Detection
                Button(action: {
                    startStopDetectionAndOpenMap()
                }) {
                    Text(isMonitoringSound && isMonitoringVibration ? "Stop Detecting Car Accident" : "Start Detecting Car Accident")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isMonitoringSound && isMonitoringVibration ? Color.green : Color.red)
                        .cornerRadius(8)
                }
                .padding()

                // List of car repair shops
                if let userLocation = locationManager.userLocation {
                    ScrollView {
                        VStack {
                            ForEach(sortedShops().prefix(maxVisibleShops)) { shop in
                                CarRepairShopRow(shop: shop, userLocation: userLocation, openInMaps: openInMaps)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }
                            NavigationLink(destination: AllCarRepairShopsView(networkManager: networkManager, userLocation: userLocation, openInMaps: openInMaps)) {
                                Text("Show All")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    }
                    .frame(maxHeight: 350)
                } else {
                    Text("Loading location...")
                }

                // Real-Time Sound Level Display
                Text("Current Sound Level: \(audioManager.currentSoundLevel)")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                // Real-Time Vibration Level Display
                Text("Current Vibration Level: \(vibrationManager.currentVibrationLevel)")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                Spacer()
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text("Sound and Vibration detected simultaneously. Open the app?"),
                    primaryButton: .default(Text("Open")) {
                        // Action to open the app or perform any desired operation
                        restartDetection()
                        sendEmergencyMessage()
                    },
                    secondaryButton: .cancel {
                        restartDetection()
                    }
                )
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Select Map Application"),
                    message: Text("Choose the map application to open"),
                    buttons: [
                        .default(Text("Apple Maps")) { mapAppChoice = .appleMaps },
                        .default(Text("Google Maps")) { mapAppChoice = .googleMaps },
                        .default(Text("Waze")) { mapAppChoice = .waze },
                        .cancel()
                    ]
                )
            }
            .onChange(of: mapAppChoice) { choice in
                if let choice = choice, let userLocation = locationManager.userLocation {
                    openMapApplication(choice, with: userLocation)
                }
            }
            .onAppear {
                locationManager.startUpdatingLocation()
                networkManager.fetchCarRepairShops() // Fetch shops when the view appears
            }
            .onChange(of: audioManager.isAlertPresented) { newValue in
                if newValue {
                    soundDetected = true
                    lastDetection = .sound
                    checkSoundAndVibration()
                }
            }
            .onChange(of: vibrationManager.isAlertPresented) { newValue in
                if newValue {
                    vibrationDetected = true
                    lastDetection = .vibration
                    checkSoundAndVibration()
                }
            }
            .banner(isPresented: $showBanner, message: alertMessage, backgroundColor: .red)
        }
    }

    private func startStopDetectionAndOpenMap() {
        if isMonitoringSound || isMonitoringVibration {
            // Stop monitoring
            audioManager.stopMonitoring()
            vibrationManager.stopMonitoring()
            isMonitoringSound = false
            isMonitoringVibration = false
        } else {
            // Start monitoring
            audioManager.startMonitoring()
            vibrationManager.startMonitoring()
            isMonitoringSound = true
            isMonitoringVibration = true

            // Show action sheet to choose the map application
            showActionSheet = true
        }
    }

    private func restartDetection() {
        // Reset the monitoring flags
        isMonitoringSound = false
        isMonitoringVibration = false
    }

    private func openMapApplication(_ choice: MapAppChoice, with location: CLLocationCoordinate2D) {
        let coordinate = location
        switch choice {
        case .appleMaps:
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "Current Location"
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        case .googleMaps:
            if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: "https://maps.google.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .waze:
            if let url = URL(string: "waze://?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else if let url = URL(string: "https://waze.com/ul?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    private func openInMaps(shop: CarRepairShop) {
        let coordinate = CLLocationCoordinate2D(latitude: shop.lat, longitude: shop.lng)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = shop.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func sortedShops() -> [CarRepairShop] {
        guard let userLocation = locationManager.userLocation else {
            return networkManager.carRepairShops
        }
        return networkManager.carRepairShops.sorted {
            $0.distance(to: userLocation) ?? Double.infinity < $1.distance(to: userLocation) ?? Double.infinity
        }
    }

    // Function to check if both sound and vibration are detected
    func checkSoundAndVibration() {
        if soundDetected && lastDetection == .vibration || vibrationDetected && lastDetection == .sound {
            showAlert = true
            soundDetected = false
            vibrationDetected = false
        }
    }
    
    // Function to send emergency message
    func sendEmergencyMessage() {
        guard let userLocation = locationManager.userLocation else { return }
        let timestamp = Date().description
        let locationString = "Lat: \(userLocation.latitude), Long: \(userLocation.longitude)"
        
        guard let url = URL(string: "http://172.20.10.2:8081/send_emergency_message") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": userData.email, "location": locationString, "timestamp": timestamp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send emergency message: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    print("Emergency message sent successfully.")
                    alertMessage = "Emergency message sent successfully."
                    showBanner = true
                } else {
                    if let data = data {
                        let responseMessage = String(data: data, encoding: .utf8) ?? "Unknown error."
                        print("Failed to send emergency message: \(responseMessage)")
                        alertMessage = "Failed to send emergency message: \(responseMessage)"
                        showBanner = true
                    } else {
                        print("Failed to send emergency message: No data received.")
                        alertMessage = "No data received."
                        showBanner = true
                    }
                }
            }
        }.resume()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserData())
    }
}

enum MapAppChoice {
    case appleMaps
    case googleMaps
    case waze
}

enum DetectionType {
    case sound
    case vibration
}
