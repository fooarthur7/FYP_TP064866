import Foundation
import CoreLocation

struct CarRepairShop: Codable, Identifiable {
    var id: String { "\(name)-\(lat)-\(lng)" } // Combine properties to create a unique identifier
    let name: String
    let phone: String
    let email: String
    let lat: Double
    let lng: Double
    let url: String
    let starCount: Double
    let primaryCategoryName: String
    let address: String
    
    func distance(to location: CLLocationCoordinate2D) -> Double? {
        let shopLocation = CLLocation(latitude: self.lat, longitude: self.lng)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return shopLocation.distance(from: userLocation) / 1000
    }

    enum CodingKeys: String, CodingKey {
        case name, phone, email, lat, lng, url, starCount, primaryCategoryName, address
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        phone = try container.decode(String.self, forKey: .phone)
        email = try container.decode(String.self, forKey: .email)
        url = try container.decode(String.self, forKey: .url)
        primaryCategoryName = try container.decode(String.self, forKey: .primaryCategoryName)
        lat = try container.decode(Double.self, forKey: .lat)
        lng = try container.decode(Double.self, forKey: .lng)
        starCount = try container.decode(Double.self, forKey: .starCount)
    }
}
