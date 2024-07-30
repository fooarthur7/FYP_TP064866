////
////  CarRepairDataManager.swift
////  ProjectTest2
////
////  Created by Arthur Foo Che Jit on 30/06/2024.
////
//
//import CoreData
//
//class CarRepairDataManager {
//    static func loadCarRepairs(context: NSManagedObjectContext) {
//        guard let path = Bundle.main.path(forResource: "sample-data-Car_repair_and_maintenances", ofType: "csv") else {
//            return
//        }
//
//        do {
//            let data = try String(contentsOfFile: path)
//            let rows = data.components(separatedBy: "\n")
//            
//            for row in rows.dropFirst() { // Drop the header row
//                let columns = row.components(separatedBy: ",")
//                if columns.count == 6, // Adjust the number based on your CSV format
//                   let lat = Double(columns[4]),
//                   let lon = Double(columns[5]) {
//
//                    let shop = CarRepairShopDetails(context: context)
//                    shop.id = UUID()
//                    shop.name = columns[0]
//                    shop.contact = columns[2]
//                    shop.latitude = lat
//                    shop.longitude = lon
//                }
//            }
//            
//            try context.save()
//        } catch {
//            print("Error reading CSV file: \(error)")
//        }
//    }
//}
//
