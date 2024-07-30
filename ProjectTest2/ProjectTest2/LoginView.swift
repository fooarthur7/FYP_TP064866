import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isLoggedIn: Bool
    @State private var navigateToRegister = false
    
    @EnvironmentObject var userData: UserData

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("logo_2") // Ensure this image is in your Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Login"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                NavigationLink(destination: RegisterView(), isActive: $navigateToRegister) {
                    Button(action: {
                        navigateToRegister = true
                    }) {
                        Text("Don't have an account? Register")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
            .padding()
        }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Both fields are required."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://172.20.10.2:8081/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60 // Increase timeout interval

        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Network error: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    alertMessage = "Login successful."
                    showAlert = true
                    isLoggedIn = true // Set login state to true
                    userData.email = email // Set the email in UserData
                    userData.password = password
                    userData.isLoggedIn = true // Set login state to true
                }
            } else {
                let responseMessage = String(data: data, encoding: .utf8) ?? "Invalid email or password."
                DispatchQueue.main.async {
                    alertMessage = "Login failed: Invalid email or password. "
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
            .environmentObject(UserData())
    }
}
