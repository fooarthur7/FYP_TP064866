import SwiftUI

struct MyProfileView: View {
    @EnvironmentObject var userData: UserData
    @State private var email = ""
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var emergencyPhoneNumber = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                VStack(alignment: .leading) {
                    Text("Email")
//                        .font(.headline)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                        .disabled(true)
                }
                
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Name", text: $name)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text("Phone Number")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text("Emergency Phone Number")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Emergency Phone Number", text: $emergencyPhoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
            }

            Button(action: {
                saveProfile()
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .navigationBarTitle("My Profile", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            email = userData.email
            password = userData.password
            fetchProfile()
        }
    }

    func fetchProfile() {
        guard let url = URL(string: "http://172.20.10.2:8081/user?email=\(email)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to fetch profile: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Response JSON: \(json)")
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    email = user.email
                    name = user.name ?? ""
                    phoneNumber = user.phoneNumber ?? ""
                    emergencyPhoneNumber = user.emergencyPhoneNumber ?? ""
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Failed to decode profile data: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }

    func saveProfile() {
        guard let url = URL(string: "http://172.20.10.2:8081/user") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "name": name, "phoneNumber": phoneNumber, "password": password, "emergencyPhoneNumber": emergencyPhoneNumber]
        print("Request Body: \(body)") // Log the request body
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Failed to save profile: \(error?.localizedDescription ?? "Unknown error")"
                    showAlert = true
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    alertMessage = "Profile saved successfully."
                    showAlert = true
                }
            } else {
                let responseMessage = String(data: data, encoding: .utf8) ?? "Unknown error."
                DispatchQueue.main.async {
                    alertMessage = "Failed to save profile: \(responseMessage)"
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct MyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MyProfileView()
            .environmentObject(UserData())
    }
}
