//
//  File.swift
//  
//
//  Created by Arthur Foo Che Jit on 22/07/2024.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String
    
    @Field(key: "name")
    var name: String?

    @Field(key: "phoneNumber")
    var phoneNumber: String?
    
    @Field(key: "emergencyPhoneNumber")
    var emergencyPhoneNumber: String?

    init() {}

    init(id: UUID? = nil, email: String, password: String, name: String? = nil, phoneNumber: String? = nil, emergencyPhoneNumber: String? = nil) {
        self.id = id
        self.email = email
        self.password = password
        self.name = name
        self.phoneNumber = phoneNumber
        self.emergencyPhoneNumber = emergencyPhoneNumber
    }
}


struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("password", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

struct AddNameAndPhoneNumberToUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .field("name", .string)
            .field("phoneNumber", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .deleteField("name")
            .deleteField("phoneNumber")
            .update()
    }
}

struct AddEmergencyPhoneNumberToUsers: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .field("emergencyPhoneNumber", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .deleteField("emergencyPhoneNumber")
            .update()
    }
}
