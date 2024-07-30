import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode // Environment variable to dismiss the view

    var body: some View {
        VStack(spacing: 20) {
            Image("logo_2") // Ensure this image is in your Assets
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text("Register")
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

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            Button(action: {
                register()
            }) {
                Text("Register")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Registration"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                    if alertMessage == "Registration successful." {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view on successful registration
                    }
                }))
            }
        }
        .padding()
    }

    func register() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
                    alertMessage = "Please enter a valid email address."
                    showAlert = true
                    return
                }

        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }

        guard let url = URL(string: "http://172.20.10.2:8081/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

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
                    alertMessage = "Registration successful."
                    showAlert = true
                }
            } else {
                let responseMessage = String(data: data, encoding: .utf8) ?? "Failed to register."
                DispatchQueue.main.async {
                    alertMessage = "Registration failed: Failed to register."
                    showAlert = true
                }
            }
        }.resume()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES[c] %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
