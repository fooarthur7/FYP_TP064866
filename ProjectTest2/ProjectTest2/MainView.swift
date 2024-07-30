////
////  MainView.swift
////  ProjectTest2
////
////  Created by Arthur Foo Che Jit on 24/07/2024.
////
//
//import SwiftUI
//
//struct MainView: View {
//    @State private var isLoggedIn = false
//
//    var body: some View {
//        if isLoggedIn {
//            TabView {
//                HomeView()
//                    .tabItem {
//                        Image(systemName: "house.fill")
//                        Text("Home")
//                    }
//                AccountView()
//                    .tabItem {
//                        Image(systemName: "person.fill")
//                        Text("Account")
//                    }
//            }
//            .transition(.slide)
//            .navigationBarBackButtonHidden(true)
//            .onAppear {
//                // Ensure navigation bar back button is hidden
//                UINavigationBar.setAnimationsEnabled(false)
//            }
//        } else {
//            LoginView(isLoggedIn: $isLoggedIn)
//                .transition(.slide)
//        }
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
