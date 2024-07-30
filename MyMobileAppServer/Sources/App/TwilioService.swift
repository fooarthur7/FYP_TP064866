//
//  File.swift
//  
//
//  Created by Arthur Foo Che Jit on 25/07/2024.
//

import Vapor

struct TwilioService {
    let accountSid: String
    let authToken: String
    let fromWhatsAppNumber: String

    func sendWhatsAppMessage(to toPhoneNumber: String, body: String, app: Application) -> EventLoopFuture<HTTPStatus> {
        let url = URI(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSid)/Messages.json")

        let basicAuth = "\(accountSid):\(authToken)".data(using: .utf8)?.base64EncodedString() ?? ""

        let headers: HTTPHeaders = [
            "Authorization": "Basic \(basicAuth)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]

        let formData = [
            "From": "\(fromWhatsAppNumber)",
            "To": "\(toPhoneNumber)",
            "Body": body
        ]
        let bodyString = formData.map { "\($0.key)=\($0.value)" }.joined(separator: "&")

        var bodyBuffer = ByteBufferAllocator().buffer(capacity: bodyString.count)
        bodyBuffer.writeString(bodyString)

        let request = ClientRequest(method: .POST, url: url, headers: headers, body: bodyBuffer)

        return app.client.send(request).flatMap { response in
            if let responseBody = response.body {
                let responseBodyString = responseBody.getString(at: responseBody.readerIndex, length: responseBody.readableBytes) ?? "No response body"
                if response.status == .ok || response.status == .accepted || response.status == .created {
                    print("Message sent successfully: \(responseBodyString)")
                    return app.eventLoopGroup.future(.ok)
                } else {
                    print("Failed to send message: \(responseBodyString)")
                    return app.eventLoopGroup.future(response.status)
                }
            } else {
                print("Failed to send message: No response body")
                return app.eventLoopGroup.future(.internalServerError)
            }
        }
    }
}
