//
//  MainTabView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 24/07/2024.
//

import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            FullScreenMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }

            AccountView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My Account")
                }
        }
    }
}
