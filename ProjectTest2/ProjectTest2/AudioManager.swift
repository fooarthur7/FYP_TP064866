//
//  AudioManager.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 30/06/2024.
//

import AVFoundation
import SwiftUI
import UserNotifications

class AudioManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    @Published var isAlertPresented = false
    @Published var currentSoundLevel: Float = 0.0
    
    override init() {
        super.init()
        setupRecorder()
        requestNotificationPermission()
    }
    
    private func setupRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatAppleLossless,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            let url = URL(fileURLWithPath: "/dev/null")
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func startMonitoring() {
        audioRecorder?.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.checkAudioLevel()
        }
    }
    
    func stopMonitoring() {
        audioRecorder?.stop()
        timer?.invalidate()
    }
    
    private func checkAudioLevel() {
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let linearLevel = pow(10, averagePower / 20)
        
        DispatchQueue.main.async {
            self.currentSoundLevel = linearLevel
        }
        
        if linearLevel > 0.7 { // Threshold for loud sound
            DispatchQueue.main.async {
                self.isAlertPresented = true
                self.sendNotification()
                self.stopMonitoring()
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
        content.title = "Sound Detected"
        content.body = "A loud sound was detected. Open the app?"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}

