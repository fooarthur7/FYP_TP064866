import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.post("register") { req -> EventLoopFuture<HTTPStatus> in
        let user = try req.content.decode(User.self)
        return User.query(on: req.db)
            .filter(\.$email == user.email)
            .first()
            .flatMapThrowing { existingUser in
                guard existingUser == nil else {
                    throw Abort(.badRequest, reason: "Email already exists")
                }
                user.password = try Bcrypt.hash(user.password)
                return user
            }
            .flatMap { user in
                user.save(on: req.db).transform(to: .ok)
            }
    }

    app.post("login") { req -> EventLoopFuture<Response> in
        let user = try req.content.decode(User.self)
        return User.query(on: req.db)
            .filter(\.$email == user.email)
            .first()
            .flatMapThrowing { existingUser in
                guard let existingUser = existingUser, try Bcrypt.verify(user.password, created: existingUser.password) else {
                    throw Abort(.unauthorized, reason: "Invalid email or password")
                }
                let response = Response(status: .ok)
                response.body = .init(string: "{\"status\":\"success\"}")
                response.headers.replaceOrAdd(name: .contentType, value: "application/json")
                return response
            }
    }
    
    app.get("car_repair_shops_details") { req -> EventLoopFuture<[CarRepairShop]> in
        return CarRepairShop.query(on: req.db).all()
    }
    
    app.get("user") { req -> EventLoopFuture<User> in
        // Fetch user details
        let email = try req.query.get(String.self, at: "email")
        return User.query(on: req.db)
            .filter(\.$email == email)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    
    app.put("user") { req -> EventLoopFuture<HTTPStatus> in
        let updatedUser = try req.content.decode(User.self)
        return User.query(on: req.db)
            .filter(\.$email == updatedUser.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { existingUser in
                existingUser.email = updatedUser.email
                if let name = updatedUser.name {
                    existingUser.name = name
                }
                if let phoneNumber = updatedUser.phoneNumber {
                    existingUser.phoneNumber = phoneNumber
                }
                if let emergencyPhoneNumber = updatedUser.emergencyPhoneNumber {
                    existingUser.emergencyPhoneNumber = emergencyPhoneNumber
                }
                return existingUser.update(on: req.db).transform(to: .ok)
            }
    }
    
    app.post("change_password") { req -> EventLoopFuture<HTTPStatus> in
        let data = try req.content.decode(ChangePasswordRequest.self)
        
        return User.query(on: req.db)
            .filter(\.$email == data.email)
            .first()
            .flatMapThrowing { user in
                guard let user = user, try Bcrypt.verify(data.currentPassword, created: user.password) else {
                    throw Abort(.unauthorized, reason: "Current password is incorrect.")
                }
                
                user.password = try Bcrypt.hash(data.newPassword)
                return user
            }
            .flatMap { user in
                user.update(on: req.db).transform(to: .ok)
            }
    }
    
    app.post("send_emergency_message") { req -> EventLoopFuture<HTTPStatus> in
        let data = try req.content.decode(EmergencyMessageRequest.self)
        
        // Fetch user details
        return User.query(on: req.db)
            .filter(\.$email == data.email)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                guard let emergencyPhoneNumber = user.emergencyPhoneNumber else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Emergency phone number not found."))
                }
                
                // Ensure the phone number is in E.164 format with the WhatsApp prefix
                var formattedPhoneNumber = emergencyPhoneNumber
                if !formattedPhoneNumber.hasPrefix("+") {
                    formattedPhoneNumber = "+6" + formattedPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                }
//                formattedPhoneNumber = "whatsapp:" + formattedPhoneNumber
                
                guard let accountSid = Environment.get("TWILIO_ACCOUNT_SID"),
                      let authToken = Environment.get("TWILIO_AUTH_TOKEN"),
                      let fromNumber = Environment.get("TWILIO_FROM_NUMBER"),
                      !accountSid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !authToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      !fromNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return req.eventLoop.makeFailedFuture(Abort(
                        .serviceUnavailable,
                        reason: "Emergency messaging is not configured. Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM_NUMBER."
                    ))
                }

                let twilioService = TwilioService(
                    accountSid: accountSid,
                    authToken: authToken,
                    fromWhatsAppNumber: fromNumber
                )
                
                // Generate URLs for navigation apps
                let locationComponents = data.location.split(separator: ",")
                guard locationComponents.count == 2,
                      let latitude = locationComponents.first?.split(separator: ":").last?.trimmingCharacters(in: .whitespaces),
                      let longitude = locationComponents.last?.split(separator: ":").last?.trimmingCharacters(in: .whitespaces) else {
                    return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Invalid location format."))
                }

//                let appleMapsURL = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
//                let googleMapsURL = "https://maps.google.com/?q=\(latitude),\(longitude)"
//                let wazeURL = "https://waze.com/ul?ll=\(latitude),\(longitude)&navigate=yes"

                
                // Construct the emergency message
                let message = """
                Emergency message sent to \(formattedPhoneNumber)
                From \(String(describing: user.phoneNumber)) :
                Our user \(String(describing: user.name)) met with a car accident
                Location: \(data.location) (https://maps.google.com/?q=\(latitude),\(longitude))
                Timestamp: \(data.timestamp)
                """
                
                return twilioService.sendWhatsAppMessage(to: formattedPhoneNumber, body: message, app: req.application)
            }
    }
}


struct ChangePasswordRequest: Content {
    let email: String
    let currentPassword: String
    let newPassword: String
}

struct EmergencyMessageRequest: Content {
    let email: String
    let location: String
    let timestamp: String
}
