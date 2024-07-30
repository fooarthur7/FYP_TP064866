//
//  CarRepairShopDetails+CoreDataProperties.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 30/06/2024.
//
//

import Foundation
import CoreData


extension CarRepairShopDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CarRepairShopDetails> {
        return NSFetchRequest<CarRepairShopDetails>(entityName: "CarRepairShopDetails")
    }

    @NSManaged public var contact: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension CarRepairShopDetails : Identifiable {

}
