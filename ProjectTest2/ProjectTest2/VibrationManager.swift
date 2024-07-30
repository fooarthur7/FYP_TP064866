//
//  VibrationManager.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 30/06/2024.
//

import CoreMotion
import SwiftUI
import UserNotifications

class VibrationManager: NSObject, ObservableObject {
    private var motionManager: CMMotionManager
    private var timer: Timer?
    @Published var isAlertPresented = false
    @Published var currentVibrationLevel: Double = 0.0

    override init() {
        motionManager = CMMotionManager()
        super.init()
        setupMotionManager()
        requestNotificationPermission()
    }

    private func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.1
    }

    func startMonitoring() {
        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.checkVibrationLevel()
            }
        }
    }

    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        timer?.invalidate()
    }

    private func checkVibrationLevel() {
        if let data = motionManager.accelerometerData {
            let acceleration = data.acceleration
            let vibrationLevel = sqrt(acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z)

            DispatchQueue.main.async {
                self.currentVibrationLevel = vibrationLevel
            }

            if vibrationLevel > 2.5 { // Threshold for significant vibration
                DispatchQueue.main.async {
                    self.isAlertPresented = true
                    self.sendNotification()
                    self.stopMonitoring()
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission request error: \(error)")
            }
        }
    }

    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Vibration Detected"
        content.body = "A significant vibration was detected. Open the app?"
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}
