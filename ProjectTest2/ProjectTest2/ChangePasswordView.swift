//
//  ChangePasswordView.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 25/07/2024.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var userData: UserData
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Change Password")) {
                SecureField("Current Password", text: $currentPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                SecureField("Confirm New Password", text: $confirmNewPassword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
            }

            Button(action: {
                changePassword()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .navigationBarTitle("Change Password", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func changePassword() {
        guard !currentPassword.isEmpty, !newPassword.isEmpty, !confirmNewPassword.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }
        
        guard newPassword == confirmNewPassword else {
            alertMessage = "New passwords do not match."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://172.20.10.2:8081/change_password") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": userData.email, "currentPassword": currentPassword, "newPassword": newPassword]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to change password: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    alertMessage = "Password changed successfully."
                    showAlert = true
                }
            } else {
                let responseMessage = String(data: data, encoding: .utf8) ?? "Unknown error."
                DispatchQueue.main.async {
                    alertMessage = "Failed to change password: Current password is incorrect."
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(UserData())
    }
}
