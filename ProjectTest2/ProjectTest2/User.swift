//
//  User.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 24/07/2024.
//

import Foundation

struct User: Codable, Identifiable {
    var id: String { "\(name)-\(email)-\(phoneNumber)" }
    let password: String
    let email: String
    let name: String?
    let phoneNumber: String?
    let emergencyPhoneNumber: String?


    enum CodingKeys: String, CodingKey {
        case name, password, email, phoneNumber, emergencyPhoneNumber
    }
}
