////
////  SpeedManager.swift
////  ProjectTest2
////
////  Created by Arthur Foo Che Jit on 20/07/2024.
////
//
//import Foundation
//import CoreLocation
//
//class SpeedManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    @Published var currentSpeed: CLLocationSpeed = 0.0
//    @Published var isAlertPresented = false
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let speed = locations.last?.speed, speed >= 0 else {
//            return
//        }
//        handleSpeedUpdate(speed)
//    }
//
//    private func handleSpeedUpdate(_ speed: CLLocationSpeed) {
//        if speed == 0.0 && currentSpeed > 0.0 {
//            // Speed dropped to zero
//            isAlertPresented = true
//        }
//        currentSpeed = speed
//    }
//}
