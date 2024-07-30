import UIKit
import MapKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Example coordinates
        let latitude: CLLocationDegrees = 37.7749
        let longitude: CLLocationDegrees = -122.4194
        let regionDistance: CLLocationDistance = 1000

        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        //let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)

        let appleMapsUrl = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
//        let googleMapsUrl = "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14"

//        if let googleMapsURL = URL(string: googleMapsUrl), UIApplication.shared.canOpenURL(googleMapsURL) {
//            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
//        } else 
        if let appleMapsURL = URL(string: appleMapsUrl) {
            UIApplication.shared.open(appleMapsURL, options: [:], completionHandler: nil)
        }
    }
}
