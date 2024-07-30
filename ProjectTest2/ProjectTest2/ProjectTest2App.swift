//
//  ProjectTest2App.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 30/06/2024.
//

import SwiftUI

@main
struct ProjectTest2App: App {
    @StateObject private var userData = UserData()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userData)
        }
    }
}

