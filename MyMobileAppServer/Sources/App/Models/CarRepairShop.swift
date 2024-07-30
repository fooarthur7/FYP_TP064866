//
//  File.swift
//  
//
//  Created by Arthur Foo Che Jit on 23/07/2024.
//

import Fluent
import Vapor

final class CarRepairShop: Model, Content {
    static let schema = "car_repair_shops_details"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "address")
    var address: String

    @Field(key: "phone")
    var phone: String

    @Field(key: "email")
    var email: String

    @Field(key: "lat")
    var lat: Double

    @Field(key: "lng")
    var lng: Double

    @Field(key: "url")
    var url: String

    @Field(key: "country")
    var country: String

    @Field(key: "state")
    var state: String

    @Field(key: "city")
    var city: String

    @Field(key: "star_count")
    var starCount: Double

    @Field(key: "rating_count")
    var ratingCount: Int

    @Field(key: "zip")
    var zip: String

    @Field(key: "primary_category_name")
    var primaryCategoryName: String

    @Field(key: "category_name")
    var categoryName: String

    init() { }

    init(id: UUID? = nil, name: String, address: String, phone: String, email: String, lat: Double, lng: Double, url: String, country: String, state: String, city: String, starCount: Double, ratingCount: Int, zip: String, primaryCategoryName: String, categoryName: String) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.email = email
        self.lat = lat
        self.lng = lng
        self.url = url
        self.country = country
        self.state = state
        self.city = city
        self.starCount = starCount
        self.ratingCount = ratingCount
        self.zip = zip
        self.primaryCategoryName = primaryCategoryName
        self.categoryName = categoryName
    }
}

struct CreateNewCarRepairShop: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CarRepairShop.schema)
            .id()
            .field("name", .string, .required)
            .field("address", .string, .required)
            .field("phone", .string, .required)
            .field("email", .string, .required)
            .field("lat", .double, .required)
            .field("lng", .double, .required)
            .field("url", .string, .required)
            .field("country", .string, .required)
            .field("state", .string, .required)
            .field("city", .string, .required)
            .field("star_count", .double, .required)
            .field("rating_count", .int, .required)
            .field("zip", .string, .required)
            .field("primary_category_name", .string, .required)
            .field("category_name", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CarRepairShop.schema).delete()
    }
}

//struct UpdateLatToCarRepairShops: Migration {
//    func prepare(on database: Database) -> EventLoopFuture<Void> {
//        database.schema(CarRepairShop.schema)
//            .field("lat", .string)
//            .update()
//    }
//
//    func revert(on database: Database) -> EventLoopFuture<Void> {
//        database.schema(CarRepairShop.schema)
//            .deleteField("id")
//            .update()
//    }
//}
