//
//  CLLocationCoordinate2DExtensions.swift
//  ProjectTest2
//
//  Created by Arthur Foo Che Jit on 04/07/2024.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

