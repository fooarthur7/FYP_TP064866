//
//  AccountView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 23/07/2024.
//

import SwiftUI

struct AccountView: View {
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var userData: UserData

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: MyProfileView()) {
                        AccountRow(icon: "person.crop.circle", iconColor: .blue, title: "My Profile")
                    }
                    
                    NavigationLink(destination: ChangePasswordView()) {
                        AccountRow(icon: "lock.circle", iconColor: .orange, title: "Change Password")
                    }
                    
                    Button(action: {
                        logout()
                    }) {
                        AccountRow(icon: "arrow.right.circle", iconColor: .red, title: "Logout")
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationBarTitle("My Account", displayMode: .inline)
            .listStyle(InsetGroupedListStyle())
        }
    }

    func logout() {
        // Perform any necessary logout actions, such as clearing user session
        isLoggedIn = false
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(isLoggedIn: .constant(true))
            .environmentObject(UserData())
    }
}
